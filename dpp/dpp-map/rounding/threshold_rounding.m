% Sorts the elements of x and iteratives, each iteration rounding up the
% next largest value in x to 1.  Checks det(L(x)) and the constraints each
% iteration and returns the highest-scoring x that satisfies the
% constraints.
function y = threshold_rounding(x, L, verify_constraints)
% Round near-integer to integer.
epsilon = 1e-4;
zero_ids = find(x <= epsilon);
x(zero_ids) = 0;
one_ids = find(x >= 1 - epsilon);
x(one_ids) = 1;
num_ones = numel(one_ids);
num_frac = numel(x) - numel(zero_ids) - num_ones;
if num_frac == 0
  y = x;
  return;
end

% Sort non-integer in descending order.
frac_ids = setdiff(1:numel(x), zero_ids);
frac_ids = setdiff(frac_ids, one_ids);
[~, order] = sort(x(frac_ids), 'descend');
frac_ids = frac_ids(order)';

% Revise the kernel, conditioning on the inclusion of the rows
% corresponding to x == 1 and the exclusion of the x == 0 rows.
inc_ids = [one_ids; frac_ids];
L = inv(L(inc_ids, inc_ids) + diag([zeros(num_ones, 1); ones(num_frac, 1)]));
L = inv(L(num_ones+1:end, num_ones+1:end)) - eye(num_frac);

% Get a baseline solution by rounding all fractional elements to zero.
% (This should satisfy the constraints as long as they are down-monotone.)
y = x;
y(frac_ids) = 0;
assert(verify_constraints(y));
best_y = y;
fs = leading_principal_minor_dets(L);
best_f = 0; % log det empty set

% Round the next largest non-integer up to 1 each iteration and store the
% objective value if it's the best found so far and the constraints are
% satisfied.
for i = 1:numel(frac_ids)
  next_index = frac_ids(i);
  y(next_index) = 1;
  if verify_constraints(y)
    next_f = fs(i);
    if next_f > best_f
      best_y = y;
      best_f = next_f;
    end
  else
    break;
  end
end

y = best_y;