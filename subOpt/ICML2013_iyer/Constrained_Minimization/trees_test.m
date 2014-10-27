% Sample test script for monotone submodular minimization subject to spanning trees.

% Author: Rishabh Iyer (rkiyer@u.washington.edu)
%% Concave over modular function

n =  15;
% Clustered graphs
[~, elist] = makeClGraph(n, round(n/8), 5, 4);
m = size(elist, 1);
V = 1:m;
weights = rand(m, 1);
a = round(10*rand())/10;
f = sfo_powmod(weights, a);
MatO = zeros(n, n);
for i = 1 : m
    MatO(elist(i, 1), elist(i, 2)) = weights(i);
    MatO(elist(i, 2), elist(i, 1)) = weights(i);
end
[~, mstcostO] = prim(MatO);
CostcOPT = power(mstcostO, a);
[~, Costcmmin, ~, CostcM] = mmin(f, n, elist, 'MST');
[d] = ellipApp(f, m, 1, 'tmp');
Matd = zeros(n, n);
for i = 1 : m
    Matd(elist(i, 1), elist(i, 2)) = d(i);
    Matd(elist(i, 2), elist(i, 1)) = d(i);
end
[mstd, ~] = prim(Matd);
Ad = convert_set(elist, mstd);
CostcEA = f(Ad);

approxmmin = Costcmmin/CostcOPT;
approxM = CostcM/CostcOPT;
approxEA = CostcEA/CostcOPT;

disp(sprintf('Approximation factor of MMin with CM is %f', approxmmin));
disp(sprintf('Approximation factor of ModUpper with CM is %f', approxM));
disp(sprintf('Approximation factor of EA with CM is %f', approxEA));
    

