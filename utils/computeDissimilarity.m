% Computing dissimilarities between sets X and Y
% X: source set of cardinality M
% Y: target set of cardinality N
% dissimilarityType: {'Euc' = \ell_2, 'Euc2' = \ell_2^2, 'L1', 'Chi'}
% D: MxN dissimilarity matrix
%--------------------------------------------------------------------------
% Copyright @ Animesh Garg, 2014
%--------------------------------------------------------------------------

function D = computeDissimilarity(dissimilarityType,X,Y)

if nargin < 3
    fprintf('Setting Y=X, because only two inputs provided');
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

elseif strcmpi(dissimilarityType,'KL_multi')
    if ~iscell(X) || ~iscell(Y)
        fprintf ('Input data not in cell arrays for multidim KL div. \n');
    end
    M = size(X,2);
    N = size(Y,2);
    
    for i = 1:M
        x = X{i}'; %Nxd
        SigmaX = cov(x); 
        muX = mean(x)';
        dim = size(x,2);
        for j = 1: i                        
            y = Y{j}';
            SigmaY = cov(y);
            muY = mean(y)';        
            
            d_ij = 0.5*(trace(pinv(SigmaY)*SigmaX)+ (muX-muY)'*pinv(SigmaY)*(muX-muY)...
                - dim + log(det(SigmaX)/(det(SigmaY)+eps))) ;            
            d_ji =  0.5*(trace(pinv(SigmaX)*SigmaY)+ (muY-muX)'*pinv(SigmaX)*(muY-muX)...
                - dim + log(det(SigmaY)/(det(SigmaX)+eps))) ;            
            
            D(i,j) = d_ji + d_ij;            
            if i ~=j
                D(j,i) = d_ji + d_ij;
            end
        end
    end
    
elseif strcmpi(dissimilarityType,'cbdtw')
    if ~iscell(X) || ~iscell(Y)
        fprintf ('Input data not in cell arrays for multidim CB DTW. \n');
    end
    M = size(X,2);
    N = size(Y,2);
    
    parfor i = 1:M
        tempDist = zeros(1,N);
        x = X{i}';        
        %dim = size(x,2);
        for j = 1: N %saves some computation.                         
            y = Y{j}';                        
            d_ij = cb_dtw (x, y);
            %d_ji = cb_dtw (y, x);            
            tempDist (j)= d_ij;
            %D(i,j) = d_ij;            
            %if i ~=j
              %  D(j,i) = d_ij;
            %end
        end
        D(i,:)= tempDist;
    end    

else
    error('Unknown dissimilarity type!');
    
end