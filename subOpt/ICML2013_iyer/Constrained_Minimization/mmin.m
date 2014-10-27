% Algorithm MMin-I from section 5.2 of the paper 'Fast Semi-differential based Submodular function optimization'. 

% Author: Rishabh Iyer (rkiyer@u.washington.edu)

function [St, Cost, A, CostM] = mmin(f, n, elist, type, varargin)
% St - Combinatorial structure - List of edges (for example in shortest
%       path - edges of path, MST - edge list of the tree etc.
% Cost - Cost of the choice
% A - Set of edges
% f - handle to the submodular function (defined on the edges)
% n - number of nodes in a graph
% elist - edge list
% type - type of the constraint (for e.g MST, SP, BM, Cuts)
epsilon = 1e-8;
A = [];
m = size(elist, 1);             % m is number of edges
V = [1:m];                      % V is the ground set of the submod function
switch type
    case 'MST'
        while(1)
            [~, MUa] = mod_uppera(f, A, V);
            CurrCostA = zeros(n, n);
            for i = 1:m
                % To prevent numerical instability we add 0.00001
                CurrCostA(elist(i, 1), elist(i, 2)) = MUa(i) + 0.00001;
                CurrCostA(elist(i, 2), elist(i, 1)) = MUa(i) + 0.00001;
            end
            [mstA, ~] = prim(CurrCostA);
            Anew = convert_set(elist, mstA);
            f(Anew)
            if (isempty(A))
                A = Anew;
                CostM = f(A);
            elseif ((f(A) - f(Anew) > epsilon))
                A = Anew;
            else
                break;
            end
            %f(A)
        end    
        St = mstA;
        Cost = f(A);
    case 'SP'
        s = varargin{1};
        t = varargin{2};
        while(1)
            [~, MUa] = mod_uppera(f, A, V);
            CurrCostA = zeros(n, n);
            for i = 1:m
                % To prevent numerical instability we add 0.00001
                CurrCostA(elist(i, 1), elist(i, 2)) = MUa(i) + 0.00001;
                CurrCostA(elist(i, 2), elist(i, 1)) = MUa(i) + 0.00001;
            end
            [~, splist, ~] = shortest_path(CurrCostA, s, t);
            Anew = convert_set(elist, splist);
            f(Anew)
            if (isempty(Anew))
                A = Anew;
                CostM = 0;
                break;
            elseif (isempty(A))
                A = Anew;
                CostM = f(A);
            elseif ((f(A) - f(Anew) > epsilon))
                A = Anew;
            else
                break;
            end
            %f(A)
        end    
        St = splist;
        Cost = f(A);  
    case 'BM'
        while(1)
            [~, MUa] = mod_uppera(f, A, V);
            CurrCostA = zeros(n, n);
            for i = 1:m
                % To prevent numerical instability we add 0.00001
                CurrCostA(elist(i, 1) - n, elist(i, 2)) = MUa(i) + 0.00001;
            end
            [bmlist, ~] = bipartite_matching(CurrCostA);
            Anew = convert_set(elist, bmlist);
            f(Anew)
            if (isempty(Anew))
                A = Anew;
                CostM = 0;
                break;
            elseif (isempty(A))
                A = Anew;
                CostM = f(A);
            elseif (f(A) - f(Anew) > epsilon)
                A = Anew;
            else
                break;
            end
            %f(A)
        end    
        St = bmlist;
        Cost = f(A);  
    case 'MUB'
        while(1)
            k = varargin{1};
            [~, MUa] = mod_uppera(f, A, V);
            [~, sortedindices] = sort(MUa, 'ascend');
            Anew = sortedindices(1:round(k));
            if (isempty(A))
                A = Anew;
                CostM = f(A);
            elseif ((f(A) - f(Anew) > epsilon))
                A = Anew;
            else
                break;
            end
            %f(A)
        end    
        St = [];
        Cost = f(A);
end        
end

