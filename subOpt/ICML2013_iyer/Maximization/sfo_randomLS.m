% An iterative algorithm which chooses a random subgradient except for two
% positions fixed deterministically. We continue iterations here until
% convergence.

% This is the randomized local search heuristic in our paper

% Author: Rishabh Iyer (rkiuer@u.washington.edu)

function Abest = sfo_randomLS(F,V,numiter, opt)
disp('%%%%%%%%%%%%%%%%')
disp('Starting the Random Local search schedule')
disp('%%%%%%%%%%%%%%%%')
if ~exist('opt','var')
    opt = sfo_opt;
end
TOL = sfo_opt_get(opt,'ssp_tolerance',1e-6);

N = length(V);
pi = V(randperm(N));
A = [];
Abest = [];
cumbest = 0;
for times = 1 : numiter
    bestVal = 0;
    count = 0;
    while 1
        Hw = sfo_ssp_modular_approx(F,pi);
        H = sfo_fn_wrapper(@(A) sum(Hw(sfo_unique_fast(A))));
        A = sfo_greedy_lazy(H, V, inf);
        curVal = F(A);
        D = sfo_setdiff_fast(V,A);
        diff = zeros(length(A));
        for j = 1 : length(A)
            diff(j) = F(setdiff(A, A(j))) - F(A);
        end
        [~, k] = max(diff);
        Ak = setdiff(A, A(k));
        addel = zeros(length(D));
        for j = 1 : length(D)
            addel(j) = F([A, D(j)]) - F(A);
        end
        [~, l] = max(addel);
        Dl = setdiff(D, D(l));
        D = [D(l), Dl(randperm(length(Dl)))];
        A = [Ak(randperm(length(Ak))), A(k)];
        pi = [A, D];
        if curVal>bestVal+TOL
            bestVal = curVal;
        else
            break;
        end
        fprintf('Iteration %d: value is %f\n', count, F(A));
        count = count + 1;
    end
    if (F(A) > cumbest)
        Abest = A;
        cumbest = F(A);
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

