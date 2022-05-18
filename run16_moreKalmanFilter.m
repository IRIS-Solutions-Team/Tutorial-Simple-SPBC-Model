%% More on Kalman Filter
%
% Run more advanced Kalman filter exercises. Split the data sample into two
% sub-samples, and pass information from one to the other. Run the filter
% with time-varying std deviations of some shocks. Evaluate the likelihood
% function and the contributions of individual time periods to the overall
% likelihood.
%


%% Clear Workspace
%
% Clear workspace, close all graphics figures, clear command window, and
% check the IRIS version.

close all
clear

load mat/estimateParams.mat mest startHist endHist
load mat/prepareDataFromFred.mat c

d = c;


%% Split the Kalman filter into sub-samples
%
% With the range split into two or more sub-samples, and the Kalman
% filter-smoother executed successively on each of them (using the most
% recent result as the initial condition for the next run), the smoothed
% data estimates will differ from those obtained previously (running the
% filter once on the whole range). This is because the individual runs of
% the filter of data will be based on different information sets.
%
% The only exception is, obviously, the last sub-sample, which is by
% construction based on information from the entire range 1..T, and hence
% identical to the information set when the filter is run just once on the
% entire range.
%
% When running the Kalman filter on the last sub-sambple, the
% output database from the previous run, `f1`, is used to set up initical
% condition for the filter (instead of the default asymptotic
% distribution). This is allowed by the fact that the database `f1`
% contains both the point estimates and the MSE matrices.

checkSteady(mest);
mest = solve(mest);

f0 = kalmanFilter( ...
    mest, d, startHist:endHist ...
    , "relative", false ...
);

N = 15;

f1 = kalmanFilter( ...
    mest, d, startHist:endHist-N ...
);

f1 

f2 = kalmanFilter( ...
    mest, d, endHist-N+1:endHist ...
    , "initials", {f1.Median, f1.MSE} ...
); 


%%%
%
% Print differences between the smoothed data
%

disp("Smoothed estimates differ for the first sub-sample")
maxabs(f0.Mean, f1.Mean)

disp("Smoothed estimates are identical for the last sub-sample")
maxabs(f0.Mean, f2.Mean)


%% Run Kalman filter with time varying std devs of some shocks
%
% Use the option `Vary=` to temporarily change some of the std deviations
% (or also cross-correlations) within the filtered sample. The estimates of
% unobservables and shocks will obviously change: Compare the estimated
% `Ep` shocks from the previous Kalman filter (with fixed std deviations)
% and the Kalman filter with time-varying `std_Ep`.

j = struct( );
j.std_Er = Series( );
j.std_Er(endHist-9:endHist-5) = 0;

f3 = kalmanFilter(mest, d, startHist:endHist, "override", j);

j = struct( );
j.std_Er = Series();
j.std_Er(endHist-9:endHist-5) = mest.std_Er * 50;

f4 = kalmanFilter(mest, d, startHist:endHist, "override", j);

[j.std_Er, f0.Mean.Er, f3.Mean.Er, f4.Mean.Er] 

ch = databank.Chartpack();
ch.Range = endHist-20:endHist;
ch.Highlight = endHist-9:endHist-5;
ch < access(mest, "transition-shocks");
draw(ch, databank.merge("horzcat", f0.Mean, f3.Mean, f4.Mean));
visual.hlegend("bottom", "Baseline", "Zero", "50x");
visual.heading("Time varying stds for productivity shocks");


%% Evaluate likelihood function and contributions of individual time periods
%
% Run the function `loglik( )` to evaluate the likelihood function. This
% function calls the very same Kalman filter as the function `filter( )`.
% The first output argument returned by `loglik( )` is minus the logarithm
% of the likelihood function; this value is also used as a criterion to be
% minimized (which means maximizing likelihood) within the function
% `estimate( )`.
%
% Set the option `ObjFuncContributions=true` to obtain not only the overall
% likelihood, but also the contributions of individual time periods. They
% are stowed in a column vector with the overall likelihood at the top; the
% length of the vector is therefore $numPer+1$ where $nPer$ is the number of
% periods over which the filter is run.

range = startHist:endHist+10;
numPer = numel(range)

mll = loglik(mest, d, range, "relative", false);
mllc = loglik(mest, d, range, "relative", false, "returnObjFuncContribs", true);

size(mllc) 

%%%
%
% Because there were no observations available in the input database `d` in
% the last 10 periods of the filter range, i.e. `endHist+1:endHist+10`, the
% contributions of these last 10 periods are zero.

mllc


%%%
%
% Adding up the individual contributions reproduces, of course, the overall
% likelihood. The following two numbers are the same (up to rounding
% errors):

mll
sum(mllc)


%%%
%
% Visualize the contributions by converting them to a Series object, and
% plotting as a bar graph. Large bars denote periods where the model
% performed poorly (rememeber, this is MINUS the log likelihood, ie. the
% larger the number the smaller the actual likelihood). Again, the last 10
% periods are zeros because no observations were available in the input
% database in those.

x = Series(range, mllc);
bar(x);
grid on
title("Contributions of individual time periods to (minus log) likelihood");


