%% Create and solve model object
%
% Create a model object from the model file <Simple_SPBC.model>, assign
% parameters to the model object, calculate its steady state, and compute
% first-order solution matrices.
%

%% Clear the workspace
%
% Clear all variables, close all figure windows.
%

close all
clear

if ~exist("mat", "dir")
    mkdir mat
end


%% Read the model file and create a model object
%
% The function `Model()` reads the model file <Simple_SPBC.model>, and
% translates it into a model object, called here `m`. Model objects are
% complex structures that carry all the necessary information about the
% model, and can be manipulated by calling various IRIS functions.
%

m = Model.fromFile( ...
    "model-source/spbc.model" ...
    , "growth", true ...
);

disp(m)


%% Calibrate model parameters
%
% Assign parameters using the dot syntax, e.g. `m.gamma = 0.60` where
% `gamma` is the name of a parameter, and `0.60` is the value to be
% assigned. Use the function `access()` to retrieve a databank with the
% currently assigned values of parameters and std deviations; the
% parameters that have been assigned no value are `NaN`.
%

m.alpha = 1.03^(1/4);
m.beta = 0.985^(1/4);
m.gamma = 0.60;
m.delta = 0.03;
m.pi = 1.025^(1/4);
m.eta = 6;
m.k = 10;
m.psi = 0.25;

m.chi = 0.85;
m.xiw = 60;
m.xip = 300;
m.rhoa = 0.90;
m.rhoterm20 = 0.80;

m.rhor = 0.85;
m.kappap = 3.5;
m.kappan = 0;

m.Short_ = 0;
m.Long_ = 0;
m.Infl_ = 0;
m.Growth_ = 0;
m.Wage_ = 0;

m.std_Mp = 0;
m.std_Mw = 0;
m.std_Ea = 0.001;

access(m, "parameter-values")
access(m, "std-values")


%% Find steady state
%
% Run `steady()` to calculate the steady-state values for all model
% variables. The option `Growth=true` means this is a non-stationary BGP
% model where variables can grow at a constant rate over time; the
% steady-state solution algorithm is modified to handle models with growth.
% Use `checkSteady()` to numerically verify the steady state values
% on dynamic equations; if there is a significant numerical discrepancy,
% the function will throw an error.
%

m = steady(m);
checkSteady(m);
access(m, 'steady')

table( ...
    m, ["steadyLevel", "steadyChange", "form", "description"] ...
    , "writeTable", "steady.xlsx" ...
)


%% Calculate first-order solution matrices
%
% Run `solve()` to calculate a first-order expansion of the model
% equations around the steady state, and finds a first-order
% rational-expectations solution. The solution matrices (state-space
% matrices) are stored within the model object; they are examined in
% <know_all_about_solution>. The availability of a first-order solution is
% indicated the model object is displayed.
%

m = solve(m);
disp(m)


%% Save the model object
%
% Save the solved model object to a mat file (internal Matlab binary file)
% for future use.
%

save mat/createModel.mat m

