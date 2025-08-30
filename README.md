# ML for Mortgage Prepayment Prediction

Code for Master's thesis: **"Machine Learning for Mortgage Prepayment Prediction: A Comparative Study of Ensemble Methods and Deep Learning in the French Market."**

This project tests whether advanced ML models (XGBoost, Random Forest, Neural Networks) can predict mortgage prepayment better than traditional Logistic Regression on French loan-level data.

## Repository Structure
├── Models/ # Main analysis notebooks
│ ├── Phase_1.ipynb
│ ├── Phase_2_Resampling.ipynb
│ ├── Phase_2_SHAP_Reduction.ipynb
│ └── Final_Model_Test.ipynb
├── data_cleaning/ # Script to clean raw data
│ └── ESMA_Data_Cleaning_Function.R
└── clean_data/ # The 5 cleaned datasets used in the study
├── d2011.csv
├── d2102.csv
├── d2105.csv
├── d2108.csv
└── d2111.csv


## Data

*   **Source:** Raw data from **ESMA Annex II** (not included here due to size).
*   **Processed Data:** The `cleaned_data` folder contains the five processed datasets used in this study. The notebooks automatically load these from a public Google Drive.

## The Analysis

1.  **Phase 1:** `Phase_1.ipynb`
    *   Compares Logistic Regression, Random Forest, XGBoost, and a Neural Network using 5-Fold CV and grid search.

2.  **Phase 2:**
    *   `Phase_2_Resampling.ipynb`: Tests advanced resampling (R-GAN for oversampling, Mahalanobis distance for undersampling) on XGBoost.
    *   `Phase_2_SHAP_Reduction.ipynb`: Tests feature reduction using SHAP values on XGBoost.

3.  **Final Test:** `Final_Model_Test.ipynb`
    *   Trains the final XGBoost model on the first four time periods and tests it on the last one (d2111).

## How to Run

1.  Open any notebook in Google Colab using the provided links.
2.  Run all cells. The code will install required packages and automatically download the data from Drive.
3.  No setup or manual downloads are needed.

## Dependencies

All required packages (e.g., `sklearn`, `xgboost`, `pytorch`, `shap`) are installed within the notebooks.
