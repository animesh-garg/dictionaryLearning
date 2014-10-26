% This function computes the range for the regularization paramter 
% given the dissimilarity matrix
% D: dissimilarity matrix
% q: {2,inf} norm of the mixed L1/Lq norm
% rho_min: minimum value of the the regularization paramter (max # representatives)
% rho_max: maximum value of the regularization paramter (1 representative)
%--------------------------------------------------------------------------
% Copyright @ Ehsan Elhamifar, 2014
%--------------------------------------------------------------------------

function [rho_min, rho_max] = computeRegularizer(D,q)

[Nr,Nc] = size(D);
[~,idx] = min(sum(D,2));

rho_max = -inf;
idxC = setdiff(1:Nr,idx);


if q == 2  
    for i = 1:Nr-1
        v = D(idxC(i),:)-D(idx,:);
        p = sqrt(Nr) * norm(v)^2 / (2*sum(v));
        if (p > rho_max)
            rho_max = p;
        end
    end
elseif q == inf
    for i = 1:Nr-1
        v = D(idxC(i),:)-D(idx,:);
        p = norm(v,1)/2;
        if (p > rho_max)
            rho_max = p;
        end
    end
end   

if (Nr == Nc)
    rho_min = min(min(D+10^10*diag(ones(Nr,1))));
else
    rho_min = min(min(D));
end

