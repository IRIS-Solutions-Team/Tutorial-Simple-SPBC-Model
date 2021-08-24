%% Calculate and Describe Balanced Growth Path
%
% The SPBC.model is a BGP model: It does not have a stationary long run.
% Instead, it has two unit roots, introduced through the productivity
% process, and the general nominal price level. To deal with BGP models, 
% there is absolutely no need to stationarise them. They can be worked with
% directly in their non-stationary forms.

%% Dependencies
%
% Run the following m-files before this one:
%
% * <read_model.html read_model>
%

%% Clear Workspace
%
% Clear workspace, close all graphics figures, clear command window, and
% check the IrisT version.
%

clear
close all


%% Load Solved Model Object
%
% Load the solved model object built in <read_model.html read_model>. 
%

load mat/createModel.mat m


%% Compute Two Different Points on BGP
%
% Compute two different points on the BGP corresponding to two different
% levels of productivity, `A`. The resulting steady-state levels of other
% varibles are always in constant proportion to the level of `A` (here,
% they simply double). The steady-state growth rates remain, obviously,
% unchanged. Whenever some variables are fixed in `sstate( )`, the steady
% state must be solved for non-recursively, i.e. with `Blocks=false`; this
% is the default setting, and can be therefore omitted.

m1 = m;
m1.A = 2;
[m1, ~, info1] = steady( ...
    m1 ...
    , "Blocks", false ...
    , "FixLevel", "A" ...
);
checkSteady(m1);

m2 = m;
m2.A = 4;
[m2, ~, info1] = steady( ...
    m2 ...
    , "Blocks", false ...
    , "FixLevel", "A" ...
);
checkSteady(m2); 

disp("Productivity level and gross rate of growth")
a1 = m1.A;
a2 = m2.A;
[a1, a2] %#ok<NOPTS>

disp("Output levels and their ratio")
y1 = real(m1.Y);
y2 = real(m2.Y);
[y1, y2, y2/y1] %#ok<NOPTS>

disp("Output growth rates")
y1 = imag(m1.Y);
y2 = imag(m2.Y);
[y1, y2] %#ok<NOPTS>

disp("Real wage levels and their ratio")
rw1 = real(m1.W) / real(m1.P);
rw2 = real(m2.W) / real(m2.P);
[rw1, rw2, rw2/rw1] %#ok<NOPTS>


%% Solve model around different points
%
% It does not matter which point on the BGP is used to solve the model.
% They give the same solution. Illustrate this fact here by comparing the
% covariance matrices of the model variables, and a shock simulation.

m1 = solve(m1);
m2 = solve(m2);

C1 = acf(m1);
C2 = acf(m2);

index = isfinite(C1);
maxabs(C1(index), C2(index))

d1 = zerodb(m1, 1:20);
d1.Er(1) = 0.01;
s1 = simulate(m1, d1, 1:20, "deviation", true);
s1 = dbextend(d1, s1);

d2 = zerodb(m2, 1:20);
d2.Er(1) = 0.01;
s2 = simulate(m2, d2, 1:20, "deviation", true);
s2 = dbextend(d2, s2);

[s1.Y, s2.Y, s1.Y-s2.Y] %#ok<NOPTS>
maxabs(s1, s2)

