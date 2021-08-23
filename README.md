# IrisT Tutorial: Simple SPBC Model                                        
Build a simple sticky-price business-cycle model
(SPBC), calibrate the model and investigate its properties. Run a number of basic and more advanced experiments to
illustrate typical tasks in practical model development and operation.
The experiments include, for instance, steady-state comparative statics,
dynamic simulations, estimation, filtering of historical data, and
forecasting.


## Model source files

Model files can be opened and edited in the Matlab editor (or any other
plain text editor), but are not run themselves. They are read from
within Matlab programs (m-files).

* [[spbc.model]]



## Matlab scripts

Run the Matlap scripts in the following order:


* |<read_model>|                    - Create and Solve Model Object                                           
* get_info_about_model          - Get Information About Model Object
* change_parameters_and_sstates - Assign and Change Parameters and Steady States
* know_all_about_solution       - Model Solution Matrices
* play_with_bgp                 - Find and Describe Balanced Growth Path
* simulate_simple_shock         - Simulate Simple Shock Responses
* simulate_complex_shocks       - More Complex Simulation Experiments
* simulate_disinflation         - Simulate Permanent Change in Inflation Target
* resample_from_model           - Monte-Carlo Stochatic Simulations
* read_data                     - Import CSV Data Files and Prepare Data
* fisher_information_matrix     - Simulate Fisher Info Matrix and Test Parameter Identification
* estimate_params               - Run Bayesian Parameter Estimation
* more_on_poster_simulator      - Posterior Simulator with 'saveEvery=' Option
* filter_hist_data              - Kalman Filtering and Historical Simulations
* more_on_kalman_filter         - More on Kalman Filter
* forecasts_with_judgment       - Forecasts with Judgmental Adjustments
* compare_model_and_data        - Compare Second Moment Properties in Model and Data



*CSV Data Files*

The following CSV data files are read in from within other m-files:

  simple_SPBC_quarterly.csv     - Quarterly data from St Louis Fed FRED
  simple_SPBC_monthly.csv       - Monthly data from St Louis Fed FRED 
  simple_SPBC_daily.csv         - Daily data from St Louis Fed FRED

