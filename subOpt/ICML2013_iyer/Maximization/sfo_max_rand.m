% Random Set Algorithm. Just sample a set uniformly at random. It has a 1/4 approximation guarantee. We do % this many times.

% Author: Rishabh Iyer (rkiyer@u.washington.edu)

% For running the codes, you will need to download the matlab toolbox sfo, written by 
% Andreas Krause (obtainable here - http://users.cms.caltech.edu/~krausea/sfo/), 
% and add it to the matlab path. 

function [Arand] = sfo_max_rand(f, V, times)
Arand = [];
best = 0;
for t = 1 : times
    A = [];
    for i = 1 : length(V)
        if (rand() > 0.5)
            A = [A, i];
        end
    end
    if (f(A) > best)
        best = f(A);
        Arand = A;
    end
end
