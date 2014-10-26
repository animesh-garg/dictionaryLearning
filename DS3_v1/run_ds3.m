% This is the main function to run DS3
% X: source set with M elements
% Y: target set with N elements
% D: MxN dissimilarity matrix
% dissimilarityType: pairwise dissimilarity type, {'Euc','Euc2','L1','Chi'}
% if regularized = true, solve:  min  rho ||Z||_{1,p} + tr(D'Z)
%                                s.t. Z>=0, 1^T Z = 1^T
% if regularized = false, solve: min  tr(D'Z)
%                                s.t. Z>=0, 1^T Z = 1^T, ||Z||_{1,p} <= rho
% alpha: if regularized = true,  rho = alpha * rho_max
%        if regularized = false, rho = alpha 
% p: norm used for the mixed L1/Lp norm regularizer, {2,inf}
% verbose: true/false = show/hide optimization steps
%
% Z: MxN probability matrix, nonzero rows of Z indicate indices of
% the representatives
% sInd: array of indices of representatives
% clusters: array of membership of points to clusters
% clusterCenters: array of indices of representatives which become cluster
% centers
%--------------------------------------------------------------------------
% Copyright @ Ehsan Elhamifar, 2014
%--------------------------------------------------------------------------

clc, clear all

dissimilarityType = 'Euc'; % type of pairwise dissimilarities
p = inf; % norm used for L1/Lp optimization in DS3
regularized = true; % true: regularized version, false: constrained version
alpha = 0.1; % regularizer coefficient
verbose = true; % true/false: show/hide optimization steps

% generate source and target sets
randn('state',111)
rand('state',111)
Ng = 35; % number of points in each group
X = [randn(2,Ng)+repmat([-5;0],1,Ng) randn(2,Ng)+repmat([5;0],1,Ng) randn(2,Ng)+repmat([0;5],1,Ng)]; % source set
Y = X; % target set

% compute D
D = computeDissimilarity(dissimilarityType,X,Y);
D = D ./ max(max(D));

% run DS3
if (regularized)
    [rho_min, rho_max] = computeRegularizer(D,p);
    options.verbose = verbose;
    options.rho = alpha * rho_max; % regularization parameter
    options.mu = 1 * 10^-1;
    options.maxIter = 3000;
    options.errThr = 1 * 10^-7;
    Z = ds3solver_regularized(D,p,options);
else
    options.verbose = verbose;
    options.rho = alpha; % regularization parameter
    options.mu = 1 * 10^-1;
    options.maxIter = 3000;
    options.errThr = 1 * 10^-7;
    Z = ds3solver_constrained(D,p,options);
end

% find representatives and clustering
sInd = findRepresentatives(Z);
[clusters,clusterCenters] = findClustering(Z,sInd);

% plotting the results
plot_results(Y,Z,sInd)


