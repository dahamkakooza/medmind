# Requirements Document

## Introduction

This specification defines the requirements for integrating a machine learning linear regression feature into the existing MedMind application. The feature will include building regression models for medication adherence prediction, deploying them via a FastAPI service, and adding a prediction page to the existing Flutter app. This integration leverages the existing MedMind infrastructure while meeting all assignment requirements.

## Glossary

- **Linear Regression Model**: A machine learning model that predicts continuous values using linear relationships between features
- **Decision Tree Model**: A tree-based model that makes predictions by learning decision rules from features
- **Random Forest Model**: An ensemble model that combines multiple decision trees for improved predictions
- **FastAPI Service**: A Python web framework for building APIs with automatic documentation
- **Pydantic Model**: A data validation library that enforces data types and constraints
- **Swagger UI**: An interactive API documentation interface
- **Flutter App**: A mobile application built with Flutter framework
- **Gradient Descent**: An optimization algorithm used to minimize the loss function
- **Feature Engineering**: The process of selecting, transforming, and creating features for model training
- **CORS Middleware**: Cross-Origin Resource Sharing configuration that allows API access from different domains
- **Loss Curve**: A plot showing how model error changes during training

## Requirements

### Requirement 1: Dataset Selection and Preparation

**User Story:** As a data scientist, I want to select and prepare a medication adherence regression dataset, so that I can predict adherence rates and integrate predictions into MedMind.

#### Acceptance Criteria

1. WHEN selecting a dataset THEN the system SHALL use a healthcare/medication-related regression dataset that is NOT house price prediction
2. WHEN selecting a dataset THEN the system SHALL ensure the dataset has sufficient volume and variety for regression analysis
3. WHEN documenting the dataset THEN the system SHALL include a brief description and source in the README
4. WHEN the dataset is loaded THEN the system SHALL identify all features and the target variable for regression
5. WHEN selecting a use case THEN the system SHALL align with MedMind's mission of medication adherence tracking

### Requirement 2: Data Visualization and Analysis

**User Story:** As a data scientist, I want to visualize and analyze the dataset, so that I can understand feature relationships and make informed decisions about feature engineering.

#### Acceptance Criteria

1. WHEN analyzing the dataset THEN the system SHALL create a correlation heatmap showing relationships between features
2. WHEN analyzing the dataset THEN the system SHALL create distribution visualizations for key variables
3. WHEN performing feature engineering THEN the system SHALL identify and document which columns to drop based on analysis
4. WHEN performing feature engineering THEN the system SHALL identify which features hold more weight for prediction
5. WHEN preparing data THEN the system SHALL convert all categorical data to numeric format
6. WHEN preparing data THEN the system SHALL standardize all numeric features

### Requirement 3: Model Training and Evaluation

**User Story:** As a data scientist, I want to train multiple regression models and compare their performance, so that I can select the best model for deployment.

#### Acceptance Criteria

1. WHEN training models THEN the system SHALL create a Linear Regression model using gradient descent
2. WHEN training models THEN the system SHALL create a Decision Tree model
3. WHEN training models THEN the system SHALL create a Random Forest model
4. WHEN evaluating models THEN the system SHALL plot loss curves for both training and test data
5. WHEN visualizing the Linear Regression model THEN the system SHALL create a scatter plot showing the fitted line through the data
6. WHEN comparing models THEN the system SHALL save the model with the lowest loss metric
7. WHEN the best model is saved THEN the system SHALL create a prediction function that accepts one data point and returns a prediction

### Requirement 4: API Development

**User Story:** As a developer, I want to create a FastAPI service that serves model predictions, so that the model can be accessed by client applications.

#### Acceptance Criteria

1. WHEN creating the API THEN the system SHALL implement a POST endpoint for prediction requests
2. WHEN configuring the API THEN the system SHALL add CORS middleware to allow cross-origin requests
3. WHEN defining input data THEN the system SHALL use Pydantic BaseModel to enforce data types for each input variable
4. WHEN defining input data THEN the system SHALL use Pydantic to define acceptable range constraints for numeric inputs
5. WHEN the API is deployed THEN the system SHALL provide a publicly accessible URL with Swagger UI documentation
6. WHEN deploying the API THEN the system SHALL include a requirements.txt file with all dependencies

### Requirement 5: Flutter Mobile Application

**User Story:** As a mobile user, I want to use a Flutter app to input data and receive predictions from the API, so that I can easily access the model's predictions.

#### Acceptance Criteria

1. WHEN the app loads THEN the system SHALL display a single prediction page with all necessary input fields
2. WHEN displaying input fields THEN the system SHALL provide text fields equal to the number of variables needed for prediction
3. WHEN the user completes input THEN the system SHALL provide a "Predict" button to submit the request
4. WHEN displaying results THEN the system SHALL show the predicted value or error messages in a dedicated display area
5. WHEN the API returns validation errors THEN the system SHALL display appropriate error messages for out-of-range or missing values
6. WHEN arranging UI elements THEN the system SHALL ensure all elements are properly organized without overlapping

### Requirement 6: Documentation and Demonstration

**User Story:** As a reviewer, I want comprehensive documentation and a video demonstration, so that I can understand the complete solution and verify its functionality.

#### Acceptance Criteria

1. WHEN creating the README THEN the system SHALL include a mission description of at most 4 lines
2. WHEN documenting the API THEN the system SHALL provide the publicly available API endpoint URL
3. WHEN creating the video demo THEN the system SHALL demonstrate the mobile app making predictions within 5 minutes
4. WHEN creating the video demo THEN the system SHALL demonstrate Swagger UI tests including datatype and range validation
5. WHEN creating the video demo THEN the system SHALL show the Flutter code where the API call is made
6. WHEN creating the video demo THEN the system SHALL explain model performance using loss metrics
7. WHEN creating the video demo THEN the system SHALL justify model selection based on dataset and problem context
8. WHEN creating the video demo THEN the system SHALL show the notebook with model creation code

### Requirement 7: Project Structure and Organization

**User Story:** As a developer, I want a well-organized project structure, so that all components are easy to locate and understand.

#### Acceptance Criteria

1. WHEN organizing the project THEN the system SHALL create a linear_regression_model/summative/ directory structure
2. WHEN organizing the project THEN the system SHALL place the notebook in linear_regression/multivariate.ipynb
3. WHEN organizing the project THEN the system SHALL place API files in API/ directory with prediction.py and requirements.txt
4. WHEN organizing the project THEN the system SHALL place Flutter app files in FlutterApp/ directory
5. WHEN submitting the project THEN the system SHALL provide clear instructions on how to run the mobile app
