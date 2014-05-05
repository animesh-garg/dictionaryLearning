% In the given graph, finds a path with endpoints of degree 1, if such a
% path exists.  Otherwise, returns an empty array.
function P = find_pipage_path(G)
% Find a node of degree 1.
P = [];
for i = 1:size(G, 1)
  neighbors = find(G(i, :));
  if numel(neighbors) == 1
    P(1) = i;
    P(2) = neighbors(1);
    break;
  end
end

% Follow descendents until reaching another node of degree 1.
neighbors = find(G(P(end), :));
while numel(neighbors) > 1
  % The below for-loop is equivalent to:
  %   neighbors = setdiff(neighbors, P);
  %   P(end + 1) = neighbors(1);
  % but usually faster since most neighbors aren't in P.
  for i = 1:numel(neighbors)
    if numel(find(P == neighbors(i))) == 0
      P(end + 1) = neighbors(i);
      break;
    end
  end
  
  neighbors = find(G(P(end), :));
end