%% Simulate Simple Shock Responses
%
% Simulate a simple shock both as deviations from control and in full
% levels, and report the simulation results.

%% Clear Workspace
%
% Clear workspace, close all graphics figures, clear command window, and
% check the IRIS version.

clear
close all
clc
irisrequired 20180131

%% Load Solved Model Object
%
% Load the solved model object built in <read_model.html read_model>. Run
% |read_model| at least once before running this m-file.

load mat/read_model.mat m;

%% Define Dates
%
% Define the start and end dates as plain numbered periods here.

startDate = 1;
endDate = 40;

%%%
%
% Alternatively, use the IRIS functions |yy( )|, |hh( )|, |qq( )|, or |mm(
% )| to create and use proper dates (with yearly, half-yearly, quarterly,
% or monthly frequency, respectively). For instance,
%
%    startdate = qq(2010,1);
%    enddate = startdate + 39;
%

%% Simulate Consumption Demand Shock
%
% Simulate the shock as deviations from control (e.g. from the steady state
% or balanced-growth path). To this end, set the option |Deviation=true|.
% Both the input and output database are then interpreted as deviations
% from control:
%
% * the deviations for linearised variables are defined as 
% $x_t - x_t$: 
% hence, 0 means the variable is on its steady state.
% * the deviations for log-linearised variables are defined as 
% $x_t / \bar x_t$: 
% hence, 1 means the variable is on its steady state, or 1.05 means
% it is 5 % above it.
%
% The function |zerodb( )| finds the maximum lag in the model, and creates
% the input database accordingly so that it includes all necessary initial
% conditions.

d = zerodb(m, startDate:endDate);
d.Ey(startDate) = log(1.01);
s = simulate(m, d, 1:40, 'Deviation=', true, 'AppendPresample=', true);
display(s);

%% Report Simulation Results
%
% Use the |dbplot( )| function to create a quick report of simulation
% results.  Note how we use the |Transform=| option to plot percent
% deviations of individual variables.

plotRng = startDate-1 : startDate+15;
plotList = { ...
    ' "Inflation, Q/Q PA [Pp Dev]" dP^4 ', ...
	' "Policy rate, PA [Pp Dev]" R^4 ', ...
    ' "Output [Pct Level Dev]" Y ', ...
    ' "Hours Worked [Pct Level Dev]" N ', ...
    ' "Real Wage [Pct Level Dev]" W/P ', ...
    ' "Capital Price [Pct Level Dev]" Pk', ...
   };
dbplot(s, plotRng, plotList, ...
   'Tight=', true, 'Transform=', @(x) 100*(x-1)); 
grfun.ftitle('Consumption Demand Shock -- Deviations from Control');

%% Simulate Shock in Full Levels
%
% Instead of deviations from control, simulate now the same shocks in full
% levels. To that end, create an input dabase with the steady state
% (balanced-growth path) using |sstatedb( )|, and keep the option
% |Deviation=false| (default). When reporting the results, plot both the
% simulated shock against the steady-state (balanced-growth path) database:
% The |&| operator combines two databases so that every time series
% has two columns.

d = sstatedb(m, startDate:endDate);
d.Ey(startDate) = log(1.01);
s = simulate(m, d, 1:40, 'AppendPresample=', true);
 
dbplot(d & s,plotRng,plotList, ... 
   'Tight=', true, 'Transform=', @(x) 100*(x-1));
grfun.ftitle('Consumption Demand Shock -- Full Levels');


%% Show Variables and Objects Created in This File                         

whos

