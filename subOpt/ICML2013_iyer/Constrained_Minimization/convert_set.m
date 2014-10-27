% Author: Rishabh Iyer (rkiyer@u.washington.edu)

function [A] = convert_set(elist, currlist)
% Convert a list of edges to a set where the ground set is enteries in
% elist
A = [];
for i = 1:size(currlist, 1)
    for j = 1 : size(elist, 1)
        if( ((currlist(i, 1) == elist(j, 1)) && (currlist(i, 2) == elist(j, 2)))...
                || ((currlist(i, 2) == elist(j, 1)) && (currlist(i, 1) == elist(j, 2))))
            A = [A, j];
        end
    end
end

end
