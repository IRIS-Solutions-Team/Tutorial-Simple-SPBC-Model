
close all
clear

%{
d = databank.fromFred({ 
    'GDPC1->y', 'GDPCTPI->ny', 'AHETPI->w', 'TB3MS->r3m', ...
    'GS5->r5y', 'CPILEGNS->cpi_u', 'CPILEGSL->cpi'
});

databank.list(d)

dq = struct( );
dq.y = d.y;
dq.ny = d.ny;

databank.toCSV(dq, 'Quarterly.csv', Inf);

dm = struct( );
dm.w = d.w;
dm.r5y = d.r5y;
dm.r3m = d.r3m;
dm.cpi_u = d.cpi_u;
dm.cpi = d.cpi;

databank.toCSV(dm, 'Monthly.csv', Inf);
%}

dq = databank.fromCSV('Quarterly.csv');
dm = databank.fromCSV('Monthly.csv');

dm.cpi_s = x13(dm.cpi_u);

figure( );
% plot( pct([dm.cpi_s, dm.cpi]) ); % Period-on-period pct changes
plot( apct([dm.cpi_u, dm.cpi_s, dm.cpi]) ); % Period-on-period pct changes annualized

dq.r3m = convert(dm.r3m, Frequency.QUARTERLY, Inf, 'Method=', @mean);

func = @(x) convert(x, Frequency.QUARTERLY, Inf, 'Method=', @mean);
dq = databank.apply(func, dm, 'AddToDatabank=', dq);

databank.list(dq)

% yy( ), hh( ), qq( ), mm( ), ww( ), dd( )

plotRange = qq(1990,1) : qq(2019,4);
dbplot(dq, plotRange, fieldnames(dq), 'Tight=', true);

                                                                           
%% Hodrick-Prescott Filter with Conditioning
%{
% filterRange = get(dq.y, 'Start') : qq(2025,4);
filterRange = qq(1990,1) : qq(2025,4);

% Plain Vanilla HP
dq.log_y = log(dq.y);
[dq.log_y_tnd, dq.log_y_gap] = hpf(dq.log_y, filterRange);

% HP with trend matching data in 2008-Q3
level = Series( );
level(qq(2008,3)) = dq.log_y(qq(2008,3));
[dq.log_y_tnd1, dq.log_y_gap1] = hpf( ...
    dq.log_y, filterRange, 'Level=', level ...
);

% HP with growth 4% in 2022-Q4
change = Series( );
change(qq(2022,4)) = 4/400;
[dq.log_y_tnd2, dq.log_y_gap2] = hpf( ...
    dq.log_y, filterRange, 'Change=', change ...
);

figure( );
plotRange = qq(2008,1) : filterRange(end);
h = plot( ...
    plotRange, ...
    [dq.log_y_tnd, dq.log_y_tnd1, dq.log_y_tnd2, dq.log_y], ...
    'Marker=', 's' ...
); 
h(end).LineWidth = 5;
h(end).Color = 0.5*[1, 1, 1];

title('Log GDP and HP Trend');
legend('HP', 'HP with Trend=Data in 2008-Q3', 'HP with trend growth 4% in 2022-Q4', 'Data');
%}

%% Model Consistent Databank with Measurement Variables


c = struct( );
c.Short = dq.r3m;
c.Long = dq.r5y;
c.Growth = 100*((dq.y/dq.y{-1})^4 - 1); % equivalent to apct(dq.y)
c.Infl = apct(dq.ny); %100*((dq.ny/dq.ny{-1})^4 - 1); % equivalent to apct(dq.py)
c.Wage = 100*((dq.w/dq.w{-1})^4 - 1); % equivalent to apct(dq.w)

dbplot(c, qq(1970,1):qq(2019,4), fieldnames(c));

save mat/read_fred_data.mat c


