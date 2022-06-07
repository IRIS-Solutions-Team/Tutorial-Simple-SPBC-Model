function plotAcf(xnv,xv,xm)

xnv = double(xnv);
xv = double(xv);
xm = double(xm);

xm = xm(:);
xv = xv(:);
xnv = xnv(:);

histogram(xnv, "normalization", "pdf");
hold on

co = get(gca(), "colorOrder");
height = get(gca(), "yLim");
height = height(2);
stem(xv, height, "color", co(1, :), "lineWidth", 3);
stem(xm, height, "color", co(2, :), "lineWidth", 3); 

grid on

end%

