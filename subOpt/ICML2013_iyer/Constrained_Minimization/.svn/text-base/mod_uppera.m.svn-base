% Author: Rishabh Iyer (rkiyer@u.washington.edu)

function [off MUa] = mod_uppera(F, A, V)
% Produces the modular upper bound-1 of a submodular function F, with
% respect to a set A. This is a vector of size n plus an offset. Note that
% this is not a normalized vector in the true sense.
n = length(V);
off = 0;
VminusA = sfo_setdiff_fast(V, A);
for i = 1 : length(VminusA)
    j = VminusA(i);
    MUa(j) = F([A, j]) - F(A);
end

for i = 1 : length(A)
    j = A(i);
    Vminusj = setdiff(V, j);
    MUa(j) = F(V) - F(Vminusj);
end
off = F(A) - MUa(A);
end
