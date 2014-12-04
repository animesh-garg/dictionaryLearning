function [F, Lt_idx] = exp3_scp(S, m, k, D, T)
%exp3 bandits- partial info case
% Algorithm inputs: S (set of all elements), m length of output list, k
% best list size (smallest), 

p{1} = ones(size(S,2),1); %initialize with uniform weights
if ~exist('T','var')
    T= 100; 
end

for t = 1:T
    %% predict a length m sequence L_t (sampling with replacement)
    rng(1)
    [Lt_idx, ~] = datasample([1:size(S,2)],m,'Replace', true, 'Weights', p{t});
    
    %Lt = S(Lt_idx);
    %% estimate F(L_t) on a sampled state iid x_t in D (sequence of x_t's is presampled and fixed throughout)
    % since this is partial info case    
    F(t) = getF(Lt_idx, D);
    
    %% discounted cumulative benefit for each s in S
    Rt = zeros(1,size(S,2));
    for s = 1:size(S,2)       
        for i = 1:m
            Lt_i = Lt_idx(1:i);
            %if s is in Lt_i, then diff is 0
            if ~ismember(s, Lt_i)
                Rt(s) = Rt(s)+ ((1- (1/k))^(m-i))*(getF([Lt_i,s], D)- getF(Lt_i, D));           
            end
        end        
    end
    
    %% Update the prior using exponential weights
    maxR = max(Rt);
    lt = maxR*ones(1,size(S,2))- Rt;
    
    if t<T
        p{t+1} = exp(lt)./sum(exp(lt));
    end
end

Lt = S(Lt_idx);

end
