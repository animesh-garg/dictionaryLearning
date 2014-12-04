function [dist] = dtwpca(seqx,seqy)
% [dist,k,path,D] = dtwpca(seqx,seqy)
% dtwpca.m - Dynamic time warping of previously segmented multivariate time series using 
% the retaind principal components of each segment. The basic distance
% between the segments is 1 - Kranowski similairty of the retained
% principal components
% Note: DTW is not optimized
% Created by Zoltán Bankó, 2005
% Inputs:
%         seqx, seqy: arrays of structure, describe the segmented time series
% Output:     
%         dist = DTW distance of the two multivariate time series

N = length(seqx);
M = length(seqy);

% initialize the cummulated distance matrix
D=Inf*ones(M,N);

% compute dtw
D(1,1)=1-spca(seqx(1).pc,seqy(1).pc); % 1-spca(seqx(1).pc,seqy(1).pc) -> creates distance from Krzanowski-similarity
for i=2:M
  D(i,1) = D(i-1,1) + 1-spca(seqy(i).pc, seqx(1).pc);
end
for i=2:N
  D(1,i) = D(1, i-1)+1-spca(seqy(1).pc, seqx(i).pc);
end

for n=2:N
    for m=2:M
        D(m,n) = min([D(m, n-1) D(m-1, n)  D(m-1, n-1)]) + 1-spca(seqx(n).pc,seqy(m).pc);
    end
end
dist = D(M,N);