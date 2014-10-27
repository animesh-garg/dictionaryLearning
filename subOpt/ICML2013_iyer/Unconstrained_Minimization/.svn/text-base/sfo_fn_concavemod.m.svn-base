% Concave over Modular functions
% Author: Rishabh Iyer (rkiyer@u.washington.edu)
 
% f(A) = m1(A)^a + lambda*m2(V \ A), a \in (0, 1)

% Input: 
% type: Whether x^a or log x
% value of power a
% m1, m2 as modular functions 
% w2 as modular weight vector on the left hand side, 
% lambda

% Output: a submodular function f: 2^{1:m} --> R, defined as f(A) =
% lambda*\sqrt{w1(\Gamma(A))} + w2(V \ A)

function [F, m1, m2] = sfo_fn_concavemod(n, type, a, lambda, m1, m2)
addpath ../
m = zeros(1, n);
if nargin < 3
    a = 0.5;
end

if strcmp(type, 'cmod')
    fn = @(A) power(sum(m1(A)), a) + lambda*sum(m2(setdiff(1:n, A)));
    F = sfo_fn_wrapper(fn);
elseif strcmp(type, 'log')
    fn = @(A) log(sum(m1(A))) + lambda*sum(m2((setdiff(1:n, A))));
    F = sfo_fn_wrapper(fn);
end
