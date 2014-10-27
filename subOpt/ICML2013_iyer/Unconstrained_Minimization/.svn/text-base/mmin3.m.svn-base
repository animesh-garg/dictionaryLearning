% Implementation of MMin-III
% Author: Rishabh Iyer (rkiyer@u.washington.edu)

function [A, B] = mmin3(F, V)
% Provides the sets A and B which bound the lattice of minimizers
A = [];
B = [];
fullval = F(V);
for i = 1:length(V)
    if(F(i) - F([]) < 0)
        A = [A, V(i)];
    end
    if(fullval - F(sfo_setdiff_fast(V, i)) <= 0)
        B = [B, i];
    end
end
end