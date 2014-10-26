%--------------------------------------------------------------------------
% This function takes the coefficient matrix with few nonzero rows and
% computes the indices of the nonzero rows
% C: MxN coefficient matrix
% thr: threshold value for selecting the nonzero rows of C
%--------------------------------------------------------------------------
% Copyright @ Ehsan Elhamifar, 2014
%--------------------------------------------------------------------------

function sInd = findRepresentatives(C,ratio)

if (nargin < 2)
    ratio = 0.1;
end

N = size(C,1);

r = zeros(1,N);
for i = 1:N
    r(i) = norm(C(i,:),inf);
end
sInd = find(r >= ratio*norm(r,inf));
v = zeros(1,length(sInd));
for i = 1:length(sInd)
    v(i) = norm(C(sInd(i),:),2);
end
[~,pind] = sort(v,'descend');
sInd = sInd(pind);