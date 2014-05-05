% Checks G for cycles, iterating from start_node to N.  Set start_node to 1
% to check the entire graph. Returns the vertices of a cycle (in order) if
% a cycle is detected.  Else, returns an empty vector.  Also separately
% returns the starting node of the cycle.
function [C, start_node] = contains_cycle(G, start_node)
% Mark each vertex as unvisited.
N = size(G, 1);
M = zeros(N, 1);

% Run the visit subroutine for each node.
for i = start_node:N
  if M(i) == 0
    [visited, M, ~, C] = visit(G, M, zeros(N, 1), [], i);
    if visited
      % Truncate C so that it contains only the cycle,
      % rather than the full DFS path.
      neighbors = find(G(C(end), :));
      for j = numel(C)-2:-1:2
        if any(neighbors == C(j))
          C = C(j:end);
          break;
        end
      end
      start_node = i;
      return;
    end
  end
end


function [visited, M, P, C] = visit(G, M, P, C, v)
% Mark vertex as visited.
M(v) = 1;
C(end + 1) = v;

% Visit its children.
children = find(G(v, :));
for i = 1:numel(children)
  c = children(i);
  if M(c) == 1 && P(v) ~= c
    visited = true;
    return;
  else
    if M(c) == 0
      P(c) = v;
      [visited, M, P, C] = visit(G, M, P, C, c);
      if visited
        return;
      end
    end
  end
end

% Mark as having had all its descendent's visited before it was revisited.
M(v) = 2;
visited = false;
assert(C(end) == v);
C = C(1:end-1);

