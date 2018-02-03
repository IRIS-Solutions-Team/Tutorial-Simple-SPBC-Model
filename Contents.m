%% Simple SPBC Model                                                       
%
% This tutorial builds a simple sticky-price business-cycle model (SPBC),
% and runs a number of basic and more advanced experiments to illustrate
% typical tasks in practical model development and operation.
%
% Runs in IRIS Release 20180131.
%
%
%% Model Files                                                             
%
% Open and inspect the model file:
%
%   simple_SPBC.model
%
% Model files are not to be run themselves; they are read in from within
% other m-files.
%
%
%% M-Files (Matlab Programs)                                               
%
% Open and run the m-files in the following order:
%
%   read_model                    - Create and Solve Model Object                                           
%   get_info_about_model          - Get Information About Model Object
%   change_parameters_and_sstates - Assign and Change Parameters and Steady States
%   know_all_about_solution       - Model Solution Matrices
%   play_with_bgp                 - Find and Describe Balanced Growth Path
%   simulate_simple_shock         - Simulate Simple Shock Responses
%   simulate_complex_shocks       - More Complex Simulation Experiments
%   simulate_disinflation         - Simulate Permanent Change in Inflation Target
%   resample_from_model           - Monte-Carlo Stochatic Simulations
%   read_data                     - Import CSV Data Files and Prepare Data
%   fisher_information_matrix     - Simulate Fisher Info Matrix and Test Parameter Identification
%   estimate_params               - Run Bayesian Parameter Estimation
%   more_on_poster_simulator      - Posterior Simulator with 'saveEvery=' Option
%   filter_hist_data              - Kalman Filtering and Historical Simulations
%   more_on_kalman_filter         - More on Kalman Filter
%   forecasts_with_judgment       - Forecasts with Judgmental Adjustments
%   compare_model_and_data        - Compare Second Moment Properties in Model and Data
%
%
%% Data Files                                                              
%
% The following CSV data files are read in from within other m-files:
%
%   simple_SPBC_quarterly.csv
%   simple_SPBC_monthly.csv
%   simple_SPBC_daily.csv
%

% Copyright (c) 2007-2018 IRIS Solutions Team

%{
delete('html-source/*');
publish.model('simple_SPBC.model');
publish.mfile('read_model.m');
publish.mfile('get_info_about_model.m');
publish.mfile('change_parameters_and_sstates.m');
publish.mfile('know_all_about_solution.m');
publish.mfile('play_with_bgp.m');
publish.mfile('simulate_simple_shock.m');
publish.mfile('simulate_complex_shocks.m');
publish.mfile('simulate_disinflation.m');
publish.mfile('resample_from_model.m');
publish.mfile('read_data.m');
publish.mfile('fisher_information_matrix.m');
publish.mfile('estimate_params.m');
publish.mfile('more_on_poster_simulator.m');
publish.mfile('filter_hist_data.m');
publish.mfile('more_on_kalman_filter.m');
publish.mfile('forecasts_with_judgment.m');
publish.mfile('compare_model_and_data.m');
%}

