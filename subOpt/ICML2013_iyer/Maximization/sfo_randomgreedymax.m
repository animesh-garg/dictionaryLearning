% An implementation of the Randomized Bi-directional Greedy from Buchbinder et al, 2012. This algorithm can be seen as an instance of our framework (see Section 6.1).

% Author: Rishabh Iyer (rkiyer@u.washington.edu)

% For running the codes, you will need to download the matlab toolbox sfo, written by 
% Andreas Krause (obtainable here - http://users.cms.caltech.edu/~krausea/sfo/), 
% and add it to the matlab path. 

function OPTset = sfo_randomgreedymax(f,V,numiterout, numiterin, opt) 
    disp('%%%%%%%%%%%%%%%%')
    disp('Starting the Randomized bi-directional greedy schedule')
    disp('%%%%%%%%%%%%%%%%')

    if ~exist('opt','var')
        opt = sfo_opt;
    end
    n=length(V);
    TOL = sfo_opt_get(opt,'ls_tolerance',1e-6);
    BestVal = 0;
    for times = 1 : numiterout
        A = [];
        B = V;
        pi = V(randperm(n));
        for j = 1: numiterin
            for i = 1 : length(V)
                alpha = max(f([A, pi(i)]) - f(A), 0);
                beta = max(f(setdiff(B, pi(i))) - f(B), 0);
                p = alpha/(alpha + beta);
                if (isnan(p) || isinf(p))
                    p = 1;
                end
                if (binornd(1, p) == 1)
                    A = [A, pi(i)];
                else 
                    B = setdiff(B, pi(i));
                end
            end	
            if (f(A) > BestVal + TOL)
                OPTset = A;
                BestVal = f(A);
            end
        end
    end
