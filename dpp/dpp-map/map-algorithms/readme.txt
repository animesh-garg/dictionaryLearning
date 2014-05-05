% A description of inputs and outputs for the functions in this folder.
%
% Inputs:
%   S = NxN similarity matrix
%   m = Nx1 vector of match (quality) scores
%   w_m = (scalar) match weight (lambda in the paper)
%   varargin: 0 args for no constraints; 1 arg to specify constraints
%   Match constraints should be given as a 2xN matrix.  Column i specifies
%   the IDs of the elements in pair i.  Ex: [3 1 2; 1 3 1] imposes the
%   constraint that we can't select both pairs 1 and 3 since they share an
%   item.  (The item with ID 1 is the second in each pair.)  Note that IDs 
%   in row 1 refer to a disjoint set of items from the IDs in row 2, so the
%   above example does NOT impose the constraint that only one pair can be
%   selected, even though all pairs include an ID "1".
%
% Objective optimized:
%   log(det(diag(sqrt(exp(w_m * m))) * S * diag(sqrt(exp(w_m * m)))))
%   subject to the constraints specified in varargin                   
%
% Output:
%   C = selected subset of {1, ..., N}