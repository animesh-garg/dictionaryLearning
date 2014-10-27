% Author: Rishabh Iyer (rkiyer@u.washington.edu)
% Produces a random set of a given type (tree, path or matching) given the edgeset

function R = rand_set(elist, n, type, varargin)
    switch type
        case 'SP'
            s = varargin{1};
            t = varargin{2};
            m = size(elist, 1);
            weightsR = rand(m, 1);
            CostR = zeros(n, n);
            for i = 1 : m
                CostR(elist(i, 1), elist(i, 2)) = weightsR(i);
                CostR(elist(i, 2), elist(i, 1)) = weightsR(i);
            end
            [~, splist, ~] = shortest_path(CostR, s, t);
            R = convert_set(elist, splist);
        case 'BM'
            m = size(elist, 1);
            weightsR = rand(m, 1);
            CostR = zeros(n, n);
            for i = 1 : m
                CostR(elist(i, 1) - n, elist(i, 2)) = weightsR(i);
            end
            [bmlist, ~] = bipartite_matching(CostR);
            R = convert_set(elist, bmlist);
	case 'ST'
	    m = size(elist, 1);
    	    weightsR = rand(m, 1);
    	    CostR = zeros(n, n);
    	    for i = 1 : m
        	CostR(elist(i, 1), elist(i, 2)) = weightsR(i);
        	CostR(elist(i, 2), elist(i, 1)) = weightsR(i);
    	    end
    	    [mstR, mstcostR] = prim(CostR);
    	    R = convert_set(elist, mstR);
    end
