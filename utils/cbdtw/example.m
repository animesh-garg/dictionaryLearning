% load demo data: four signatures from svc_2004 dataset
% 1st and 2nd from the same person, 3rd is different signature
load svc_2004_demo.mat

% turn of warning from pca (some variables of the signatures are linearly dependent when
% segmentation is starting, just suppress this message, not relevant) -> not related to cbdtw logic itself
warning('off', 'stats:pca:ColRankDefX')

% create segmented representation of each signature
for i = 1 : length(svc_2004_demo)
    % arguments: signature raw data, number of segmentes, number of
    % retained principal components, cost function type (1: residual error)
    signatures{i} = pcaseg(svc_2004_demo{i},20,2,1); %DATA DEPENDENT
    %signatures{i} = pcaseg(svc_2004_demo{i},size(svc_2004_demo{i},1),2,1); 
    %signatures{i} = pcaseg(svc_2004_demo{i},20,size(svc_2004_demo{i},2)-1,1); %Useless
    %signatures{i} = pcaseg(svc_2004_demo{i},size(svc_2004_demo{i},1),size(svc_2004_demo{i},2)-1,1); %useless orginal>different
end

% compute cbdtw between 1st-2nd, 1st-3rd and print it
disp('CBDTW distance of two orignal signatures:');
dtwpca(signatures{1}, signatures{2})

disp('CBDTW distance of the orignal and a different signature:');
dtwpca(signatures{1}, signatures{3})

% enable warning again -> not related to cbdtw logic itself
warning('on', 'stats:pca:ColRankDefX')