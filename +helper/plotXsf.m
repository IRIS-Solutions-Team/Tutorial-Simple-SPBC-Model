function helper_plot_xsf(freq, xv, xm)

freq = double(freq);
xv = double(xv);
xm = double(xm);

xv = xv(:);
xm = xm(:);

plot(freq, real(xv), 'linewidth', 2);
hold on
plot(freq, real(xm), 'linewidth', 2);
set(gca(), 'xlim', [0, pi], 'xLimMode', 'manual');
grid on

end%

