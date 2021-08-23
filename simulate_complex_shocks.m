%% More Complex Simulation Experiments
%
% Simulate the differences between anticipated and unanticipated future
% shocks, run experiments with temporarily exogenized variables, and show
% how easy it is to examine simulations with mutliple different
% parameterisations.
%


%% Clear Workspace
%
% Clear workspace, close all graphics figures.
%

close all
clear


%% Load Solved Model Object
%
% Load the solved model object built in `read_model`.
%

load mat/read_model.mat m


%% Define Dates and Ranges

startDate = 1;
endDate = 40;
plotRng = startDate-1 : startDate+19;


%% Simple Consumption Demand Shock

d = zerodb(m, startDate-3:startDate);
d.Ey(startDate) = 0.07;
s = simulate(m, d, 1:40, 'Deviation=', true, 'PrependInput=', true);

plotList = { ...
    ' "Inflation, Q/Q PA [Pp Dev]" dP^4 '
	' "Policy rate, PA [Pp Dev]" R^4 '
    ' "Output [Pct Level Dev]" Y '
    ' "Hours Worked [Pct Level Dev]" N '
    ' "Real Wage [Pct Level Dev]" W/P '
    ' "Capital Price [Pct Level Dev]" Pk'
};
[ff, aa] = dbplot(s, plotRng, plotList, 'Tight=', true, 'Round=', 8); % , 'Transform=', @(x) 100*(x-1));
visual.heading('Consumption Demand Shocks');


%% Anticipated vs Unanticipated Consumption Demand Shock
%
% Simulate a future (3 quarters ahead) aggregate demand shock twice: as
% anticipated and unanticipated.
%

d = zerodb(m, startDate-3:startDate);
d.Ey(startDate+3) = 0.07;
s1 = simulate( ...
    m, d, startDate:endDate, ...
    'Anticipate=', true, ...
    'Deviation=', true, ...
    'PrependInput=', true ...
);

s2 = simulate( ...
    m, d, startDate:endDate, ...
    'Anticipate=', false, ...
    'Deviation=', true, ...
    'PrependInput=', true ...
);

dbplot( ...
    s1 & s2, plotRng, plotList, ...
    'Tight=', true, ...
    'Transform=', @(x) 100*(x-1) ...
);
visual.heading('Consumption Demand Shock: Anticipated vs Unanticipated');
visual.hlegend('Bottom', 'Anticipated', 'Unanticipated');


%% Simulate Consumption Demand Shock with Delayed Policy Reaction
%
% Simulate a consumption shock and, at the same time, delay the policy
% reaction (by exogenising the policy rate to its pre-shock level for 3
% periods). This can be done in an anticipated mode and
% unanticipated mode.
%
% # Simulate consumption shocks with immediate policy reaction.
% # Simulate the same shock with delayed policy reaction that is announced
% and anticipated from the beginning.
% # Simulate the same shock with delayed policy reaction that takes
% everyone by surprize every quarter.

nPer = 3;
d = zerodb(m, startDate-3:startDate);
d.Ey(startDate) = 0.07;

p = Plan(m, startDate:endDate);
p = exogenize(p, startDate:startDate+nPer-1, 'R');
p = endogenize(p, startDate:startDate+nPer-1, 'Er');
d.R(startDate:startDate+nPer-1) = 1;

s1 = simulate( ...
    m, d, startDate:endDate, ... 
   'Deviation=', true, 'PrependInput=', true ...
);

s2 = simulate( ...
    m, d, startDate:endDate, ...
    'Plan=', p, ... 
    'Deviation=', true, ...
    'PrependInput=', true ...
);


p = Plan(m, startDate:endDate, 'Anticipate=', false);
p = exogenize(p, startDate:startDate+nPer-1, 'R');
p = endogenize(p, startDate:startDate+nPer-1, 'Er');
s3 = simulate( ...
    m, d, startDate:endDate, ...
    'Plan=', p, ... 
    'Deviation=', true, ...
    'PrependInput=', true ...
);


dbplot( ...
    s1 & s2 & s3, plotRng, plotList, ...
    'Tight=', true, 'Transform=', @(x) 100*(x-1) ...
);
visual.heading('Consumption Demand Shock with Delayed Policy Reaction');
visual.hlegend('Bottom', 'No delay', 'Anticipated', 'Unanticipated');


%% Simulate Consumption Demand Shock with Desired Impact
%
% Find the size of a consumption demand shock such that it leads to exactly
% a 1 pct increase in consumption in the first period. Because consumption
% (C) is a log-linearized variable, specify the 1 pct deviation from its
% steady state as 1.01.

d = zerodb(m, startDate-3:startDate);
d.Y(startDate) = 1.01;

p = Plan(m, startDate:endDate);
p = exogenize(p, startDate, 'Y');
p = endogenize(p, startDate, 'Ey');

s = simulate(...
    m, d, startDate:endDate, ...
    'Plan=', p, ...
    'Deviation=', true, ...
    'PrependInput=', true ...
);

disp(s.Ey{1:10});

dbplot(s, plotRng, plotList, 'Tight=', true, 'Transform=', @(x) 100*(x-1));
visual.heading('Consumption Demand Shock with Exact Impact');


%% Simulate Consumption Demand Shocks with Multiple Parameterisations
%
% Within the same model object, expand the number of parameter variants, 
% and assign different sets of values to some (or all) of the parameters
% (here, only the values for the parameter `xip` vary, i.e. the price
% adjustment costs).  Solve and simulate all parameter variants at once.
% Almost all IRIS model functions support multiple parametert variants.
%

m = alter(m, 8);
m.xip = [140, 160, 180, 200, 220, 240, 260, 280];
m = solve(m);
disp(m);

d = zerodb(m, startDate-3:startDate);
d.Ey(1, :) = 0.07;

s = simulate( ...
    m, d, startDate:endDate, ...
    'Deviation=', true, ...
    'PrependInput=', true ...
);

dbplot(s, plotRng, plotList, 'Tight=', true, 'Transform=', @(x) 100*(x-1));
visual.heading('Consumption Demand Shock with Mutliple Parameter Variants');


