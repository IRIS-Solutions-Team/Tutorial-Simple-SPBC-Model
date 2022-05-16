%% Read US macro data from Fred database

close all
clear
%#ok<*VUNUS> 
%#ok<*UNRCH> 

load mat/createModel.mat m


%% Read data from St Louis Fed Fred databank through API

if true
    tic
    d = databank.fromFred.data([
        "GDPC1->y"; "GDPCTPI->py"; "AHETPI->w"; "TB3MS->r3m"
        "GS5->r5y"; "CPILEGNS->cpi_u"; "CPILEGSL->cpi"; "PCEPI->pc"
    ]); 
    toc

    databank.list(d)

    dq = struct( );
    dq.y = d.y;
    dq.py = d.py;

    databank.toCSV(dq, "fred-quarterly.csv", Inf);

    dm = struct( );
    dm.w = d.w;
    dm.r5y = d.r5y;
    dm.r3m = d.r3m;
    dm.cpi_u = d.cpi_u;
    dm.cpi = d.cpi;
    dm.pc = d.pc;

    databank.toCSV(dm, "fred-monthly.csv", Inf);
end

%% Preprocess the data

dq = databank.fromCSV("fred-quarterly.csv");
dm = databank.fromCSV("fred-monthly.csv");

dm.cpi_s = x13.season(dm.cpi_u);

figure( );
plot( apct([dm.cpi_u, dm.cpi_s, dm.cpi]) ); % Period-on-period pct changes annualized

dq.r3m = convert(dm.r3m, Frequency.QUARTERLY, "method", @mean);

func = @(x) convert(x, Frequency.QUARTERLY, "method", @mean);
dq = databank.apply(func, dm, "targetDb", dq);

databank.list(dq)


ch = databank.Chartpack();
ch.Range = qq(1990,1):qq(2019,4);
ch < databank.fieldNames(dq);
draw(ch, dq);


%% Apply conditional Hodrick-Prescott filter to historical data

%{
% filterRange = get(dq.y, "Start") : qq(2025,4);
filterRange = qq(1990,1) : qq(2025,4);

% Plain Vanilla HP
dq.log_y = log(dq.y);
[dq.log_y_tnd, dq.log_y_gap] = hpf(dq.log_y, filterRange);

% HP with trend matching data in 2008-Q3
level = Series( );
level(qq(2008,3)) = dq.log_y(qq(2008,3));
[dq.log_y_tnd1, dq.log_y_gap1] = hpf( ...
    dq.log_y, filterRange, "Level", level ...
);

% HP with growth 4% in 2022-Q4
change = Series( );
change(qq(2022,4)) = 4/400;
[dq.log_y_tnd2, dq.log_y_gap2] = hpf( ...
    dq.log_y, filterRange, "Change", change ...
);

figure( );
plotRange = qq(2008,1) : filterRange(end);
h = plot( ...
    plotRange, ...
    [dq.log_y_tnd, dq.log_y_tnd1, dq.log_y_tnd2, dq.log_y], ...
    "Marker", "s" ...
);
h(end).LineWidth = 5;
h(end).Color = 0.5*[1, 1, 1];

title("Log GDP and HP Trend");
legend("HP", "HP with Trend=Data in 2008-Q3", "HP with trend growth 4% in 2022-Q4", "Data");
%}


%% Create model consistent databank with measurement variables

c = struct( );
c.Short = dq.r3m;
c.Long = dq.r5y;
c.Growth = 100*((dq.y/dq.y{-1})^4 - 1);
c.Infl = apct(dq.cpi);
c.Wage = 100*((dq.w/dq.w{-1})^4 - 1);

ch = databank.Chartpack();
ch.Range = qq(1995,1) : getEnd(c.Short);
ch < access(m, "measurement-variables"); 

draw(ch, c);


%% Save databank to mat file

save mat/prepareDataFromFred.mat c


