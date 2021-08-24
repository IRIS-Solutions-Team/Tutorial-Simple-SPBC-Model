%% Compare Second Moment Properties in Model and Data
%
% Compute and compare several second-moment properties of the estimated
% model and the data. Describe the data using an estimated VAR; this also
% allows to evaluate sampling uncertainty of the empirical estimates using
% bootstrap methods.


%% Clear Workspace
%
% Clear workspace, close all graphics figures, clear command window, and
% check the IRIS version.

close all
clear

load mat/estimateParams.mat mest startHist endHist
load mat/prepareDataFromFred.mat c 

d = c;


%% Estimate VAR and BVAR
%
% Estimate an unrestricted 2nd-order VAR, and a 2nd-order Bayesian VAR with
% Litterman-type priors. First, create an empty VAR object specifying the
% names of the endogenous variables. The names are identical to the names
% of measurement variables in the DSGE model.  Second, call the function
% `estimate( )` with an input database. For bayesian VARs, create prior
% dummy observations before running `estimate( )`.

ylist = access(mest, "measurement-variables");

p = 2;

v = VAR(ylist, "Order", p) %#ok<NOPTS> %(#emptyvar)
[v, vdata] = estimate(v, d, startHist:endHist);
v

X = BVAR.litterman(0, sqrt(30), 0) %#ok<NOPTS> %(#priordummy)

bv = VAR(ylist, "Order", p) %#ok<NOPTS>
[bv, bvdata] = estimate( ...
    bv, d, startHist:endHist ...
    , "BVAR", X ...
    , "Stdize", true ...
);

bv



%{
%% Compare Transition Matrices
%
% Get and print the transition matrices from the plain VAR and the BVAR
% objects. The transition matrices are Ny-by-Ny-by-P matrices, where Ny is
% the number of variables, and P is the order of the VAR.

A = (v, "A*");
BA = (bv, "A*");

disp("Unrestricted VAR transition matrix");
A(:, :, 1)
A(:, :, 2)
disp("BVAR transition matrix");
BA(:, :, 1)
BA(:, :, 2)


%% Compare Residuals
%
% Plot and compare the estimated residuals from the plain VAR and the BVAR.
% Use the output data, `vdata` and `bvdata` returned from `estimate( )`.
% These databases containing both the endogenous variables and estimated
% residuals. By default, the residuals are named `res_XXX` where `XXX` is
% the name of the respective variable, 

elist = (v, "EList");

figure( );
for i = 1 : 4
    name = elist{i};
    subplot(2, 2, i);
    plot(vdata.(name));
    hold all;
    plot(bvdata.(name));
    title(name, "Interpreter", "None");
    grid on;
    axis tight;
end
visual.hlegend("Bottom", "Unrestricted VAR(2)", "BVAR(2)");
%}


%% Resample From Estimated VAR
%
% Use a wild bootstrap to generate `N=500` of VARs; a wild bootstrap is
% robust to potential heteroscedasticity of residuals. Note that some of
% the resampled VAR parameterisations may be explosive, and remove them
% from the VAR object.

N = 1000;
Y = resample(v, vdata, startHist+p:endHist, N, "Wild", true, "Progress", true);
size(Y)

Nv = VAR(ylist);
Nv = estimate(Nv, Y, startHist:endHist, "Order", p);

inx = isstationary(Nv);
sum(inx)
Nv = Nv(inx);


%% Compare ACF From Model and Data
%
% Compute and plot the autocovariance/autocorrelation functions (ACF) for
% the estimated VAR, the resampled VARs, and the model. The function
% `helper.plotAcf( )` is a helper function (for plotting ACFs) created for
% this exercise in this tutorial (it is not part of the IRIS toolbox).

[Cv, Rv] = acf(v, "Order", 1);
[CNv, RNv] = acf(Nv, "Order", 1);
[Cm, Rm] = acf(mest, "Order", 1, "select", ylist);

numY = numel(ylist);
figure( );
for i = 1 : numY
    for j = i : numY
        subplot(numY, numY, (i-1)*numY+j);
        helper.plotAcf(CNv(i, j, 1, :), Cv(i, j, 1), Cm(i, j, 1)); %(#herePlotAcf)
        title(sprintf("Cross-covariance %s x %s", ylist(i), ylist(j)));
    end
end

visual.hlegend("Bottom", "VAR: Bootstrap", "VAR: Point Estimate", "Model: Asymptotic");
visual.heading("Estimated Cross-covariances");


%% Compare Frequency Selective ACF
%
% Use the option `Filter=` to compute the ACF (both from the strucural
% model and the VAR) that corresponds to cyclical fluctuations with
% periodicity between 4 and 40 quarters (1 to 10 years).

[Cv1, Rv1] = acf(v, "Order", 1, "Filter", "Per<=40 & per>4");
[Cv2, Rv2] = acf(v, "Order", 1, "Filter", "Per>40");
[Cv3, Rv3] = acf(v, "Order", 1, "Filter", "Per<=4");

maxabs(Cv1+Cv2+Cv3 - Cv)

[CNv1, RNv1] = acf(Nv, "Filter", "Per<=40 & per>4", "Progress", true);

[Cm1, Rm1] = acf(mest, "Filter", "Per<=40 & per>4", "select", ylist);

figure( );
for i = 1 : numY
    for j = i : numY
        subplot(numY, numY, (i-1)*numY+j);
        helper.plotAcf(CNv1(i, j, 1, :), Cv(i, j, 1), Cm1(i, j, 1));
        title(sprintf("Cross-cov %s x %s", ylist(i), ylist(j))); 
    end 
end 
visual.hlegend("Bottom", "VAR: Bootstrap", "VAR: Point Estimate", "Model: Asymptotic");
visual.heading("Estimated Cross-covariances for Periodicities Below 40 Qtrs");


%% Compare VAR and Model Spectra
%
% Compute and plot the power spectra and spectral densities for the
% estimated VAR and for the model. The function `helper.plotXsf( )` is a
% helper function (for plotting the spectral densities) created for this
% exercise in this tutorial (it is not part of the IRIS toolbox); it can be
% opened and viewed in the Matlab editor.
%

freq = 0.05 : 0.05 : pi;
[Pv, Sv] = xsf(v, freq);
[Pm, Sm] = xsf(mest, freq, "select", ylist);

figure( );

for i = 1 : numel(ylist)
    subplot(2, 3, i);
    helper.plotXsf(freq, Sv(i, i, :), Sm(i, i, :));
    title(sprintf("Spect density %s", ylist(i)));
end

visual.hlegend("Bottom", "VAR: Point Estimate", "Model: Asymptotic");
visual.heading("Estimated Spectral Densities");


