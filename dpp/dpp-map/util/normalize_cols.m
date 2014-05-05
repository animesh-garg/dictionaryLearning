% Normalizes M so each column has 2-norm of 1.
function [Mnorm, nonzero_cols] = normalize_cols(M)
totals = sum(M.^2, 1);
nonzero_cols = find(totals ~= 0);
Mnorm = bsxfun(@rdivide, M, sqrt(totals));