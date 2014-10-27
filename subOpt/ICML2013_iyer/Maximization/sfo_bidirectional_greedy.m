% An implementation of the bidirectional greedy algorithm of Buchbinder et al, 2012. It can be seen as an instance of the subgradient framework with a particular subgradient schedule.

% Author: Rishabh Iyer (rkiyer@u.washington.edu)

function OPTset = sfo_bidirectional_greedy(f,V,numiter, opt) 
    disp('%%%%%%%%%%%%%%%%')
    disp('Starting the Bi-directional Greedy schedule')
    disp('%%%%%%%%%%%%%%%%')

    % numiter is the number of times to try this
    if ~exist('opt','var')
        opt = sfo_opt;
    end
    n=length(V);
    TOL = sfo_opt_get(opt,'ls_tolerance',1e-6);
    BestVal = 0;
    for times = 1 : numiter
        A = [];
        B = V;
        pi = V(randperm(n));
        for i = 1 : length(V)
            alpha = max(f([A, pi(i)]) - f(A), 0);
            beta = max(f(setdiff(B, pi(i))) - f(B), 0);
            if (alpha >= beta)
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
