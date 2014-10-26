% This function finds clustering of points according to representatives
% Z: MxN probability matrix obtained by DS3
% sInd: index of representatives
% clusters: array indicating the clustering of the columns of dissimilarity
% clusterCenters: array indicating the indices of representatives, which
% become cluster centers
%--------------------------------------------------------------------------
% Copyright @ Ehsan Elhamifar, 2014
%--------------------------------------------------------------------------

function [clusters,clusterCenters] = findClustering(Z,sInd)

N = size(Z,2);
membership = zeros(1,N);
for i = 1:N
    [~,t] = max(Z(sInd,i));
    membership(i) = sInd(t);
end
clusterCenters = unique(membership);
clusters = zeros(1,N);

for i = 1:length(clusterCenters)
    clusters(membership == clusterCenters(i)) = i;
end