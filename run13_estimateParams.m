%% Run Bayesian Parameter Estimation
%
% Use bayesian methods to estimate some of the parameters. First, set up
% our priors about the individual parameters, and locate the posterior
% mode. Then, run a posterior simulator (adaptive random-walk Metropolis)
% to obtain the whole distributions of the parameters.
%


%% Clear Workspace

close all
clear
%#ok<*ASGLU> 
%#ok<*CLARRSTR> 

visualize = false;
% numPoster = 3000;
numPoster = 500;


%% Load Solved Model Object and Historical Database
%
% Load the solved model object built `<read_model>`, and the historical
% database and dates created in `<read_data>`. 
%

load mat/createModel.mat m
load mat/prepareDataFromFred.mat c

d = c;
startHist = qq(1995,1);
endHist = qq(2022,1);

%{
m.pi = (1 + 2/100)^(1/4);
m.Short = 3;
m.Wage_ = -2;

m = steady(m, "exogenize", "Short", "endogenize", "beta0");
checkSteady(m);
m = solve(m);
%}


%% Set Up Estimation Input Structure
%
% The estimation input struct describes which parameters to estimate and
% how to estimate them. A struct needs to be created with one field for
% each parameter that is to be estimated. Each parameter can be then
% assigned a cell array with up to four pieces of information:
%
%    estimSpecs.parameter_name = {start}
%    estimSpecs.parameter_name = {start, lower}
%    estimSpecs.parameter_name = {start, lower, upper}
%    estimSpecs.parameter_name = {start, lower, upper, dist}
%
% where `start` is a starting value for the iteration, `lower` and
% `upper` are the lower and upper bounds, respectively, and `dist` is a
% `distribution` object to specify the prior distribution on that
% parameter.
%
% If the starting value is `NaN`, then the currently assigned parameter
% value (from the model object) is used. The constants `-Inf` and `Inf` can
% be used for the lower and upper bounds, respectively. 
%

estimSpecs = struct( );

% estimSpecs.chi = {NaN, 0.5, 0.95, distribution.Normal.fromMeanStd(0.85, 0.025)};
estimSpecs.chi = {NaN, 0.5, 0.95, distribution.Normal.fromMeanStd(0.85, 0.01)};
estimSpecs.xiw = {NaN, 30, 1000, distribution.Normal.fromMeanStd(60, 5)};
estimSpecs.xip = {NaN, 30, 1000, distribution.Normal.fromMeanStd(300, 5)};
estimSpecs.rhor = {NaN, 0.10, 0.95, distribution.Beta.fromMeanStd(0.85, 0.05)};
estimSpecs.kappap = {NaN, 1.5, 10, distribution.Normal.fromMeanStd(3.5, 1)};
estimSpecs.kappan = {NaN, 0, 0.2, distribution.Normal.fromMeanStd(0.1, 0.01)};
estimSpecs.beta1 = {NaN, 0.8, 1};

estimSpecs.std_Ep      = {0.01, 0.001, 0.10, distribution.InvGamma.fromMeanStd(0.01, Inf)};
estimSpecs.std_Ew      = {0.01, 0.001, 0.10, distribution.InvGamma.fromMeanStd(0.01, Inf)};
estimSpecs.std_Ea      = {0.001, 0.0001, 0.01, distribution.InvGamma.fromMeanStd(0.001, Inf)};
estimSpecs.std_Er      = {0.005, 0.0001, 0.10, distribution.InvGamma.fromMeanStd(0.005, Inf)};
estimSpecs.std_Eterm20 = {0.05, 0.001, 0.30, distribution.InvGamma.fromMeanStd(0.10, Inf)};

estimSpecs.corr_Er__Ep = {0, -0.9, 0.9, distribution.Normal.fromMeanStd(0, 0.5)};

disp(estimSpecs)


%% Visualize Prior Distributions
%
% The function `plotpp( )` plots the prior distributions (this function can
% also plot the priors together with posteriors obtained from a posterior
% simulator; see below). To control the appearance and graphics
% properties of the various plots included in the graphs, use either the
% options `Figure=`, `Axes=`, `Title=`, `PlotPrior=`, `PlotInit=`,
% `PlotMode=`, `PlotPoster=`, `PlotBounds=`, or alternatively the standard
% Matlab function `set( )` with the graphics handles returned in the struct
% `h`.


if visualize
    [~, ~, h] = plotpp( ...
        estimSpecs, [ ], [ ] ...
        , "subplot", [2, 3] ...
    );

    for f = h.figure
        figure(f);
        visual.heading("Prior Distribution");
    end
end


%% Maximize Posterior Distribution to Locate Its Mode
%
% The main output arguments are the following (these remain the same
% whatever the set-up of the estimation):
%
% * `summary` -- Summary table with several characteristics describing the
% final estimates (posterior mode) and input assumptions (prior, starting
% value, bounds).
% * `pos` -- Initialized posterior simulator object. The object `pos` will
% be used later in this file to run a posterior simulator.
% * `C` -- Covariance matrix of the parameter estimates based on the
% asymptotical hessian of the posterior density at its mode.
% * `H` -- Cell array 1-by-2: `H{1}` is the hessian of the objective
% function returned by the Optim Tbx (should be close to `C`); `H{2}` is a
% diagonal matrix with the contributions of the priors to the total
% hessian.
% * `mest` -- Model object with the new estimated parameters.
% * `v` -- Estimate of the common variance factor (only with the option
% `Relative=true`, which is the default setting); all the std dev of all
% shocks are multiplied automatically by the square root of this number.
% * `delta` -- Estimates of the deterministic trend parameters estimated
% by concentrating them out of the likelihood function.


filterOpt = {
    "outOfLik"; "Wage_"
    "unitRootInitials"; "approxDiffuse"
    "relative"; true
};

optimSet = { ...
    "MaxFunEvals"; 10000
    "MaxIter"; 100
};

[summary, pos, C, H, mest, v, delta, Pdelta] = estimate( ...
    m, d, startHist:endHist, estimSpecs ...
    , "filter", filterOpt ...
);

summary

f = kalmanFilter(mest, d, startHist:endHist, filterOpt{:});

%% Visualize objective function (posterior mode) around optimum 


n = neighbors(pos, 0.95:0.005:1.05);

if visualize
    plotNeighbors(pos, n, "plotSystemPriors", false);
    visual.hlegend("bottom", "Minus log posterior", "Mode", "Contribution of data lik", "Contribution of indie priors")
end


%% Visualize Prior Distributions and Posterior Modes
%
% Use the function `plotpp( )` again supplying now the struct `summary`
% with the estimated posterior modes as the second input argument. The
% posterior modes are added as stem graphs, and the estimated values are
% included in the graph titles.

if visualize
    [pr, po, h] = plotpp(  ...
        estimSpecs, summary, [ ], ...
        "Title", {"FontSize", 8}, ...
        "Axes", {"FontSize", 8}, ...
        "PlotInit", {"LineWidth", 2}, ...
        "PlotMode", {"LineWidth", 2}, ...
        "Subplot", [2, 3] ...
    ); 
    
    for f = h.figure
        visual.heading("Prior Distributions and Posterior Modes");
        visual.hlegend( ...
            "Bottom" ...
            , "Prior Density", "Starting Value", "Posterior Mode" ...
            , "Lower Bound", "Upper Bound" ...
        );
    end
end


%% Run Adaptive Random Walk Metropolis Posterior Simulator
%
% Run 5,000 draws from the posterior distribution using an adaptive version
% of the random-walk Metropolis algorithm. The number of draws, `numPoster=1000`, 
% should be obviously much larger in practice (such as 100,000 or
% 1,000,000). 
% The output argument `ar` monitors the evolution of the acceptance ratio.
% The default target acceptance ratio is 0.234 (can be modified using the
% option `TargetAR=` in `arwm( )`), the covariance of the proposal
% distribution is gradually adapted to achieve this target.
%

[theta, logPost, ar, posFinal, scale, finalCov] = arwm( ...
    pos, numPoster ...
    , "Progress", true ...c
    , "AdaptScale", 1/2 ...
    , "AdaptProposalCov", 1/2 ...
    , "Gamma", 0.51 ...
    , "BurnIn", 0.20 ...
);


%%

if visualize
    tiledlayout("flow");
    nexttile( );
        plot(logPost);
        title("Log Posterior");
    nexttile( );
        plot(ar);
        title("Cumulative Acceptance Rate");
    nexttile( );
        plot(scale);
        title("Adaptive Scale of Proposal Cov");
end

%% Calculate Posterior Distribution Statistics
%
% Use then the function `stats` to calculate some statistics of
% the simulated parameter chains -- by default, the simulated chains, their
% means, std errors, high probability density intervals, and the marginal
% data density are returned. Feel free to change the list of requested
% characteristics; see help on `poster/stats` for details.
%

s = stats(pos, theta, logPost)


%% Visualize Priors and Posteriors
%
% Because the number of draws from the posterior distribution is very low, 
% `numPoster=1000`, the posterior graphs are far from being smooth, and may visibly
% change if another posterior chain is generated.

if visualize
    [pr, po, h] = plotspp( ...
        estimSpecs, summary, theta, ...
        "PlotPrior", {"LineStyle", "--"}, ...
        "PlotMode", {"LineWidth", 3}, ...
        "PlotInit", {"LineWidth", 3}, ...
        "PlotBounds", {"LineStyle", "--"}, ...
        "Title", {"FontSize", 8}, ...
        "Subplot", [2, 3] ...
    ); 
    
    for f = h.figure
        figure(f);
        visual.heading("Prior Distributions and Posterior Distributions");
        visual.hlegend( ...
            "Bottom",...
            "Prior Density", "Starting Value", ...
            "Posterior Mode", "Posterior Density", ...
            "Lower Bound", "Upper Bound" ...
        );
    end
end


%% Save Model Object with Estimated Parameters

save mat/estimateParams.mat mest pos estimSpecs theta logPost s startHist endHist

