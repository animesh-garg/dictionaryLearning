function [ F ] = getF( Lt_idx, D, mode )
sizeL = length(Lt_idx);
L = sort(Lt_idx); %sorting doesnt make a difference. easier to debug
dist = D(L,L);

if ~exist('mode','var')
    mode = 'graph_diameter';
end

switch lower(mode)
    case {'similarity_sum'}
        %1. F is sum of all dissimilarities. Always monotone submodular.
        % but only captures coverage not diversity
        F = sum(sum(dist))/2;

    case {'graph_diameter'}
%2 .define F as the 1-min (||x-y||)/max(||x-y||), for all (x,y) in L_t, x~=y
% NOT monotone? None of the Graph cut measures are monotone. 
% % min_ij = 1;
% % Smin = 0;
% % max_ij = 0;
% % for i = 1: sizeL 
% %     for j = 1: sizeL 
% %         if L(i)~= L(j)
% %             if D(i,j) < min_ij
% %                 min_ij = D(L(i),L(j));
% %                 Smin = Smin + min_ij; 
% %             end
% %         
% %             if D(i,j) > max_ij
% %                 max_ij = D(L(i),L(j));         
% %             end
% %         end
% %     end
% % end
% 
% Smin = sum (min (dist));
% max_ij = max (max (dist));
% 
% %in case all m elements are the same, we should output 0.
% %F = max(0, 1 - (min_ij/max_ij));
% %F = max(0, sizeL - (Smin/max_ij))/sizeL; %non submodular
% F = 1- Smin/max_ij; %non monotone



end

