% The asymetric graph cut minus similarity penalty
% lambda is a controlling parameter between 1/2 and 1.

% Author: Rishabh Iyer (rkiyer@u.washington.edu)

function F = sfo_fn_agcpen(G, lambda)
fn = @(A) eval_cut_fn(G,A, lambda);
F = sfo_fn_wrapper(fn);


function C = eval_cut_fn(G,A,lambda)
A = sfo_unique_fast(A);
n = size(G,1);
C = sum(sum(G(A,1:n))) - lambda*sum(sum(G(A, A)));
