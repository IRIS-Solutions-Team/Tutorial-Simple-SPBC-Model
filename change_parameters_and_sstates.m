%% Assign and Change Parameters and Steady States
%
% Assign or change the values of parameters and/or steady states of
% variables in a model object using a number of different ways. Under
% different circumstances, different methods of assigning parameters may be
% more convenient (while being all equivalent).

%% Clear Workspace
%
% Clear workspace, close all graphics figures, clear command window, and
% check the IRIS version.

close all
clear

%#ok<*NOPTS>
%#ok<*NASGU>


%% Read Model File and Assign Parameters to Model Object
%
% The easiest way to assign or change parameters is simply by using the
% dot-reference, i.e. the name of the model object dot the name of the
% parameter.

m = Model('simple_SPBC.model');

m.alpha = 1.03^(1/4);
m.beta = 0.985^(1/4);
m.gamma = 0.60;
m.delta = 0.03;
m.pi = 1.025^(1/4);
m.eta = 6;
m.k = 10;
m.psi = 0.5;

m.chi = 0.80;
m.xiw = 60;
m.xip = 80;
m.rhoa = 0.90;

m.rhor = 0.8;
m.kappap = 2.5;
m.kappan = 0.1;

m.Short_ = 0;
m.Wage_ = 0;

m.std_Mp = 0;
m.std_Mw = 0;
m.std_Ea = 0.1/100;

table(m, 'parameters')

%% Assign Parameter Database When Reading Model File
%
% Create first a database with the desired parameter values (or
% use an existing one, for example), and assign the database when
% reading the model file, i.e. when calling the Model object
% constructor functionk `Model( )`, by using the option
% `Assign=`.

P = struct( );

P.alpha = 1.03^(1/4); 
P.beta = 0.985^(1/4);
P.gamma = 0.60;
P.delta = 0.03;
P.pi = 1.025^(1/4);
P.eta = 6;
P.k = 10;
P.psi = 0.5;

P.chi = 0.80;
P.xiw = 60;
P.xip = 80;
P.rhoa = 0.90;

P.rhor = 0.8;
P.kappap = 2.5;
P.kappan = 0.1;

P.Short_ = 0;
P.Wage_ = 0;

P.std_Mp = 0;
P.std_Mw = 0;
P.std_Ea = 0.1/100;

m = Model('simple_SPBC.model', 'Assign=', P); 

table(m, 'parameters')

%% Assign Parameter Database After Reading Model File
%
% Here, use again a parameter database, but assign the database after
% reading the model file, in a separate call to the function |assign( )|.

P = struct( );

P.alpha = 1.03^(1/4);
P.beta = 0.985^(1/4);
P.gamma = 0.60;
P.delta = 0.03;
P.pi = 1.025^(1/4);
P.eta = 6;
P.k = 10;
P.psi = 0.5;

P.chi = 0.80;
P.xiw = 60;
P.xip = 80;
P.rhoa = 0.90;

P.rhor = 0.8;
P.kappap = 2.5;
P.kappan = 0.1;

P.Short_ = 0;
P.Wage_ = 0;

P.std_Mp = 0;
P.std_Mw = 0;
P.std_Ea = 0.1/100;

m = Model('simple_SPBC.model');

m = assign(m, P); 

table(m, 'parameters')

%% Change Parameters in Model Object
%
% There are several ways how to change some of the parameters. All the
% following three blocks of code do exactly the same.
%
% * Refer directly to the model object using a model-dot-name notation.

m.chi = 0.9;
m.xip = 100;

%%%
%
% * Use the |assign( )| function and specify name-value pairs.

m = assign(m, 'chi=', 0.9, 'xip=', 100); 

%%%
%
% * Create a database with somenew values, and run |assign( )|.

P = struct( );
P.chi = 0.9;
P.xip = 100;
m = assign(m, P);

%%%
%
% Reset the parameters to their original values.

m.chi = 0.8;
m.xip = 80;

%% Fast Way to Repeatedly Change Parameters
%
% If you need to iterate over a number of different parameterisations, use
% the fast version of the function |assign( )|. First, initialise the fast
% |assign( )| by specifying the list of parameters (and nothing else).
% Then, use |assign( )| repeatedly to pass different sets of values (in the
% same order) to the model object. Compare the time needed to assign 1,000
% different pairs of values for two parameters.

load MAT/read_model.mat m;

chis = linspace(0.5, 0.95, 1000);
xips = linspace(60, 200, 1000);

assign(m, {'chi', 'xip'}); 

tic
for i = 1 : 1000
   m = assign(m, [chis(i), xips(i)]); 
end
toc

tic
for i = 1 : 1000
   m.chi = chis(i);
   m.xip = xips(i);
end
toc

%% Assign or Change Steady State Manually
%
% If you wish to manually change some of the steady-state values (or, for
% instance, assign all of them because they have been computed outside the
% model), treat the steady-state values the same way as parameters.
%

m = sstate(m, 'Growth=', true, 'Solver=', {'IRIS', 'Display=', 'Off'});
chksstate(m)
disp('Steady-state database')
sstate_database = get(m, 'sstate')

%%%
%
% Change both the levels and growth rates of |Y| and |C| using the
% model-dot-name notation.

m.Y = 2 + 1.01i;
m.Pk = 10 + 1.05i;

%%%
%
% Change the steady states for |Y| and |C| using the function |assign| with
% name-pair values.

m = assign(m, 'Y', 2+1.01i, 'Pk', 10+1.05i);

%%%
%
% Do the same as above but separately for the levels and growth rates.

m = assign(m, '-level', 'Y', 2, 'Pk', 10);
m = assign(m, '-growth', 'Y', 1.01, 'Pk', 1.05);

%%%
%
% Change the steady states by creating a database with the new values, and
% passing the database in |assign|.

P = struct();
P.Y = 2 + 1.01i;
P.Pk = 10 + 1.05i;
m = assign(m, P);

%%%
%
% Note that the newly assigned steady states are, of course, not consistent
% with the model.

disp('Check steady state -- it does not hold');
[flag, listOfEquations] = chksstate(m, 'Error=', false);
flag
listOfEquations

%%%
%
% Reset the steady state to the original values.

m = assign(m, sstate_database);
disp('Check steady state; it holds');
chksstate(m)

