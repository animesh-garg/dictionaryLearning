% A bipartite neighbourhood function
% Author: Rishabh Iyer (rkiyer@u.washington.edu)

% Input: Bipartite Graph G (defined as a mxn matrix -- m nodes on LHS and n nodes on RHS) 
% w1 as modular weight vector on the right hand side of the bipartite graph, 
% w2 as modular weight vector on the left hand side, 
% lambda
% covered, which defines the set \Gamma(A), for a given set A \subseteq {1, .., m}

% Output: a submodular function f: 2^{1:m} --> R, defined as f(A) =
% lambda*\sqrt{w1(\Gamma(A))} + w2(V \ A)

function F = sfo_fn_bipartite_nb(G, w1, w2, lambda, covered, type)

[m, n] = size(G);
if strcmp(type, 'sqrt')
    fn = @(A) lambda*sqrt(sum(w1(find_neighbors(G, A, covered)))) + sum(w2(setdiff(1:m, A)));
    F = sfo_fn_wrapper(fn);
elseif strcmp(type, 'log')
    fn = @(A) lambda * log(sum(w1(find_neighbors(G, A, covered)))) + sum(w2(setdiff(1:m, A)));
    F = sfo_fn_wrapper(fn);
elseif strcmp(type, 'one')
    fn = @(A) lambda * sum(w1(find_neighbors(G, A, covered))) + sum(w2(setdiff(1:m, A)));
    F = sfo_fn_wrapper(fn);
end
end
