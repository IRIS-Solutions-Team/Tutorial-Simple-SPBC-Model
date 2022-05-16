%% Get information about model object
%
% Use the functions `access` and `table` to access various pieces of
% information about the model, the model object, and its properties, such
% as variable names, parameter values, equations, lag structure, or the
% model eigenvalues.
%
% Two related topics are covered in separate scripts: 
%
% * assigning/modifying the model parameters and the steady-state values in
% [`run03_modifyParameters`](run03_modifyParameters.m), 
%
% * and accessing model solution matrices in
% [`run04_aboutSolution.m`](run04_aboutSolution).
%


%% Clear workspace
%
% Clear workspace, close all graphics figures, clear command window.
%

close all 
clear
%#ok<*NOPTS>


%% Load solved model object
%
% Load the model object created in <read_model.html read_model>.
%

load mat/createModel.mat m


%% Names of variables, shocks and parameters

disp("List of transition variables")
access(m, "transition-variables")'

disp("List of measurement variables")
access(m, "measurement-variables")'

disp("List of transition shocks")
access(m, "transition-shocks")'

disp("List of measurement shocks")
access(m, "measurement-shocks")'

disp("List of parameters")
access(m, "parameters")'


%% Description of variables, shocks and parameters

disp("Struct with descriptions of all variables, shocks and parameters")
access(m, "names-descriptions")


%% Access equations 

disp("All equations")
access(m, "equations")'

disp("Transition equations")
access(m, "transition-equations")'

disp("Measurement equations")
access(m, "measurement-equations")'


%% Comments and user data
%
% Access and (re)assign a text comment or any kind of user data to a model
% object
%

c = comment(m)

m = comment(m, "New comment");
comment(m)

m = comment(m, c);

x = struct();
x.ToDo = "Fix this and that";
x.SomeRandNumbers = rand(1,10);

m = assignUserData(m, "TODO", "Fix this");
m = assignUserData(m, "RandomNumbers", rand(1, 10));

accessUserData(m)


%% Different Ways to Get and Assign/Change Parameters
%
% There are multiple equivalent ways how to view and assign parameters.
% Display the parameter `gamma`, and change the values for two std
% deviations, `std_ep` and `std_ew`.
%

p = access(m, "parameter-values");
p.gamma

m.gamma

s = struct();
s.std_Ey = 0.02;
s.std_Ep = 0.02;
m = assign(m, s);

m = assign(m, "std_Ey", 0.02, "std_Ep", 0.02);

m.std_Ey = 0.02;
m.std_Ep = 0.02;


%% Check stationarity

disp("Is the model stationary?")
isstationary(m)

disp("Is the variable stationary?")
access(m, "is-stationary")



%% Get currently assigned steady state
%
% Steady state is described by complex numbers:
%
% * real part = steady-state levels
% * imaginary part = steady-state growth
%
% The interpretation of the steady-state growth rates
% differs for linearised versus log-linearised variables:
%
% * linearised variables: x(t) - x(t-1)
% * log-linearised variables: x(t) / x(t-1)
%

disp("Steady-state levels and growth rates")
access(m, "steady")

disp("Steady-state levels")
access(m, "steady-level")

disp("Steady-state change (diff or rate of change)")
access(m, "steady-change")

disp("Is the variable declared as a log-variable?")
access(m, "is-log")


%% Lags, leads, and initial conditions

disp("Maximum lag in the model")
access(m, "maxLag")

disp("Maximum lead in the model")
access(m, "maxLead")

disp("Transition vector")
access(m, "transition-vector")'

disp("List of initial conditions needed for simulations and forecasts")
access(m, "initials")'


%% Eigenvalues (Roots)
%
% Get stable, unit, or unstable eigenvalues (roots). Plot the stable roots
% in a unit circle. Display the dominant (largest) stable root, and the
% dominant (smallest) unstable root.

format short e

disp("Model eigenvalues (Roots)");
allRoots = table(m, "allRoots")

% Stable roots
stableRootsTable = table(m, "StableRoots")

% Unit roots
unitRootsTable = table(m, "UnitRoots")

% Unstable roots
unstableRootsTable = table(m, "UnstableRoots")

format


%% Plot stable and inverted unstable roots 

figure( )
hold on
visual.eigen(stableRootsTable{:, 1});
title("Stable roots");

figure( )
visual.eigen(1./unstableRootsTable{:, 1});
title("Inverted unstable roots");


%% Sorted roots

[~, pos] = sort(stableRootsTable{:, 2}, "descend");
stableRootsSortedTable = stableRootsTable(pos, :);

[~, pos] = sort(unstableRootsTable{:, 2}, "ascend");
unstableRootsSortedTable = unstableRootsTable(pos, :);


%% Show most influential roots 
%
% Show the roots that are the most influential for the model dynamics: the
% largest stable root and the smallest unstable root.
%

disp("Magnitude of the largest stable root")
stableRootsSortedTable{1, 2}

disp("Magnitude of smallest unstable root and its inverse")
[unstableRootsSortedTable{1, 2}, 1./unstableRootsSortedTable{1, 2}]

