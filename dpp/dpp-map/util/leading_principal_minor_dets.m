% Computes the determinants of all the leading principal minors of L,
% starting from det(L_{11}) up through det(L).
function dets = leading_principal_minor_dets(L)
% Run Gaussian elimination and record all pivots.
N = size(L, 1);
pivots = zeros(N, 1);
for i = 1:N-1
  % Note that this computation may be unstable if pivots are small.
  pivots(i) = L(i, i);
  scaling = L(i+1:N, i) / pivots(i);
  L(i+1:N, :) = L(i+1:N, :) - bsxfun(@times, L(i, :), scaling);
end
pivots(N) = L(N, N);

% The product of the first n pivots is the determinant of the nth leading
% principal minor.
dets = cumprod(pivots);