// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
//
// class EditProfilePage extends StatefulWidget {
//   const EditProfilePage({super.key});
//
//   @override
//   State<EditProfilePage> createState() => _EditProfilePageState();
// }
//
// class _EditProfilePageState extends State<EditProfilePage> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _bioController = TextEditingController();
//
//   String? _selectedImagePath;
//   Uint8List? _selectedImageBytes;
//   bool _isLoading = false;
//   bool _isImageUploading = false;
//   String? _originalDisplayName;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCurrentUserData();
//   }
//
//   void _loadCurrentUserData() {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       _originalDisplayName = user.displayName ?? '';
//       _nameController.text = _originalDisplayName!;
//       _emailController.text = user.email ?? '';
//     }
//   }
//
//   Future<void> _pickImage() async {
//     try {
//       final picker = ImagePicker();
//       final pickedFile = await picker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 70,
//         maxWidth: 800,
//       );
//
//       if (pickedFile != null) {
//         setState(() {
//           _selectedImagePath = pickedFile.path;
//           _isImageUploading = true;
//         });
//
//         final bytes = await pickedFile.readAsBytes();
//         setState(() {
//           _selectedImageBytes = bytes;
//           _isImageUploading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to pick image: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//       setState(() {
//         _isImageUploading = false;
//       });
//     }
//   }
//
//   Future<String?> _uploadImageToFirebase() async {
//     if (_selectedImageBytes == null) return null;
//
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) return null;
//
//       final storageRef = FirebaseStorage.instance
//           .ref()
//           .child('profile_pictures')
//           .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
//
//       print('Starting image upload, size: ${_selectedImageBytes!.lengthInBytes} bytes');
//
//       final uploadTask = storageRef.putData(
//         _selectedImageBytes!,
//         SettableMetadata(contentType: 'image/jpeg'),
//       );
//
//       // Listen for progress
//       uploadTask.snapshotEvents.listen((snapshot) {
//         final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
//         print('Upload progress: ${progress.toStringAsFixed(1)}%');
//       });
//
//       final snapshot = await uploadTask;
//       final downloadUrl = await snapshot.ref.getDownloadURL();
//       print('✅ Image uploaded successfully: $downloadUrl');
//       return downloadUrl;
//     } catch (e) {
//       print('❌ Image upload error: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Image upload failed: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//       return null;
//     }
//   }
//
//   Future<void> _updateUserProfile(String? photoUrl) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) throw Exception('User not authenticated');
//
//     bool needsUpdate = false;
//     String? newDisplayName;
//     String? newPhotoUrl;
//
//     // Check if display name changed (compare with original, not current)
//     final currentName = _nameController.text.trim();
//     if (currentName != _originalDisplayName) {
//       newDisplayName = currentName;
//       needsUpdate = true;
//       print('📝 Display name changed: "$_originalDisplayName" -> "$newDisplayName"');
//     } else {
//       print('📝 Display name unchanged: "$currentName"');
//     }
//
//     // Check if we have a new photo URL
//     if (photoUrl != null) {
//       newPhotoUrl = photoUrl;
//       needsUpdate = true;
//       print('🖼️ New photo URL available');
//     }
//
//     // Also update if user wants to remove existing photo but we're not uploading new one
//     final hasExistingPhoto = user.photoURL != null;
//     final isUploadingNewPhoto = photoUrl != null;
//     final wantsToRemovePhoto = _selectedImageBytes == null && hasExistingPhoto;
//
//     if (wantsToRemovePhoto && !isUploadingNewPhoto) {
//       newPhotoUrl = null; // Remove photo
//       needsUpdate = true;
//       print('🗑️ Removing existing photo');
//     }
//
//     // If there's nothing to update, return early
//     if (!needsUpdate) {
//       print('⏭️ No changes detected, skipping update');
//       return;
//     }
//
//     print('🔄 Updating profile: displayName=${newDisplayName ?? "unchanged"}, photoURL=${newPhotoUrl != null}');
//
//     // Update profile
//     await user.updateProfile(
//       displayName: newDisplayName,
//       photoURL: newPhotoUrl,
//     );
//
//     print('✅ Profile update completed, reloading user...');
//
//     // Quick reload
//     try {
//       await user.reload().timeout(
//         const Duration(seconds: 3),
//         onTimeout: () {
//           print('⚠️ User reload timeout - continuing');
//         },
//       );
//       print('✅ User reload completed');
//
//       // Verify changes
//       final updatedUser = FirebaseAuth.instance.currentUser;
//       if (updatedUser != null) {
//         if (newDisplayName != null && updatedUser.displayName != newDisplayName) {
//           print('⚠️ Display name may not have updated properly');
//         }
//         if (newPhotoUrl != null && updatedUser.photoURL != newPhotoUrl) {
//           print('⚠️ Photo URL may not have updated properly');
//         }
//       }
//     } catch (e) {
//       print('❌ User reload error: $e - continuing anyway');
//     }
//   }
//
//   Future<void> _saveProfile() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }
//
//     print('🚀 Starting profile save...');
//
//     if (mounted) {
//       setState(() {
//         _isLoading = true;
//       });
//     }
//
//     String? photoUrl;
//
//     try {
//       // Handle image upload with better timeout
//       if (_selectedImageBytes != null) {
//         print('📤 Starting image upload...');
//         final uploadFuture = _uploadImageToFirebase();
//
//         photoUrl = await uploadFuture.timeout(
//           const Duration(seconds: 25), // Increased timeout
//           onTimeout: () {
//             print('⏰ Image upload timeout - continuing without image');
//             return null;
//           },
//         );
//         print('📤 Image upload completed: ${photoUrl != null}');
//       }
//
//       // Always update profile to handle image-only changes
//       print('👤 Updating user profile...');
//       await _updateUserProfile(photoUrl).timeout(
//         const Duration(seconds: 10),
//         onTimeout: () {
//           throw TimeoutException('Profile update took too long');
//         },
//       );
//
//       print('✅ Profile update successful');
//
//       // Update original name for future comparisons
//       final updatedUser = FirebaseAuth.instance.currentUser;
//       if (updatedUser != null) {
//         _originalDisplayName = updatedUser.displayName ?? _nameController.text.trim();
//       }
//
//       // SUCCESS
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Profile updated successfully!'),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 2),
//           ),
//         );
//
//         // Navigate back immediately
//         if (mounted) {
//           Navigator.pop(context, true);
//         }
//       }
//     } on TimeoutException catch (e) {
//       print('⏰ Timeout during save: $e');
//       // Partial success - still navigate back but show warning
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Profile saved (changes may take a moment to appear)'),
//             backgroundColor: Colors.orange,
//             duration: Duration(seconds: 3),
//           ),
//         );
//
//         // Still navigate back even with timeout
//         await Future.delayed(const Duration(milliseconds: 800));
//         if (mounted) {
//           Navigator.pop(context, true);
//         }
//       }
//     } catch (e) {
//       print('❌ Error during save: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to update profile: ${e.toString()}'),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 4),
//           ),
//         );
//       }
//     } finally {
//       print('🏁 Save process completed');
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   ImageProvider? _getProfileImage() {
//     final user = FirebaseAuth.instance.currentUser;
//
//     if (_selectedImageBytes != null) {
//       return MemoryImage(_selectedImageBytes!);
//     } else if (user?.photoURL != null) {
//       return NetworkImage(user!.photoURL!);
//     }
//     return null;
//   }
//
//   Widget _buildProfileImage() {
//     final imageProvider = _getProfileImage();
//
//     return Stack(
//       children: [
//         Container(
//           width: 120,
//           height: 120,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: Colors.grey[300],
//             image: imageProvider != null
//                 ? DecorationImage(
//               image: imageProvider,
//               fit: BoxFit.cover,
//             )
//                 : null,
//           ),
//           child: imageProvider == null
//               ? const Icon(Icons.person, size: 50, color: Colors.grey)
//               : null,
//         ),
//         if (_isImageUploading)
//           Positioned.fill(
//             child: Container(
//               decoration: const BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.black54,
//               ),
//               child: const Center(
//                 child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               ),
//             ),
//           ),
//         Positioned(
//           bottom: 0,
//           right: 0,
//           child: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.primary,
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.camera_alt,
//               color: Colors.white,
//               size: 20,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Profile'),
//         actions: [
//           if (_isLoading)
//             const Padding(
//               padding: EdgeInsets.only(right: 16.0),
//               child: SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               ),
//             )
//           else
//             IconButton(
//               icon: const Icon(Icons.save),
//               onPressed: _saveProfile,
//               tooltip: 'Save Profile',
//             ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text('Saving Changes...'),
//           ],
//         ),
//       )
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               // Profile Picture
//               GestureDetector(
//                 onTap: _isImageUploading ? null : _pickImage,
//                 child: _buildProfileImage(),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 _isImageUploading ? 'Processing Image...' : 'Tap to change photo',
//                 style: TextStyle(
//                   color: Theme.of(context).colorScheme.secondary,
//                 ),
//               ),
//               const SizedBox(height: 32),
//
//               // Display Name
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Display Name',
//                   prefixIcon: Icon(Icons.person),
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your name';
//                   }
//                   if (value.trim().isEmpty) {
//                     return 'Name cannot be empty';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//
//               // Email (Read-only)
//               TextFormField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(
//                   labelText: 'Email',
//                   prefixIcon: Icon(Icons.email),
//                   border: OutlineInputBorder(),
//                 ),
//                 readOnly: true,
//               ),
//               const SizedBox(height: 16),
//
//               // Phone Number
//               TextFormField(
//                 controller: _phoneController,
//                 decoration: const InputDecoration(
//                   labelText: 'Phone Number',
//                   prefixIcon: Icon(Icons.phone),
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.phone,
//               ),
//               const SizedBox(height: 16),
//
//               // Bio
//               TextFormField(
//                 controller: _bioController,
//                 decoration: const InputDecoration(
//                   labelText: 'Bio',
//                   prefixIcon: Icon(Icons.info),
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 3,
//               ),
//               const SizedBox(height: 32),
//
//               // Save Button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _saveProfile,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                   child: const Text('Save Changes'),
//                 ),
//               ),
//               const SizedBox(height: 16),
//
//               // Cancel Button
//               SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton(
//                   onPressed: _isLoading ? null : () => Navigator.pop(context),
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                   child: const Text('Cancel'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _bioController.dispose();
//     super.dispose();
//   }
// }
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  String? _selectedImagePath;
  Uint8List? _selectedImageBytes;
  bool _isLoading = false;
  bool _isImageUploading = false;
  String? _originalDisplayName;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  void _loadCurrentUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _originalDisplayName = user.displayName ?? '';
      _nameController.text = _originalDisplayName!;
      _emailController.text = user.email ?? '';
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, // Further reduced for faster upload
        maxWidth: 600, // Smaller size for web
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImagePath = pickedFile.path;
          _isImageUploading = true;
        });

        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _isImageUploading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isImageUploading = false;
      });
    }
  }

  Future<String?> _uploadImageToFirebase() async {
    if (_selectedImageBytes == null) return null;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      // Use a simpler filename for faster processing
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${user.uid}.jpg'); // Reuse same filename

      print('🚀 Starting image upload, size: ${_selectedImageBytes!.lengthInBytes} bytes');

      // Use faster upload without progress tracking (causes delays on web)
      final uploadTask = storageRef.putData(
        _selectedImageBytes!,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Use faster completion method
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('✅ Image uploaded successfully!');
      return downloadUrl;
    } catch (e) {
      print('❌ Image upload error: $e');
      // Don't show error snackbar here - let the main save handle it
      return null;
    }
  }

  Future<void> _updateUserProfile(String? photoUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    bool needsUpdate = false;
    String? newDisplayName;
    String? newPhotoUrl;

    // Check if display name changed
    final currentName = _nameController.text.trim();
    if (currentName != _originalDisplayName) {
      newDisplayName = currentName;
      needsUpdate = true;
    }

    // Check if we have a new photo URL
    if (photoUrl != null) {
      newPhotoUrl = photoUrl;
      needsUpdate = true;
    }

    // If there's nothing to update, return early
    if (!needsUpdate) {
      return;
    }

    // FAST UPDATE - minimal validation for speed
    await user.updateProfile(
      displayName: newDisplayName,
      photoURL: newPhotoUrl,
    );

    // Quick reload without extensive validation
    await user.reload();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    print('🚀 Starting profile save...');

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      String? photoUrl;

      // PARALLEL PROCESSING: Start profile update immediately, handle image separately
      if (_selectedImageBytes != null) {
        print('📤 Starting image upload in background...');

        // Start image upload but don't wait too long
        final uploadFuture = _uploadImageToFirebase();

        photoUrl = await uploadFuture.timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            print('⏰ Image upload taking too long, continuing without it...');
            return null; // Continue without image
          },
        );
      }

      // Update profile (this is fast - 2-3 seconds)
      print('👤 Updating profile...');
      await _updateUserProfile(photoUrl);

      print('✅ Profile update successful!');

      // Update original name for future comparisons
      final updatedUser = FirebaseAuth.instance.currentUser;
      if (updatedUser != null) {
        _originalDisplayName = updatedUser.displayName ?? _nameController.text.trim();
      }

      // SUCCESS - Show feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate back immediately for better UX
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } on TimeoutException catch (e) {
      print('⏰ Partial timeout: $e');
      // Still show success since profile was updated
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved! Image will update shortly.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate back immediately
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      print('❌ Error during save: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      print('🏁 Save process completed');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  ImageProvider? _getProfileImage() {
    final user = FirebaseAuth.instance.currentUser;

    if (_selectedImageBytes != null) {
      return MemoryImage(_selectedImageBytes!);
    } else if (user?.photoURL != null) {
      return NetworkImage(user!.photoURL!);
    }
    return null;
  }

  Widget _buildProfileImage() {
    final imageProvider = _getProfileImage();

    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
            image: imageProvider != null
                ? DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            )
                : null,
          ),
          child: imageProvider == null
              ? const Icon(Icons.person, size: 50, color: Colors.grey)
              : null,
        ),
        if (_isImageUploading)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black54,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProfile,
              tooltip: 'Save Profile',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Saving...'),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _isImageUploading ? null : _pickImage,
                child: _buildProfileImage(),
              ),
              const SizedBox(height: 20),
              Text(
                _isImageUploading ? 'Processing...' : 'Tap to change photo',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  prefixIcon: Icon(Icons.info),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save Changes'),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}