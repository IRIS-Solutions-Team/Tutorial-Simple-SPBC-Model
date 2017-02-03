%% Read and Solve Model
% by Jaromir Benes
%
% Create a model object by loading the model file `Simple_SPBC.model`,
% assign parameters to the model object, find its steady state, and compute
% the first-order accurate solution. The model object is then saved to a
% mat file, and ready for further experiments.

%% Clear Workspace
%
% Clear workspace, close all graphics figures, clear command window, and
% check the IRIS version.

clear;
close all;
clc;
irisrequired 20140315;

if ~exist('MAT', 'dir')
    mkdir('MAT');
end

%% Read Model File and Create Model Object
%
% The function `model` reads the model file and translates it into a model
% object, called here `m`. Model objects are complex structures that carry
% all the information needed about the model, and can be manipulated by
% calling some of the IRIS functions.

m = Model('simple_SPBC.model');

%% Calibrate Model Parameters
%
% Assign parameters using the simplest possibly syntax: `m.XXX = YYY;`
% where `XXX` is the name of a parameters, and `YYY` is its value. Use the
% function `get` <?get?> to retrieve a database with currently assigned
% parameter values.

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

m.rhor = 0.85;
m.kappap = 3.5;
m.kappan = 0;

m.Short_ = 0;
m.Infl_ = 0;
m.Growth_ = 0;
m.Wage_ = 0;

m.std_Mp = 0;
m.std_Mw = 0;
m.std_Ea = 0.001;

disp('Get a parameter database from the model object');
get(m,'parameters') %?get?

%% Compute Steady State
%
% Compute and numerically check the steady-state values for all model
% variables. The option `'growth=' true` <?growth?> says this is a
% non-stationary BGP model where variables can grow at a constant rate over
% time (the steady-state solution is modified to handle such models).

m = sstate(m, 'Growth=', true); %?growth?
chksstate(m);

%% Compute First Order Solution

m = solve(m);

disp('Solved model')
m %#ok<NOPTS>

%% Save Model Object
%
% Save the solved model object to a mat-file (binary file) for future use.

save MAT/read_model.mat m;

%% Help on IRIS Functions Used in This File
%
% Use either `help` to display help in the command window, or `idoc`
% to display help in an HTML browser window.
%
%    help model/model
%    help model/subsasgn
%    help model/assign
%    help model/sstate
%    help model/chksstate
%    help model/solve
