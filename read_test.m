
clear
close all
m = model('test.model');
m = sstate(m);
m = solve(m);

