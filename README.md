# M5 - Forecasting
Below is the competition link for problem statement and other details. Full datasets have to be downloaded from the data tab. Cureently, sample of datasets are present in the input folder.
https://www.kaggle.com/c/m5-forecasting-accuracy/ 

## Pipeline
In this repository, a pipeline is implemented for M5-forecasting competition. It does an end to end job from loading data to final submission file creation.

## Components
1. tsmodels.R: Time Series or ML models
2. evaluation_metrics.R: Metrics for forecast evaluation
3. train_test_split.R: Splitting of time series into train and test
4. bottom_up.R: Sales aggregation from level 12 to all higher levels.
5. top_down.R: Sales aggregation from level 1 to all lower levels. 

## Code flow
1. sales_agg.R: Time series of slaes values are created at all levels (1 to 12). These are then stored in the input dir.
2. feature_creation.R: Trend, seasonality, holiday and interaction features are created from calendars dataset. These features can be used for modeling in multivariate TS models.
3. pipeline_l12: This is bottom up aggregation pipeline. Forecasting is done at level 12 and then aggregated for all levels. Any time series model, evluation metric or aggregation methodology implemented as components can be used for forecasting.
4. pipeline_l1: This is top down aggregation pipeline. Forecasting is done at level 1 and then extrapolated for all levels. Same as the other pipeline, implemented components can be called here.

This framework allows us to experiment with different features, models, evaluation metrics or aggregation approaches in a parametric manner. These components can also be leveraged in other forecasting solutions.
