% Auxiliary function for finding the location of a particular name in P.
% Returns which array within P corresponds to name (pidx), how many
% elements are in all the preceeding arrays (num_pre), and the size of 
% name's array (num_docs).
function [pidx, num_pre, num_docs] = locate_name_in_struct(P, name)
pidx = 0;
num_pre = 0;
for i = 1:numel(P)
  if strcmp(P(i).name, name)
    num_docs = numel(P(i).data);
    pidx = i;
    break;
  end
  num_pre = num_pre + numel(P(i).data);
end