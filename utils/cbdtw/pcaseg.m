function [segment,tc] = pcaseg(data,num_segments,q,flag)
% [segment,tc] = pcaseg(data,num_segments,q,flag)
% pcaseg.m - Bottom-up segmentation of multivariate time series using PCA based cost functions
% Created by Zoltán Bankó, 2006
% Inputs:
%         data: multivariate time series (columns: variables)
%         num_segments: desired number of segments
%         q: number of principal compnents to be retained
%         flag: cost type (0: Hotelling (T2), 1: avarage residual error(Q))
% Outputs:
%         segment: a szegmentálást leíró struktúra, elemei a szegmensek
%         tc: total cost of the resulted segmentation

minres=ceil(length(data)/200); % initial segmentation -> MUST BE MODIFIED BASED ON YOUR DATA!!!
left_x = 1 : minres : size(data,1)-1; % starting points of the segments
right_x = left_x + minres; % ending points of the segments
right_x(end) = size(data,1); % last element is obviously is the size of the time series
number_of_segments = length(left_x); % intial number of segments

% intialize segments
for i = 1 : number_of_segments
    segment(i).lx = left_x(i);
    segment(i).rx = right_x(i);
    segment(i).mc = inf;
    segment(i).c = inf;
end;
tc=[];

% compute merge costs (i.e. cost of two consecutive segments)
for i = 1 : number_of_segments -1
    sx=data(segment(i).lx :segment(i+1).rx,:);
    segment(i).mc = pcaresid(sx,q,flag); % compute merge cost with the consecutive segment
    sx=data(segment(i).lx :segment(i).rx,:);
    segment(i).c = pcaresid(sx,q,flag); % cost of the segment itself
end
% special handling of the last segment -> no merge cost
sx=data(segment(i+1).lx :segment(i+1).rx,:);
segment(i+1).c = pcaresid(sx,q,flag);

% segments are merged until the desired segment number is not reached
while length(segment) > num_segments
    [temp, i ] = min([segment(:).mc]); % get the minimum of the merge costs
    if i > 1 && i < length(segment) -1 % special case 1: neither the first nor last segment is merged
        segment(i).c=segment(i).mc; % the merge cost of the two segments now become the cost of the merged segment
        sx=data(segment(i).lx :segment(i+2).rx,:);
        segment(i).mc = pcaresid(sx,q,flag); % compute the new merge cost of the currently merged segment and the next one
        segment(i).rx = segment(i+1).rx; % update the last data point of the newly merged segment
        segment(i+1) = []; % delete the second segments of two we just merged
        i  = i - 1; % decrease index
        sx=data(segment(i).lx :segment(i+1).rx,:); 
        segment(i).mc = pcaresid(sx,q,flag); % update the merge cost of the segment in front of the newly merged segment
    elseif i == 1 %  special case 2: first segment is merged
        segment(i).c=segment(i).mc;
        sx=data(segment(i).lx :segment(i+2).rx,:);
        segment(i).mc = pcaresid(sx,q,flag);
        segment(i).rx = segment(i+1).rx;
        segment(i+1) = [];
        sx=data(segment(i).lx :segment(i).rx,:);
        segment(i).c = pcaresid(sx,q,flag);
    else % special case 3: last segment is merged
        segment(i).rx = segment(i+1).rx;
        segment(i).c=segment(i).mc;
        segment(i).mc = inf;
        segment(i+1) = [];
        i = i - 1;
        sx=data(segment(i).lx :segment(i+1).rx,:);
        segment(i).mc = pcaresid(sx,q,flag);
    end
    tc=[tc; sum([segment.c])];
end

% go trough all segments and compute their merge costs (won't be used
% anymore), principal components (will be used to compute the distance of
% the segments) and avarage of the segments (won't be used anymore)
for i = 1 : size(segment,2)
    sx=data(segment(i).lx :segment(i).rx,:);
    [segment(i).mc,segment(i).pc,segment(i).avg] = pcaresid(sx,q,flag);
end
