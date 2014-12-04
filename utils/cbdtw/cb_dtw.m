function [ d ] = cb_dtw( X, Y, num_segments,q,flag,verbose)
%CBDTW: correlation based Dynamic Time warping distance
% This file is not optimized. 
% Input:   
%       X: Multivariate time series 1
%       Y: Multivariate time series 2
%         num_segments: desired number of segments
%         q: number of principal compnents to be retained
%         flag: cost type (0: Hotelling (T2), 1: avarage residual error(Q))

% Animesh Garg 2014
if nargin<2
    fprintf('Cannot compute dtw with only 1 input\n');
    
elseif nargin<6
   if ~exist('X','var') || ~exist('Y','var')                     
       fprintf('Cannot compute dtw with only 1 input\n');   
   end
   if ~exist('verbose','var') 
       verbose=false;
   end
   
   if ~exist('num_segments','var')
       num_segments = 15; %DATA DEPENDENT - 15 for the character trajecotry data set.
       if verbose==true
           fprintf('Setting number of desired segments to 15\n');
       end
    end
    
    if ~exist('q','var')
       q = 2; %DATA DEPENDENT - 2 for the character trajecotry data set.
       if verbose==true
           fprintf('Setting number of principal components to consider to 2\n');
       end
   end
   
   if ~exist('flag','var')
       flag = 1; %
       if verbose==true
           fprintf('Setting Error metric to avarage residual error(Q)\n');
       end
   end
end
% turn of warning from pca (some variables of the signatures are linearly dependent when
% segmentation is starting, just suppress this message, not relevant) -> not related to cbdtw logic itself
warning('off', 'stats:pca:ColRankDefX')


Xseg = pcaseg(X, num_segments,q,flag);
Yseg = pcaseg(Y, num_segments,q,flag);
%Compute the distance
d = dtwpca(Xseg, Yseg);

% enable warning again -> not related to cbdtw logic itself
warning('on', 'stats:pca:ColRankDefX')

end

