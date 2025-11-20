import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/scan_barcode.dart';
import '../../../../../core/usecases/usecase.dart';
import 'barcode_event.dart';
import 'barcode_state.dart';

class BarcodeBloc extends Bloc<BarcodeEvent, BarcodeState> {
  final ScanBarcode scanBarcode;

  BarcodeBloc({required this.scanBarcode}) : super(BarcodeInitial()) {
    on<StartBarcodeScan>(_onStartBarcodeScan);
    on<StopBarcodeScan>(_onStopBarcodeScan);
    on<BarcodeDetected>(_onBarcodeDetected);
  }

  Future<void> _onStartBarcodeScan(
    StartBarcodeScan event,
    Emitter<BarcodeState> emit,
  ) async {
    emit(BarcodeScanLoading());
    final result = await scanBarcode(NoParams());
    result.fold(
      (failure) => emit(const BarcodeScanError(message: 'Failed to scan barcode')),
      (medicationName) => emit(BarcodeScanned(
        medicationName: medicationName,
        barcode: 'scanned_code',
      )),
    );
  }

  void _onStopBarcodeScan(
    StopBarcodeScan event,
    Emitter<BarcodeState> emit,
  ) {
    emit(BarcodeInitial());
  }

  void _onBarcodeDetected(
    BarcodeDetected event,
    Emitter<BarcodeState> emit,
  ) {
    emit(BarcodeScanned(
      medicationName: 'Detected Medication',
      barcode: event.barcode,
    ));
  }
}