%% Get Information About Model Object
% by Jaromir Benes
%
% Use the function `get` (and a few others) to access various pieces of
% information about the model and its properties, such as variable names,
% parameter values, equations, lag structure, or the model eigenvalues. Two
% related topics are furthermore covered in separate files:
% assigning/changing parameters and steady-state values, and accessing
% model solution matrices.

%% Clear Workspace
%
% Clear workspace, close all graphics figures, clear command window, and
% check the IRIS version.

clear;
close all;
clc;
irisrequired 20140315;
%#ok<*NOPTS>

%% Load Solved Model Object and Historical Database
%
% Load the solved model object built `read_model`. You must run
% `read_model` at least once before running this m-file.

load mat/read_model.mat m;

%% Names of Variables, Shocks and Parameters

disp('List of transition variables');
get(m, 'XList')

disp('List of measurement variables');
get(m, 'YList')

disp('List of shocks');
get(m, 'EList')

disp('List of parameters');
get(m, 'PList')

%% Description of Variables, Shocks and Parameters

disp('Database with descriptions of all variables, shocks and parameters');
get(m, 'Descript')

disp('List of descriptions of transition variables');
get(m, 'XDescript')

%% Equations and Equation Labels

disp('Transition equations')
get(m, 'XEqtns')

disp('Measurement equations')
get(m, 'yEqtn')

disp('Transition equation labels')
get(m, 'XLabels')

disp('Find equation labeled ''Production function''');
findeqtn(m, 'Production function')

disp('Equations whose labels start with P');
findeqtn(m, rexp('P.*'))

%% Comments and User Data
%
% Assign a text comment or any kind of user data to a model object using
% the functions `comment` and `userdata`, respectively. The same functions
% are also used to get the current comment or the user data. It's only your
% business whether and how you use these.

c = comment(m)

m = comment(m, 'New comment');
comment(m)

m = comment(m,c);

x = struct();
x.ToDo = 'Fix this and that';
x.SomeRandNumbers = rand(1,10);

m = userdata(m,x)

userdata(m)

%% Different Ways to Get and Assign/Change Parameters
%
% There are multiple equivalent ways how to view and assign parameters.
% Display the parameter 'gamma', and change the values for two std
% deviations, 'std_ep' and 'std_ew'.

P = get(m, 'parameters');
P.gamma

m.gamma

S = struct( );
S.std_Ey = 0.02;
S.std_Ep = 0.02;
m = assign(m, S);

m = assign(m, 'std_Ey', 0.02, 'std_Ep', 0.02);

m.std_Ey = 0.02;
m.std_Ep = 0.02;

%% Check Stationarity
%
% The logical value `true` is displayed as `1`, the logical value `false`
% is displayed as `0`.

disp('Is the model stationary?');
isstationary(m)

disp('Is the variable stationary?');
get(m, 'IsStationary')

disp('List of stationary variables');
get(m, 'StationaryList')

disp('List of non-stationary variables');
get(m, 'NonstationaryList')

%% Get Currently Assigned Steady State
%
% Steady state is described by complex numbers:
%
% * real part = steady-state levels
% * imaginary part = steady-state growth
%
% The interpretation of the steady-state growth rates
% differs for linearised versus log-linearised variables:
% * linearised variables: x(t) - x(t-1)
% * log-linearised variables: x(t) / x(t-1)

disp('Steady-state levels and growth rates');
get(m, 'Steady')

disp('Steady-state levels');
get(m, 'SteadyLevel')

disp('Steady-state growth rates')
get(m, 'SteadyGrowth')

disp('Is the variable a log-variable?');
get(m, 'IsLog')

disp('List of log-variables');
get(m, 'LogList')  

%% Lags and Initial Conditions

disp('Maximum lag in the model');
get(m, 'MaxLag')

disp('List of initial conditions needed for simulations and forecasts');
get(m, 'Required')

%% Eigenvalues
%
% Get stable, unit, or unstable eigenvalues (roots). Plot the stable roots
% in a unit circle. Display the dominant (largest) stable root, and the
% dominant (smallest) unstable root.

format short e;

disp('Model Eigenvalues (Roots)');
allRoots = get(m, 'Roots');
table(allRoots.', abs(allRoots).', ...
    'VariableNames', {'All_Roots', 'Magnitudes'});

stableRoots = get(m, 'StableRoots');
unitRoots = get(m, 'UnitRoots');
unstableRoots = get(m, 'UnstableRoots');

% Stable roots.
table(stableRoots.', abs(stableRoots).', ...
    'VariableNames', {'Stable_Roots', 'Magnitudes'})

% Unit roots.
table(unitRoots.', abs(unitRoots).', ...
    'VariableNames', {'Unit_Roots', 'Magnitudes'})

% Unstable roots.
table(unstableRoots.', abs(unstableRoots).', ...
    'VariableNames', {'Unstable_Roots', 'Magnitudes'})

format;

figure( );
ploteig(stableRoots);
title('Stable Roots');

[~, pos] = sort(abs(stableRoots), 'descend');
stableRoots = stableRoots(pos);
[~, pos] = sort(abs(unstableRoots), 'ascend');
unstableRoots = unstableRoots(pos);

disp('Largest stable root');
stableRoots(1)
disp('Smallest unstable root and its inverse');
[unstableRoots(1), 1./unstableRoots(1)]

%% Help on IRIS Functions Used in This File
%
%    help model/comment
%    help model/findeqtn
%    help model/get
%    help model/subsref
%    help model/subsasgn
%    help model/userdata
