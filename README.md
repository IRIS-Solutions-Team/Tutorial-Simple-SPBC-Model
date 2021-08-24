# IrisT Tutorial: Simple SPBC Model

Build a simple sticky-price business-cycle model (SPBC), calibrate the
model and investigate its properties. Run a number of basic and more
advanced experiments to illustrate typical tasks in practical model
development and operation. The experiments include, for instance,
steady-state comparative statics, dynamic simulations, estimation,
filtering of historical data, and forecasting scenarios.


## Model source files

Model source files can be opened and edited in the Matlab editor (or any
other plain text editor), but are not run themselves. They are read from
within Matlab programs.

* [`spbc.model`](spbc.model)


## Matlab scripts

Run the Matlap scripts in the following order:

* [`run01_createModel`](run01_createModel.m)
* [`run02_aboutModel`](run02_aboutModel.m)
* [`run03_modifyParameters`](run03_modifyParameters.m)
* [`run04_aboutSolution`](run04_aboutSolution.m)
* [`run05_playWithGrowthPath`](run05_playWithGrowthPath.m)
* [`run06_simulatePlainVanillaShock`](run06_simulatePlainVanillaShock.m)
* [`run07_simulateComplexShocks`](run07_simulateComplexShocks.m)
* [`run08_simulateDisinflation.m`](run08_simulateDisinflation.m)
* [`run09_nonlinearSimulation`](run09_nonlinearSimulation.m)
* [`run10_resampleFromModel`](run10_resampleFromModel.m)
* [`run11_prepareDataFromFred`](run11_prepareDataFromFred.m)
* [`run12_fisherInfoMatrix`](run12_fisherInfoMatrix.m)
* [`run13_estimateParams`](run13_estimateParams.m)
* [`run14_morePosterSimulator`](run14_morePosterSimulator.m)
* [`run15_filterHistData`](run15_filterHistData.m)
* [`run16_moreKalmanFilter`](run16_moreKalmanFilter.m)
* [`run17_createForecastScenarios`](run17_createForecastScenarios.m)
* [`run18_modelVersusData.m`](run18_modelVersusData.m)


## Data files

The following CSV data files are read in from within other m-files:

* [`fred-quarterly.csv`](fred-quarterly.csv)
* [`fred-monthly.csv`](fred-monthly.csv)

