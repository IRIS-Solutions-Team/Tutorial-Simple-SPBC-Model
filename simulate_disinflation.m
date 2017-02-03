%% Simulate Permanent Change in Inflation Target
% by Jaromir Benes
%
% Simulate a permanent change in the inflation target, calculate the
% sacrifice ratio, and run a simple parameter sensitivity exercise using
% model objects with multiple parameterizations.

%% Clear Workspace
%
% Clear workspace, close all graphics figures, clear command window, and
% check the IRIS version.

clear;
close all;
clc;
irisrequired 20140315;
%#ok<*NASGU>
%#ok<*NOPTS>
 
%% Load Solved Model Object
%
% Load the solved model object built in `read_model`; run `read_model` at
% least once before running this m-file.

load MAT/read_model.mat m;

%% Define dates

startDate = qq(2009, 2);
endDate = startDate + 39;
plotRng = startDate-5 : startDate+19;

%% Create Model with Higher Steady State Inflation
%
% Set the steady-state rate of inflation to 3 pct, and solve for the new
% steady state of nominal variables. Real variables remain unchanged, so
% they can be fixed here.

m1 = m;
m1.pi = 1.035^(1/4);
m1 = sstate(m1, ...
    'Solver=', 'IRIS', ...
    'Fix=', {'Y', 'N', 'A', 'RMC', 'Growth'}, 'Growth=', true);
chksstate(m1, 'Equations=', 'Steady');
chksstate(m1, 'Equations=', 'Dynamic');
m1 = solve(m1);
display(m1);

ss = get(m, 'SteadyLevel');
ss1 = get(m1, 'SteadyLevel');
ss & ss1

%% Simulate Disinflation
%
% Simulate the low-inflation model, `m`, starting from the steady state of
% the high-inflation model, `m1`.

d1 = sstatedb(m1, startDate-3:endDate);
s = simulate(m, d1, startDate:endDate, 'AppendPresample=', true);
s = dbminuscontrol(m, s, d1);

plotList = { ...
    ' "Inflation, Q/Q PA [Pp Dev]" dP^4 ', ...
	' "Policy rate, PA [Pp Dev]" R^4 ', ...
    ' "Output [Pct Level Dev]" Y ', ...
    ' "Hours Worked [Pct Level Dev]" N ', ...
    ' "Real Wage [Pct Level Dev]" W/P ', ...
    ' "Capital Price [Pct Level Dev]" Pk', ...
   };
dbplot(s, plotRng, plotList, ...
   'Tight=', true, 'Highlight=', startDate-5:startDate-1, ...
   'Transform=', @(x) 100*(x-1));
grfun.ftitle('Disinflation');

%% Sacrifice Ratio
%
% Sacrifice ratio is the cumulative output loss after a 1% PA disinflation.
% Divide by 4 to get an annualised figure (reported in the literature).

sacRat = -cumsum(100*(s.Y-1))/4

%% Change Price and Wage Stickiness and Compare to Baseline
%
% Create a model object with 8 parameterisations, and assign a range of
% values to the price stickiness parameter.

m(1:8) = m;
m.xip = [60, 80, 100, 120, 140, 160, 180, 200];
m = solve(m);
display(m);

s = simulate(m, d1, startDate:endDate, 'AppendPresample=', true);
s = dbminuscontrol(m, s, d1);

dbplot(s, plotRng, plotList, 'Tight=', true, 'Transform=', @(x) 100*(x-1));
grfun.ftitle('Disinflation with More Flexible Prices');

disp('Cumulative output gap (sacrifice ratio):');
sacRat = -cumsum(100*(s.Y-1))/4;

figure( );
plot(sacRat);
grid('on');
title('Sacrifice ratio');
legend('\xi_p=60', '\xi_p=80', '\xi_p=100', '\xi_p=120', ...
   '\xi_p=140', '\xi_p=160', '\xi_p=180', '\xi_p=200', ...
   'location', 'northWest');
sacRat{startDate:endDate}

%% Help on IRIS Functions Used in This File
%
% Use either `help` to display help in the command window, or `idoc`
% to display help in an HTML browser window.
%
%    help model/subsasgn
%    help model/solve
%    help model/sstate
%    help model/sstatedb
%    help model/simulate
%    help dbase/dbplot
%    help dbase/dboverlay
    
