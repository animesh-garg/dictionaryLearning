% This function solves the shrinkage/thresholding problem for different
% norms p in {1, 2, inf}
%--------------------------------------------------------------------------
% Copyright @ Ehsan Elhamifar, 2014
%--------------------------------------------------------------------------

function C2 = shrinkL1Lp(C1,lambda,p)

C2 = [];
if ~isempty(lambda)
    [D,N] = size(C1);
    if (p == 1)
        C2 = max(abs(C1)-repmat(lambda,N,1),0) .* sign(C1);
    elseif (p == 2)
        r = zeros(D,1);
        for j = 1:D
            r(j) = max(norm(C1(j,:))-lambda(j),0);
        end
        C2 = repmat(r./(r+lambda'),1,N) .* C1;
    elseif(p == inf)
        C2 = zeros(D,N);
        for j = 1:D
            C2(j,:) = L2_Linf_shrink(C1(j,:)',lambda(j))';
        end
    end
end