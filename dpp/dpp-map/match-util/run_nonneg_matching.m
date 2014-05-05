% Solves the linear assignment problem for the given cost matrix.
function P_new = run_nonneg_matching(costs)

%% Format cost matrix as required by the matching algorithm.

% Add dummy nodes with cost zero; only pairs with negative cost should
% be kept in the end.
[r, c] = size(costs);
costs = [costs; zeros(c, c)];

% Make cost matrix positive with min cost of zero.
min_cost = min(costs(:));
assert(~isinf(min_cost));
costs = costs - min_cost;

% Ensure min cost is slightly above zero.  (Important so that dummy nodes
% added below will have strictly less cost than any real node.)
non_inf_ids = ~isinf(costs);
max_cost = max(costs(non_inf_ids));
if max_cost == 0
  max_cost = 1;
end
costs = costs + max_cost * 1e-3;

% Change +inf values to large numbers.
max_cost = sum(sum(costs(non_inf_ids)));
costs(isinf(costs)) = max_cost;

% Make cost matrix square by adding dummy nodes with cost zero.
[r1, c1] = size(costs);
diff = r1 - c1;
if diff > 0
  costs = [costs zeros(r1, diff)];
else
  if diff < 0
    costs = [costs; zeros(-diff, c1)];
  end
end

%% Run the matching and re-format the results into row and col ids.
m1 = lap_double(costs);
[row_sol, col_sol] = find(m1);
[row_sol, order] = sort(row_sol, 'ascend');
row_sol = row_sol(1:r);
col_sol = col_sol(order);
col_sol = col_sol(1:r);

%% Keep matches between non-dummy nodes.
keepers = find(col_sol <= c);
row_ids = row_sol(keepers);
col_ids = col_sol(keepers);
P_new = zeros(r, c);
sol_idxs = sub2ind(size(P_new), row_ids, col_ids);
P_new(sol_idxs) = 1;

%% Check at-most-1-to-1 constraint.
assert(all(sum(P_new, 1) <= 1));
assert(all(sum(P_new, 2) <= 1));