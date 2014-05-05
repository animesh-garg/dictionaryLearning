% Extracts spectral features from G and returns them in V.
function V = spectral_embedding(G, eps_val, gap_size, varargin)
assert(numel(varargin) <= 1);

% Build an epsilon-NN graph.
middles = G(G > 0 & G < 1);
G(G < eps_val * mean(middles) + (1 - eps_val) * max(middles)) = 0;
G = sparse(G);

% Construct unnormalized Laplacian.
D = diag(sum(G));
Lap = D - G;

% Get eigthings for the L_{sym} matrix.
[V, E] = eigs(Lap, D, ceil(sqrt(size(G, 1))), 'sm');
[E, eig_order] = sort(diag(E), 'ascend');
V = V(:, eig_order);

% Look for a gap in the eigenvalues to determine how many to use.
gaps = E(2:end) - E(1:end-1);
gap_loc = numel(E);
for i = 2:numel(gaps)
    if gaps(i - 1) > 0 && gaps(i) > gap_size * mean(gaps(max(1, i - 5):i-1))
        gap_loc = i;
        break;
    end
end
V = V(:, 1:gap_loc)';

% Save results to file if one is provided.
if numel(varargin) == 1
    save(varargin{1}, 'V', '-append');
end