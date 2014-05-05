% The pipage rounding method of Ageev and Sviridenko (2004).
function X = pipage_rounding(X, f)
% Make 1's and 0's exact.
epsilon = 1e-4;
X = round_x(X, epsilon);

% Build bipartite graph indicated by the nonintegral values.
[idx1, idx2] = is_noninteger(X, epsilon);
idx2 = idx2 + size(X, 1);
[N1, N2] = size(X);
N = N1 + N2;
G = sparse([idx1; idx2], [idx2; idx1], 1, N, N, 2 * numel(idx1));

% Iterate until X is all integer.
prev_nnz = nnz(G);
start_node = 1;
cycles = true;
while nnz(G) > 0
  % Find a cycle in G.
  if cycles
    [path, start_node] = contains_cycle(G, start_node);
    if numel(path) == 0
      cycles = false;
    else
      % If there is a cycle, add the final looping edge.
      path(end + 1) = path(1);
      assert(mod(numel(path), 2) == 1);
    end
  end

  % Or, if no cycle exists, find a path with endpoints of degree 1.
  if ~cycles
    path = find_pipage_path(G);
  end 
  
  % Convert path from nodes to edges.
  path = reshape(path, [], 1);
  path = [path(1:end-1) path(2:end)];
  path = sort(path, 2);
  path = sub2ind(size(X), path(:, 1), path(:, 2) - N1);
  num_edges = numel(path);
  
  % Separate the path into two matchings;
  % every other edge in the path goes into one matching.
  id_m1 = path(1:2:num_edges);
  x_m1 = X(id_m1);
  id_m2 = path(2:2:num_edges);
  x_m2 = X(id_m2);
  
  % Find the maximum changes allowed for these matchings.
  if numel(x_m2) > 0
    eps1 = min(min(x_m1), min(1 - x_m2));
    eps2 = min(min(x_m2), min(1 - x_m1));
  else
    eps1 = x_m1;
    eps2 = 1 - x_m1;
  end
    
  % Check both of the change scenarios to see which gives higher f value.
  X_eps1 = X;
  X_eps1(id_m1) = X_eps1(id_m1) - eps1;
  X_eps1(id_m2) = X_eps1(id_m2) + eps1;
  f_eps1 = f(X_eps1);
  X_eps2 = X;
  X_eps2(id_m1) = X_eps2(id_m1) + eps2;
  X_eps2(id_m2) = X_eps2(id_m2) - eps2;
  f_eps2 = f(X_eps2);
  if f_eps1 > f_eps2
    X = X_eps1;
  else
    X = X_eps2;
  end
  
  % Re-compute which values are noninteger.  
  preroundingX = X;
  X = round_x(X, epsilon);
  old_idx1 = idx1;
  old_idx2 = idx2;
  [idx1, idx2] = is_noninteger(X, epsilon);
  
  % Re-build bipartite graph.
  idx2 = idx2 + size(X, 1);
  G = sparse([idx1; idx2], [idx2; idx1], 1, N, N, 2 * numel(idx1));
  assert(nnz(G) < prev_nnz);
end


function [i_nonint, j_nonint] = is_noninteger(X, epsilon)
[i_nonint, j_nonint] = find((X < 1 - epsilon) & (X > 0 + epsilon));


function x = round_x(x, epsilon)
x(x <= epsilon) = 0;
x(x >= 1 - epsilon) = 1;
