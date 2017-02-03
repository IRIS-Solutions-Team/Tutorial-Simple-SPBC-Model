%% Kalman Filtering and Historical Simulations
% by Jaromir Benes
%
% Run the Kalman filter on the historical data to back out unobservable
% variables (such as the productivity process) and shocks, and perform a
% number of analytical exercises that help understand the inner workings of
% the model.

%% Clear Workspace
%
% Clear workspace, close all graphics figures, clear command window, and
% check the IRIS version.

clear;
close all;
clc;
irisrequired 20140315;
%#ok<*EVLC> 

%% Load Estimated Model Object and Historical Database
%
% Load the model object estimated in `estimate_params.m`, and the
% historical database created in `read_data`. Run `estimate_params` at
% least once before running this m-file.

load MAT/estimate_params.mat mest;
load MAT/read_data.mat d startHist endHist;

%% Run Kalman Filter
%
% The output data struct returned from the Kalman filter, `f`, consist by
% default of three sub-databases:
%
% * `mean` with point estimates of all model variables as tseries objects, 
% * `std` with std dev of those estimates as tseries objects, 
% * `mse` with the MSE matrix for backward-looking transition variables.
%
% Use the options `'output='`, `'meanOnly='`, `'returnStd='` and
% `'returnMse='` to control what is reported in the output data struct.

[~, f, v, ~, pe, co] = filter(mest, d, startHist:endHist+10);
    
%% Plot Estimated Shocks
%
% The measurement shocks are kept turned off in our exercises (i.e. their
% standard errors are zero), and hence their estimates are zero throughout
% the historical sample.

list = get(mest, 'elist');

dbplot(f.mean, startHist:endHist, list, ...
    'Tight=', true, 'ZeroLine=', true, 'Transform=', @(x) 100*x);
ftitle('Estimated shocks');

dbplot(f.mean, startHist:endHist, list, ...
    'Tight=', true, ...
    'ZeroLine=', true, ...
    'PlotFunc=', @hist, ...
    'Title=', get(mest, 'EDescript'), ...
    'Transform=', @(x) 100*x);

ftitle('Histograms of Estimated Transition Shocks');

%% K-Step-Ahead Kalman Predictions
%
% Re-run the Kalman filter requesting now also prediction step data (see
% the option `'output='`) extended to 5 quarters ahead (see the option
% `'ahead='`). Each row of the time series returned in the `.pred`
% sub-database contains t|t-1, t|t-2, ..., t|t-k predictions.
%
% Because of the option `'meanOnly=' true` <?meanOnly?>, the filter output
% struct, `g`, only containes mean databases directly under `.pred` and
% `.smooth`, and no subdatabases `.mean` are created <?nomeansubdb?>.
%
% Use the function `plotpred` <?plotpred?> to organise and plot the data in
% a user-convenient way.

k = 8;

[~, g] = filter(mest, d, startHist:endHist, ...
    'Output=', 'Pred, Smooth', 'MeanOnly=', true, 'Ahead=', k); %?meanOnly?

g %#ok<NOPTS>
g.pred %?nomeansubdb?
g.smooth

figure();
[h1, h2] = plotpred(startHist:endHist, d.Short, g.pred.Short); %?plotpred?
set(h1, 'Marker', '.');
set(h2, 'LineStyle', ':', 'LineWidth', 1.5);
grid on;
title('Short Rates: 1- to 5-Qtr-Ahead Kalman Predictions');

%% Resimulate Filtered Data
%
% This is to illustrate that running a simulation with the initial
% conditions and shocks estimated by the Kalman filter exactly reproduces
% the historical paths of the observables.

s = simulate(mest, f.mean, startHist:endHist, 'Anticipate=', false);

dbfun(@(x, y) max(abs(x-y)), f.mean, s)

%% Run Counterfactual
%
% Remove the cost-push shocks from the filtered database, and re-simulate
% the historical data. This experiment shows what the data would have
% looked like if inflation had been determeined exactly by the Phillips
% curve without any cost-push shocks.

f1 = f.mean;
f1.Ep(:) = 0;

s1 = simulate(mest, f1, startHist:endHist, 'Anticipate=', false);

figure();
plot([s.Infl, s1.Infl]);
grid on;
title('Inflation, Q/Q PA');
legend('Actual Data', 'Counterfactual without Cost Push Shocks');

%% Simulate Contributions of Shocks
%
% Re-simulate the filtered data with the `'contributions='` option set to
% true. This returns each variable as a multivariate time series with $n+1$
% columns, where $n$ is the number of model shocks. The first $n$ columns
% are contributions of individual shocks (in order of their appearance in
% the `!transition_shocks` declaration block in the model file), the last, 
% $n+1$-th column is the contribution of the initial condition and/or the
% deterministic drift.

c = simulate(mest, s, startHist:endHist+8, ...
    'Anticipate=', false, 'Contributions=', true, 'AppendPresample=', true);

c %#ok<NOPTS>
c.Infl

% ...
%
% To plot the shock contributions, use the function `conbar`. Plot first
% the actual data and the effect of the initial condition and deterministic
% constant (i.e. the last, $n+1$-th column in the database `c`) in the
% upper panel, and then the contributions of individual shocks, i.e. the
% first $n$ columns.

figure();

subplot(2, 1, 1);
plot(startHist:endHist, [s.Infl, c.Infl{:, end}]);
grid on;
title('Inflation, Q/Q PA');
legend('Actual data', 'Steady State + Init Cond', ...
    'location', 'northWest');

subplot(2, 1, 2);
barcon(startHist:endHist, c.Infl{:, 1:end-2});
grid on;
title('Contributions of shocks');

edescript = get(mest, 'EDescript');
legend(edescript{:}, 'Location', 'NorthWest');

%% Plot Grouped Contributions
%
% Use a `grouping` object to define groups of shocks whose contributions
% will be added together and plotted as one category. Run `eval` to create
% a new database with the contributions grouped accordingly <?groupeval?>.
% Otherwise, the information content of this figure window is the same as
% the previous one.

g = grouping(mest, 'Shock');
g = addgroup(g, 'Measurement', 'M.*');
g = addgroup(g, 'Demand', 'Ey, Er');
g = addgroup(g, 'Supply', 'Ep, Ea, Ew');

detail(g);

[cg, lg] = eval(g, c); %?groupeval?

figure( );

subplot(2, 1, 1);
plot(startHist:endHist, [s.Infl, c.Infl{:, end-1}]);
grid on;
title('Inflation, Q/Q PA');
legend('Actual Data', 'Steady state + Init Cond', ...
    'Location', 'NorthWest');

subplot(2, 1, 2);
conbar(cg.Infl{:, 1:end-1});
grid on;
title('Contributions of Shocks');
legend(lg(:, 1:end-1), 'Location', 'NorthWest');

%% Save Output Data for Future Use
%
% Save the output database `f` from the basic run of the filter in a
% mat-file (binary file) for future use.

save MAT/filter_hist_data.mat f;

%% Help on IRIS Functions Used in This Files
%
% Use either `help` to display help in the command window, or `idoc`
% to display help in an HTML browser window.
%
%    help model/filter
%    help model/simulate
%    help tseries/conbar
%    help tseries/plotpred
%    help grfun/movetosubplot
%    help data/dbfun
