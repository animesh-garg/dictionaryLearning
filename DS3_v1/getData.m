function [ X,Y ] = getData( dataFolder )
%GETDATA Summary of this function goes here
%   Detailed explanation goes here
if nargin<1
    fprintf('Creating artifical Circles \n');
    N = 5; %num trajectories
    %lenTraj = 10;%timesteps in each trajectory segment
    lenTraj = 5;
    snr= 0.1;    
    r = 1;
    t = linspace(0,2*pi, 72);
    c = [r*cos(t); r*sin(t)];
    X ={};
    
    numSections = size(c,2) - lenTraj +1;
    for k = 1:N       
        temp = c' + normrnd(0, r*snr, [size(c')]); %add noise to total circle
        %create sliding windows        
        for l = 1:numSections
            %X{k*l} = c(l:l+lenTraj-1, :) + normrnd(0, r*snr, [lenTraj,2]);
            X{(k-1)*numSections+l} = temp(l:l+lenTraj-1, :);
        end        
    end
    fprintf('Making source and target same \n');
    Y = X; 
else    
    fprintf('Nothing here! \n')
    X = [];
    Y = [];
end

end

