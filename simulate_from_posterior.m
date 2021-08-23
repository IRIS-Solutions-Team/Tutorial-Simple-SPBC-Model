
close all
clear

load mat/read_model.mat m
load mat/estimate_params.mat s

m0 = m;

% Create space for 5,000 parameter variants
% Copy the existing parameters into all of them
m = alter(m, 5000);

% Assign 5,000 different parameter sets from the 
% posterior distribution
m = assign(m, s.chain);
checkSteady(m);
m = solve(m);

d = zerodb(m, 1:40);
d.Ey(1) = 0.10;
s = simulate(m, d, 1:40, 'Deviation=', true);

figure( );
plot(s.Y);

%% Percentiles

func = @(x) prctile(x, [0.10, 0.50, 0.90]);
prc = databank.apply(func, s);

dbplot(prc, 0:20, {'Y', 'dP', 'R'});



