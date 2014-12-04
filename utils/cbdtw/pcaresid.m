function [cost,pc,avg]  = pcaresid(x,ndim,flag)
% [cost,pc,avg]  = pcaresid(x,ndim,flag)
% pcaresid.m - Computes the cost of a segment
% Created by Zolt?n Bank?, 2006
% Inputs: 
%         x: time series to be segmented (columns: variables)
%         ndim: number of retained principal components
%         flag: cost type (0: Hotelling (T2), 1: avarage residual error(Q))
% Outputs
%         pc: retained principal components of the segment
%         cost: cost of the segment
%         avg: mean of the segment

[m,n] = size(x);
if numel(ndim) > 1
    error('ndim must be a scalar value!');
end
if ndim >= n
    error('ndim must be smaller than the variables (columns) of x!');
end
[pc,score, latent, t2] = princomp(x); % execute principal component analysis
avg = mean(x); % get the avarage of x for each variable (columns)
avgx = repmat(avg,m,1); % just repeat the avarage for each variable for further computation
retain = pc(:,1:ndim)'; % get the retained principal components and transfer their matrices for further useage
predictx = avgx + score(:,1:ndim)*retain; % predicted values of x using the retained principal components
residuals = x - predictx; % get the prediction error for each time stamp
if flag==1
     cost=mean(sum(residuals.^2,2)); % avarage residual error(Q)
else
     cost=mean(t2); % Hotelling (T2)
end   
pc=pc(:,1:ndim); % retained principal components of the segment

