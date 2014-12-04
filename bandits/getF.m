function [ F ] = getF( Lt_idx, D )
%define F as the 1-min (||-x-y||)/max(||x-y||), for all (x,y) in L_t, x~=y
% Provably monotone submodular (Contextual Sequence Prediction by dey et al 2012.)

min_ij = 1;
max_ij = 0;
L = sort(Lt_idx);
for i = 1: length(Lt_idx)
    for j = 1: length(Lt_idx)
        if L(i)~= L(j)
            if D(i,j) < min_ij
                min_ij = D(L(i),L(j));
            end
        
            if D(i,j) > max_ij
                max_ij = D(L(i),L(j));         
            end
        end
    end
end

%in case all m elements are the same, we should output 0.
F = max(0, 1 - (min_ij/max_ij));

end

