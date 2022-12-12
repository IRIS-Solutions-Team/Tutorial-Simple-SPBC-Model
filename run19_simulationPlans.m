
close all
clear

load mat/createModel.mat m

d = databank.forModel(m, 1:20);

d.Ey(1) = 0.10;

s1 = simulate( ...
    m, d, 1:20 ...
    , prependInput=true ...
    , method="stacked" ...
);

s2 = simulate( ...
    m, d, 1:20 ...
    , prependInput=true ...
    , method="stacked" ...
    , terminal="data" ...
);


% Combine anticipated/unanticipated swaps

d = databank.forModel(m, 1:20);

p = Plan.forModel(m, 1:20);

p = anticipate(p, true, ["dP", "Ep"]);
p = anticipate(p, false, ["Y", "Ey"]);

p = swap(p, 3, ["dP", "Ep"]);
p = swap(p, 2, ["Y", "Ey"]);

d.dP(3) = d.dP(3) * 1.05;
d.Y(2) = d.Y(2) * 1.05;

[s, info, frames] = simulate( ...
    m, d, 1:20 ...
    , plan=p ...
    , prependInput=true ...
    , method="stacked" ...
);


%% Conditioning

d = databank.forModel(m, 1:20);

p = Plan.forModel(m, 1:20, method="condition");

p = exogenize(p, 1:4, "R");
p = endogenize(p, 1:4, ["Ep", "Ey"]);

p = assignSigma(p, 1:3, "Ep", 0.05);
p = assignSigma(p, 4, "Ep", 0.01);
p = assignSigma(p, 1:3, "Ey", 0.02);
p = assignSigma(p, 4, "Ey", 0.06);

d.R(1:4) = d.R(1:4) * 1.01;

s = simulate( ...
    m, d, 1:20 ...
    , plan=p ...
    , prependInput=true ...
    , method="stacked" ...
    , solver="qnsd" ...
);

ch = Chartpack();
ch.Range = 0:20;
ch.PlotSettings = {"marker", "s"};
ch + ["R", "dP", "Y", "Ep", "Ey"];
draw(ch, databank.merge("horzcat", d, s));


