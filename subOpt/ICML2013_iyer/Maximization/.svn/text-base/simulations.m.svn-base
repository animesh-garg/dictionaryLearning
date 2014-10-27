% Contains implementations of different subgradient schedules for unconstrained maximization. 
% They include (see section 6.3 of the paper 'Fast Semidifferential based Submodular Function Optimization')

% 1) Deterministic Local search
% 2) Randomized Local search
% 3) Bi-directional Greedy
% 4) Randomized bi-directional greedy
% 5) Random Permutation
% 6) Random Adaptive
% 7) Random Set

% Author: Rishabh Iyer (rkiyer@u.washington.edu)

% We run this here on random data, and we average it over 2 runs.

% For running the codes, you will need to download the matlab toolbox sfo, written by 
% Andreas Krause (obtainable here - http://users.cms.caltech.edu/~krausea/sfo/), 
% and add it to the matlab path. 
%% Synthetic simulations on random data with asymmetric graph cut functions f(X) = \sum_{i \in X, j \in V} % s_{ij} - lambda \sum_{i, j \in X} s_{ij} 

n = 20;
lambda = 0.7;
aRS = 0;
aRA = 0;
aRP = 0;
aLR = 0;
aRG = 0;
aBG = 0;
aLS = 0;
numtimes = 5;
for times = 1:numtimes
    M = rand(n, n);
    G = triu(M).'+triu(M,1);
    for i = 1 : n
        G(i, i) = 1;
    end

    f = sfo_fn_agcpen(G, lambda);
    V = 1:n;
    A1 = sfo_max_rand(f, V, 5);
    [A2, A3] = sfo_max_randperm(f, V, 5);
    A4 = sfo_randomLS(f,V, 5);
    A5 = sfo_randomgreedymax(f, V, 5, 20);
    A6 = sfo_bidirectional_greedy(f, V, 5);
    A7 = sfo_ls_lazy(f, V);
    OPT = sfo_max_dca_lazy(f, V);
    opt = max([f(A1), f(A2), f(A3), f(A4), f(A5), f(A6), f(A7), f(OPT)]);

    aRS = aRS + f(A1)/opt;
    aRA = aRA + f(A2)/opt;
    aRP = aRP + f(A3)/opt;
    aLR = aLR + f(A4)/opt;
    aRG = aRG + f(A5)/opt;
    aBG = aBG + f(A6)/opt;
    aLS = aLS + f(A7)/opt;
    LR(times) = aLR;
    RA(times) = aRA;
end
disp(sprintf('Approx. factor of Random Set is %f', aRS/numtimes));
disp(sprintf('Approx. factor of Random Permutation is %f', aRP/numtimes));
disp(sprintf('Approx. factor of Random Adaptive is %f', aRA/numtimes));
disp(sprintf('Approx. factor of Randomized Local Search is %f', aLR/numtimes));
disp(sprintf('Approx. factor of Bidirectional Greedy is %f', aBG/numtimes));
disp(sprintf('Approx. factor of Randomized Bidirectional Greedy is %f', aRG/numtimes));
disp(sprintf('Approx. factor of Local Search is %f', aLS/numtimes));
