
close all
clear


load mat/createModel.mat m

m = alter(m, 2);
m.P = [1, 1];
m.A = [1, 1.10];
m = steady(m, "fixLevel", ["P", "A"]);


m = alter(m, 2);
m.W = [1, 1];
m.Y = [1, 1.10];
m = steady(m, "fixLevel", ["W", "Y"]);

table(m, ["steadyLevel", "description", "log"], "writeTable", "xlsx/comparativeStatic.xlsx")


