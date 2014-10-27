% Sample test script for monotone submodular minimization subject to matchings.

% Author: Rishabh Iyer (rkiyer@u.washington.edu)

%% Concave over modular (CM) functions
n =  8;
% Clustered graphs
[~, elist] = makeClGraph(2*n, 0, 2*n + round(2*n*rand()), 2); 
m = size(elist, 1);
V = 1:m;
weights = rand(m, 1);
a = round(10*rand())/10;
f = sfo_powmod(weights, a);
MatO = zeros(n, n);
for i = 1 : m
    MatO(elist(i, 1) - n, elist(i, 2)) = weights(i);
end
[~, mcostO] = bipartite_matching(MatO);
CostOPT = power(mcostO, a);
[~, Costmmin, ~, CostM] = mmin(f, n, elist, 'BM');
[d] = ellipApp(f, m, 1, 'tmp');
Matd = zeros(n, n);
for i = 1 : m
    Matd(elist(i, 1) - n, elist(i, 2)) = d(i);
end
[matchingd, ~] = bipartite_matching(Matd);
Ad = convert_set(elist, matchingd);
CostEA = f(Ad);

approxmmin = Costmmin/CostOPT;
approxM = CostM/CostOPT;
approxEA = CostEA/CostOPT;

disp(sprintf('Approximation factor of MMin with CM is %f', approxmmin));
disp(sprintf('Approximation factor of ModUpper with CM is %f', approxM));
disp(sprintf('Approximation factor of EA with CM is %f', approxEA));

