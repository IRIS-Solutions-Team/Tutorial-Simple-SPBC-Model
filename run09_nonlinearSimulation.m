%% Nonlinear simulations
%
% Illustrate the use of nonlinear simulation methods. By default, IrisT
% uses a first-order approximate solution to run the `simulate()` function.
% There are two nonlinear simulation methods available:
%
% * a stacked-time method (solving the model as a large system of nonlinear
% equations stacked in time) with a first-order terminal condition;
%
% * a period-by-period method meant for special use cases where a total
% control about forward-looking expectations is needed.
%


%% Clear workspace

close all
clear
%#ok<*VUNUS>

load mat/createModel.mat m


%% Prepare input databank with unanticipated demand and supply shocks

startDate = 1;
endDate = startDate + 19;

d = steadydb(m, startDate:endDate);
d.Ey(1:2) = -0.05;
d.Ep(1:3) = -0.05;


%% Run first-order simulation

s1 = simulate( ...
    m, d, startDate:endDate ...
    , "plan", false ...
);


%% Run nonlinear stacked-time simulation with first-order terminal condition

s2 = simulate( ...
    m, d, startDate:endDate ...
    , "method", "stacked" ...
    , "plan", false ...
);


%% Run nonlinear period-by-period simulations with fixed-data terminal condition

s3 = simulate( ...
    m, d, startDate:endDate ...
    , "method", "period" ...
    , "terminal", "data" ...
    , "plan", false ...
);


%% Compare results 

ch = databank.Chartpack();
ch.Range = startDate-1 : startDate+19;
ch.Transform = @(x) 100*(x-1);
ch.Round = 8;

ch < "Inflation, Q/Q PA // Pp Deviations: dP^4 ";  
ch < "Policy rate, PA // Pp Deviations: R^4 ";
ch < "Output // Pct Level Deviations: Y ";
ch < "Hours Worked // Pct Level Deviations: N ";
ch < "Real Wage // Pct Level Deviations: W/P ";
ch < "Capital Price // Pct Level Deviations: Pk"; 

tempDb = databank.merge("horzcat", s1, s2, s3);
draw(ch, tempDb);

visual.hlegend( ...
    "bottom" ...
    , "First order" ...
    , "Nonlinear stacked time" ...
    , "Period by period with fixed expectations" ...
);

