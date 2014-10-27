% Author: Rishabh Iyer (rkiyer@u.washington.edu)

function [off MUa] = mod_upperb(F, A, V)
% Produces the modular upper bound-2 of a submodular function F, with
% respect to a set A. This is a vector of size n plus an offset. Note that
% this is not a normalized vector in the true sense.
n = length(V);
off = 0;
VminusA = sfo_setdiff_fast(V, A);
for i = 1 : length(VminusA)
    j = VminusA(i);
    MUa(j) = F(j) - F([]);
end

for i = 1 : length(A)
    j = A(i);
    Aminusj = setdiff(A, j);
    MUa(j) = F(A) - F(Aminusj);
end
off = F(A) - MUa(A);
end
