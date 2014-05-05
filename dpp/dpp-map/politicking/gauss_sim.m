% Computes similarities between all vectors in M1 and M2.
function G = gauss_sim(M1, M2, gauss_sigma, varargin)
assert(numel(varargin) <= 1);

normalizer = 2 * (gauss_sigma^2);
G = zeros(size(M1, 2), size(M2, 2));
for i = 1:size(M1, 2)
  G(i, :) = exp(-sum((bsxfun(@minus, M2, M1(:, i))).^2, 1) / normalizer);
end

% Save results to file if one is provided.
if numel(varargin) == 1
  save(varargin{1}, 'G', '-append');
end