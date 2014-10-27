% A basic subgradient based maximization algorithm which picks a random
% subgradient and maximizes it. We provide both the non-adaptive maximizer,
% as well as an adaptive one which is obtained by randomly continuing the
% algorithm.
% Afin is the output of the adaptive one and Arandfin is the output of the
% non-adaptive one.

% Author: Rishabh Iyer (rkiyer@u.washington.edu)

% For running the codes, you will need to download the matlab toolbox sfo, written by 
% Andreas Krause (obtainable here - http://users.cms.caltech.edu/~krausea/sfo/), 
% and add it to the matlab path. 

function [Afin, Arandfin] = sfo_max_randperm(F,V,times, opt)
disp('%%%%%%%%%%%%%%%%')
disp('Starting the Random Permutation schedule')
disp('%%%%%%%%%%%%%%%%')
if ~exist('opt','var')
    opt = sfo_opt;
end
TOL = sfo_opt_get(opt,'ssp_tolerance',1e-6);
best1 = 0;
best2 = 0;
for runs = 1 : times            
    N = length(V);
    pi = V(randperm(N));
    bestVal = 0;
    A = [];
    count = 1;
    while 1
        Hw = sfo_ssp_modular_approx(F,pi);
        H = sfo_fn_wrapper(@(A) sum(Hw(sfo_unique_fast(A))));
        A = sfo_greedy_lazy(H, V, inf);
        curVal = F(A);
        D = sfo_setdiff_fast(V,A);
        A = A(randperm(length(A)));
        D = D(randperm(length(D)));
        pi = [A D];
        if (bestVal == 0)
            Arand = A;
        end
        if curVal > bestVal + TOL
            bestVal = curVal;
        else
            break;
        end
        fprintf('Iteration %d: value is %f\n', count, F(A));
        count = count + 1;
    end
    if (F(A) > best1)
        best1 = F(A);
        Afin = A;
    end
    if (F(Arand) > best2)
        best2 = F(Arand);
        Arandfin = Arand;
    end
end

function H = sfo_ssp_modular_approx(G,pi)
H = zeros(1,max(pi(:)));
W = [];
oldVal = G(W);
for i = 1:length(pi)
    newVal = G([W pi(i)]);
    H(pi(i)) = newVal-oldVal;
    oldVal = newVal;
    W = [W pi(i)];
end

