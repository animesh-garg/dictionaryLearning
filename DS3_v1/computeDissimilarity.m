% Computing dissimilarities between sets X and Y
% X: source set of cardinality M
% Y: target set of cardinality N
% dissimilarityType: {'Euc' = \ell_2, 'Euc2' = \ell_2^2, 'L1', 'Chi'}
% D: MxN dissimilarity matrix
%--------------------------------------------------------------------------
% Copyright @ Ehsan Elhamifar, 2014
%--------------------------------------------------------------------------

function D = computeDissimilarity(dissimilarityType,X,Y)

if nargin < 3
    Y = X;
end

D = zeros(size(X,2),size(Y,2));

if strcmpi(dissimilarityType,'Euc')
    
    for i = 1:size(X,2)
        for j = 1:size(Y,2)
            D(i,j) = norm(X(:,i)-Y(:,j));
        end
    end
    
elseif strcmpi(dissimilarityType,'Euc2')
    
    for i = 1:size(X,2)
        for j = 1:size(Y,2)
            D(i,j) = norm(X(:,i)-Y(:,j))^2;
        end
    end
    
elseif strcmpi(dissimilarityType,'L1')
    
    for i = 1:size(X,2)
        for j = 1:size(Y,2)
            D(i,j) = norm(X(:,i)-Y(:,j),1);
        end
    end
    
elseif strcmpi(dissimilarityType,'Chi')
    
    for i = 1:size(X,2)
        for j = 1:size(Y,2)
            D(i,j) = 0.5 * sum((X(:,i)-Y(:,j)).^2 ./ (X(:,i)+Y(:,j)+eps));
        end
    end
    
elseif strcmpi(dissimilarityType,'KL')
    
    for i = 1:size(X,2)
        for j = 1:size(Y,2)
            D(i,j) = sum(Y(:,j) .* log2((Y(:,j)+eps) ./ (X(:,i) + eps)));
        end
    end
    
else
    
    error('Unknown dissimilarity type!');
    
end