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
debug = true;
getBound = false; 

%Add Data
[X,Y] = loadExamples('uci'); %each time series data point is dxN


%% Calculate dissimilarity
if debug == true
    rng(1);
    nSamples = 100; 
    arrTest = randperm (size(X,2));
    %arrTest = arrTest(1:nSamples); %Not sure if sorting helps
    arrTest = sort (arrTest(1:nSamples));
    Xtest = X(arrTest);
    Ytest = Y.charlabels(arrTest);
    if exist(['D_',dissimilarityType,'_',int2str(nSamples),'.mat'],'file')==2
        D = load (['D_',dissimilarityType,'_',int2str(nSamples),'.mat'],'D');
        D = D.D;
    else
        tic
        D = computeDissimilarity(dissimilarityType, Xtest, Xtest);
        fprintf('Time to compute Similarity Matrix for %d Samples: %5f\n', nSamples, toc);
        D = D ./ max(max(D));%normalize
        save(['D_',dissimilarityType,'_',int2str(nSamples),'.mat'],'D');
    end
else
    Xtest = X;
    Ytest = Y.charlabels;
    if exist(['D_',dissimilarityType,'.mat'],'file')==2
        D = load(['D_',dissimilarityType,'.mat'],'D');
        D = D.D;
    else
        tic
        D = computeDissimilarity(dissimilarityType, Xtest, Xtest);
        fprintf('Time to compute Similarity Matrix for all Data: %5f\n', toc);
        D = D ./ max(max(D)); %normalize
        save(['D_',dissimilarityType,'.mat'],'D');
    end
end

D = real(sqrt(D));
%% Run exp3-scp - Context free stochastic bandit setting 
m = 25;
k = 20;%total 20 chars in dataset.
T = 1000;

% Lt is the returned size m dictionary.
tic
[F,Lt_idx] = exp3_scp(Xtest, m, k, D,T);
fprintf('Mean Score after %4d trials:%5f \n', T,  mean(F));
fprintf('Time to compute dictionary using Submod-EXP3: %5f\n', toc);
fprintf('Using Dissimilarity Type: %s \n', dissimilarityType);
%% retrieve results
Lt = Xtest(Lt_idx);
%Lt_labels = cell2mat(Y.key(Ytest.charlabels(Lt_idx)));
Lt_labels = cell2mat(Y.key(Ytest(Lt_idx)));
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
