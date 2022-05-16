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

load mat/createModel.mat m
load mat/estimateParams.mat mest

m = mest;
checkSteady(m);
m = solve(m);

%% Define Dates and Ranges

startDate = 1;
endDate = 40;
plotRng = startDate-1 : startDate+19;


%% Simple Consumption Demand Shock

d = zerodb(m, startDate-3:startDate);
d.Ey(startDate) = 0.07;
s = simulate(m, d, 1:40, "Deviation", true, "PrependInput", true);

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

draw(ch, s);
visual.heading("Plain vanila consumption demand shock");


%% Anticipated vs Unanticipated Consumption Demand Shock
%
% Simulate a future (3 quarters ahead) aggregate demand shock twice: as
% anticipated and unanticipated.
%

d = zerodb(m, startDate-3:startDate);
d.Ey(startDate+3) = 0.07;
s1 = simulate( ...
    m, d, startDate:endDate, ...
    "Anticipate", true, ...
    "Deviation", true, ...
    "PrependInput", true ...
);

s2 = simulate( ...
    m, d, startDate:endDate, ...
    "Anticipate", false, ...
    "Deviation", true, ...
    "PrependInput", true ...
);

tempDb = databank.merge("horzcat", s1, s2);
draw(ch, tempDb);

visual.heading("Consumption demand shock: Anticipated vs Unanticipated");
visual.hlegend("bottom", "Anticipated", "Unanticipated");


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

T = 3;
d = zerodb(m, startDate-3:startDate);
d.Ey(startDate) = 0.07;

p = Plan.forModel(m, startDate:endDate);
p = exogenize(p, startDate:startDate+T-1, "R");
p = endogenize(p, startDate:startDate+T-1, "Er");
d.R(startDate:startDate+T-1) = 1;

s1 = simulate( ...
    m, d, startDate:endDate, ... 
   "Deviation", true, "PrependInput", true ...
);

s2 = simulate( ...
    m, d, startDate:endDate, ...
    "Plan", p, ... 
    "Deviation", true, ...
    "PrependInput", true ...
);


p = Plan.forModel(m, startDate:endDate, "anticipate", false);
p = exogenize(p, startDate:startDate+T-1, "R");
p = endogenize(p, startDate:startDate+T-1, "Er");

s3 = simulate( ...
    m, d, startDate:endDate, ...
    "Plan", p, ... 
    "Deviation", true, ...
    "PrependInput", true ...
);


tempDb = databank.merge("horzcat", s1, s2, s3);
draw(ch, tempDb);
visual.heading("Consumption demand shock with delayed policy reaction");
visual.hlegend("bottom", "No delay", "Anticipated", "Unanticipated");


return
%% Simulate consumption demand shock with fixed impact
%
% Find the size of a consumption demand shock such that it leads to exactly
% a 1 pct increase in consumption in the first period. Because consumption
% (C) is a log-linearized variable, specify the 1 pct deviation from its
% steady state as 1.01.

d = zerodb(m, startDate-3:startDate);
d.Y(startDate) = 1.01;

p = Plan.forModel(m, startDate:endDate);
p = exogenize(p, startDate, "Y");
p = endogenize(p, startDate, "Ey");

s = simulate(...
    m, d, startDate:endDate, ...
    "Plan", p, ...
    "Deviation", true, ...
    "PrependInput", true ...
);

disp(s.Ey{1:10})

draw(ch, s);
visual.heading("Consumption demand shock with fixed impact");


%% Simulate Consumption Demand Shocks with Multiple Parameterisations
%
% Within the same model object, expand the number of parameter variants, 
% and assign different sets of values to some (or all) of the parameters
% (here, only the values for the parameter `xip` vary, i.e. the price
% adjustment costs).  Solve and simulate all parameter variants at once.
% Almost all IrisT model functions support multiple parametert variants.
%

mm = alter(m, 8);
mm.xip = [140, 160, 180, 200, 220, 240, 260, 280];
mm = solve(mm);
disp(mm);

d = zerodb(mm, startDate-3:startDate);
d.Ey(1, :) = 0.07;

s = simulate( ...
    mm, d, startDate:endDate, ...
    "deviation", true, ...
    "prependInput", true ...
);

draw(ch, s);
visual.heading("Consumption demand shock with mutliple parameter variants");

