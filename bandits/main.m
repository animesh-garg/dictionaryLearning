%Bandit based disciotnary selection
%ANIMESH GARG
% 29 NOV 2014
%clc
clear all
close all
%Add Utils
addpath(genpath('../utils'));

%dissimilarityType = 'cbdtw'; % type of pairwise dissimilarities
dissimilarityType = 'KL_multi';
debug = false;
getBound = false; 

%Add Data
[X,Y] = loadExamples('uci'); %each time series data point is dxN


%% Calculate dissimilarity
if debug == true
    rng(1);
    nSamples = 500; %only test a and b
    arrTest = randperm (size(X,2));
    arrTest = arrTest(1:nSamples);
    %arrTest = sort (arrTest(1:nSamples));
    Xtest = X(arrTest);
    if exist(['D_',dissimilarityType,'_',int2str(nSamples),'.mat'],'file')==2
        D = load (['D_',dissimilarityType,'_',int2str(nSamples),'.mat'],'D');
        D = D.D;
    else
        D = computeDissimilarity(dissimilarityType, Xtest, Xtest);
        D = D ./ max(max(D));%normalize
        save(['D_',dissimilarityType,'_',int2str(nSamples),'.mat'],'D');
    end
else
    Xtest = X;
    if exist(['D_',dissimilarityType,'.mat'],'file')==2
        D = load(['D_',dissimilarityType,'.mat'],'D');
        D = D.D;
    else
        D = computeDissimilarity(dissimilarityType, Xtest, Xtest);
        D = D ./ max(max(D)); %normalize
        save(['D_',dissimilarityType,'.mat'],'D');
    end
end

%D = real(sqrt(D));
%% Run exp3-scp - Context free stochastic bandit setting 
m = 25;
k = 20;%total 20 chars in dataset.
T = 100;

% Lt is the returned size m dictionary.
[F,Lt_idx]= exp3_scp(Xtest, m, k, D,T);
fprintf('Mean Score after %4d trials:%5f \n', T,  mean(F));

%% retrieve results
Lt = Xtest(Lt_idx);
Lt_labels = cell2mat(Y.key(Y.charlabels(Lt_idx)));
fprintf('\n');
fprintf('Number of distinct elements retrieved: %3d \n', length((unique(Lt_labels))));
fprintf('Following distinct elements were retrieved: ');
fprintf('%c ', unique(Lt_labels));
fprintf('\n');
fprintf('All elements retrieved: ');
fprintf('%c ', sort(Lt_labels));
fprintf('\n');

%% initialize subplots to show all the selected stuff
figure
for i = 1: m 
    subplot (m/5, m/5, sub2ind([m/5,m/5],i));
    temp =Lt{i};
    plot (temp(1,:), temp(2,:),'LineWidth',3);
    title(Lt_labels(i),'FontSize',20) 
    axis square
    set(gca, 'XTickLabelMode', 'manual', 'XTickLabel', []);
    set(gca, 'YTickLabelMode', 'manual', 'YTickLabel', []);
end

%% Evaluate the bound plot for multiple iterations
if getBound
    T = 50:25:500;
    F = zeros(1,length(T));
    parfor t = 1:length(T)    
        % Lt is the returned size m dictionary.
        [temp,~]= exp3_scp(Xtest, m, k, D, T(t));
        F(t) = mean(temp);
        fprintf('Mean Score after %4d trials :%5f \n', T(t), mean(temp));    
    end

    plot(T,F,'LineWidth',5);
    %get ideal score (Ground Truth)
end
