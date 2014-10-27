% Produces the modular lower bound of a submodular function F, with
% respect to a set A. If the fourth option pi is not given it generates a
% random permutation

% Author: Rishabh Iyer (rkiyer@u.washington.edu)

% For running the codes, you will need to download the matlab toolbox sfo, written by 
% Andreas Krause (obtainable here - http://users.cms.caltech.edu/~krausea/sfo/), 
% and add it to the matlab path. 


function [ML] = mod_lower(F, A, V, pi)
if(nargin < 3)
    error('Less than 3 arguments provided');
elseif(nargin < 4)
    D = sfo_setdiff_fast(V,A);
    A = A(randperm(length(A)));
    D = D(randperm(length(D)));
    pi = [A, D];
end

n = length(V);
ML = zeros(1,n);
W = [];
oldVal = F(W);
for i = 1:length(pi)
    newVal = F([W pi(i)]);
    ML(pi(i)) = newVal-oldVal;
    oldVal = newVal;
    W = [W pi(i)];
end
end
