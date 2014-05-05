% Approximates the MAP of the specified DPP by gradient descent on the
% softmax objective, starting from the all-zeros vector.  See readme.txt in
% this folder for a description of inputs and output.  A "% *" comment
% below indicates a parameter that can be tuned.  A "% Debugging." comment
% below indicates a check that can be turned on to help diagnose issues.
function C = softmax(S, m, w_m, varargin)
nvars = numel(varargin);
assert(nvars == 0 || nvars == 1);

%% Integrate the match score with the DPP score.
if numel(m) ~= size(m, 1)
  m = m';
end
m = sqrt(exp(w_m * m));
% Note: Using bsxfun is faster than setting M = diag(m) and multiplying
%       L = M * S * M.  (In general, diag is slower than bsxfun.)
L = bsxfun(@times, bsxfun(@times, m, S), m);

%% Zeros initialization (which obeys the at-most-1:1 property).
N = size(L, 1);
p = zeros(N, 1);

%% If not enforcing 1:1, we can just run LBFGS.
if nvars == 0
  opts = lbfgs_options('iprint', 0, 'maxits', 100000, ...  % *
    'factr', 1, 'pgtol', 1e-10);  % **
  p = lbfgs(@(p) (neg_objective_and_gradient(L, p)), ...
    p, zeros(size(p)), ones(size(p)), 2*ones(size(p)), opts);
  
  % Allowed deviation from integer value.
  p_tol = 0.1;  % *
  
  % Solution should already be integer.  If it's not, try increasing
  % 'maxits' above.
  if ~all((p < p_tol) | (p > 1 - p_tol));
    % If not all integer, start from the endpoint and continue
    % optimizing.  (Convergence criteria are different starting from the
    % endpoint.)
    p = lbfgs(@(p) (neg_objective_and_gradient(L, p)), ...
      p, zeros(size(p)), ones(size(p)), 2*ones(size(p)), opts);
    
    % If still not all integer, we could re-start lbfgs again from the
    % endpoint, but for now we'll raise an exception in this case.
    assert(all((p < p_tol) | (p > 1 - p_tol)));
  end
  
  C = find(p > 0.5);
  return;
end

%% Read in 1:1 constraints.
uv = varargin{1};

% Make sure the numbers in uv are as compact as possible.
[us, ~, u_map] = unique(uv(1, :));
[vs, ~, v_map] = unique(uv(2, :));
num_us = numel(us);
num_vs = numel(vs);
uv = sub2ind([num_us, num_vs], u_map, v_map);
%non_uv = setdiff(1:(num_us * num_vs), uv);  % Debugging.

% Check to see if there are duplicate pairs.
unique_uv = unique(uv);
num_unique_uv = numel(unique_uv);
dups_exist = num_unique_uv ~= numel(uv);
if dups_exist
  dup_groups = cell(num_unique_uv, 1);
  for i = 1:num_unique_uv
    dup_groups{i} = find(uv == unique_uv(i));
  end
end

% Set up the cost matrix for matching.
% (Cost > 0 ensures a pair will not be chosen.)
costs = Inf * ones(num_us, num_vs);

%% Initialize optimization parameters.
% Larger values of obj_eps and p_eps result in faster convergence.
obj_eps = 1e-5;  % *
p_eps = 1e-4;  % *
% Variable p_tol is useful for debugging and determines deviation from
% exact 1:1ness that will result in termination of the program.
p_tol = 1e-4;  % *
verify = @(p) verify_1to1(p, us, vs, u_map, v_map, p_tol);
% Variable df_tol determines allowed deviation from the requirement that
% p_new only be 1 where df > 0.
df_tol = 1e-5;  % *
% Larger step_df_tol allows for more leniency when judging whether p is
% on the boundary of the polytope or not.
step_df_tol = 1e-6;  % *
% Line search parameters.
prev_step = 1.0;  % *
max_line_search_iters = 1000;  % *
max_step = 1.0;  % *
step_eps = 0.001;  % *
% Set relatively loose search parameters.
c1 = 1e-4;  % * (Smaller is looser.)
c2 = 0.9;  % * (Larger is looser.)
wolfe_handle = @(in0, in1, in2, in3, in4, in5, in6) wolfe_line_search( ...
  @(p) neg_objective(L, p), in0, in1, in2, in3, in4, in5, c1, c2, in6, ...
  max_step, step_eps, max_line_search_iters);
% Larger debug_interval makes for less debugging information.
%debug_interval = 100;  % Debugging.

%% Iterate until convergence.
iters = 0;
f = -Inf;
old_obj = f;
while 1
  iters = iters + 1;
  p_old = p;
  
  %% Compute current objective and gradient values.
  if iters == 1
    [f, df, M] = objective_and_gradient(L, p);
  else
    df = gradient_given_m(L, M);
  end
  %if mod(iters, debug_interval) == 1  % Debugging.
  %  fprintf('Objective: %f\n', f);  % Debugging.
  %end  % Debugging.
  
  %% Break if change in objective is small.
  if (f - old_obj < obj_eps * abs(old_obj))
    break;
  end
  
  %% Enforce 1:1 constraints by running a matching algorithm.
  if dups_exist
    max_ids = zeros(num_unique_uv, 1);
    for i = 1:num_unique_uv
      group = dup_groups{i};
      [costs(unique_uv(i)), max_ids(i)] = max(df(group));
      max_ids(i) = group(max_ids(i));
    end
    costs(unique_uv) = -costs(unique_uv);
    P_new = run_nonneg_matching(costs);
    p_new = zeros(N, 1);
    p_new(max_ids) = P_new(unique_uv);
  else
    costs(uv) = -df;
    P_new = run_nonneg_matching(costs);
    p_new = P_new(uv)';
  end
  
  % Check no weight got placed on non-uv pairs.
  %assert(all(P_new(non_uv) == 0));  % Debugging.
  % Check no weight got placed on uv pairs whose derivative is negative.
  %assert(numel(setdiff(find(p_new > 0), find(df >= -df_tol))) == 0);  % Debugging.
  % Check 1:1 constraints.
  %assert(verify(p_new));  % Debugging.
  
  %% Break if p is close to p_new.
  p_diff = p_new - p;
  if sum(abs(p_diff)) < N * p_eps
    break;
  end
  
  %% Break if p is on the boundary of the 1:1 matching polytope,
  %% somewhere between two integer solutions, and the gradient is
  %% pointing perpendicular to the boundary.
  %step_df = -trace(M_inv * bsxfun(@times, p_diff, L - eye(N)));
  step_df = -trace(M \ bsxfun(@times, p_diff, L - eye(N)));
  if step_df >= 0 && step_df <= step_df_tol  % Check to see if value is approx 0.
    break;
  end
  
  %% Take a step in the direction of the new solution.
  %assert(step_df < 0);  % Debugging.
  old_obj = f;
  [step_size, f, M] = wolfe_handle(-f, ...
    @(M) step_gradient(L, p, p_new, M), step_df, M, ...
    p, p_diff, prev_step);
  f = -f;
  %assert(step_size >= 0);  % Debugging.
  %assert(step_size <= 1);  % Debugging.
  prev_step = step_size;
  p = (1 - step_size)*p + step_size*p_new;
  %assert(verify(p));  % Debugging.
  
  %% Break if p is close to p_old.
  if sum(abs(p_old - p)) < N * p_eps
    break;
  end
end

%% Round solution.
if dups_exist
  % Can't use vanilla pipage rounding with duplicate pairs; it's like
  % having multiple copies of an edge in the bipartite graph.
  p = threshold_rounding(p, L, verify);
else
  P = zeros(num_us, num_vs);
  P(uv) = p;
  P = pipage_rounding(P, @(Q) objective(L, Q(uv)));
  p = P(uv);
end
%verify(p);  % Debugging.
C = find(p)';
%final_f = objective(L, p);  % Debugging.
%fprintf('ratio objective / objective post-rounding: %f\n', f / final_f);  % Debugging.
%fprintf('final objective: %f\n', final_f);  % Debugging.

  
%% End of main function.
  

function verified = verify_1to1(p, us, vs, u_map, v_map, p_tol)
  for ui = 1:numel(us)
    if sum(p(u_map == us(ui))) > 1 + p_tol
      verified = false;
      return;
    end
  end
  
  for vi = 1:numel(vs)
    if sum(p(v_map == vs(vi))) > 1 + p_tol
      verified = false;
      return;
    end
  end
  
  verified = true;


% Note that for all functions below that use bsxfun, p must be Nx1, not
% 1xN, for the math to be correct.  (The functions have checks to make
% sure that p is appropriately dimensioned.)


function [f, M] = objective(L, p)
N = length(L);
if numel(p) ~= size(p, 1)
  p = p';
end
M = eye(N) + bsxfun(@times, p, L - eye(N));
f = log(det(M));


function df = gradient_given_m(L, M)
df = diag((L - eye(length(L))) / M);


function [f, df, M] = objective_and_gradient(L, p)
[f, M] = objective(L, p);
% Commented code is an alternative implementation, likely less efficient.
%M_inv = inv(M);
%df_temp = sum((L - eye(length(L))) .* M_inv', 2);
df = diag((L - eye(length(L))) / M);

  
function [f, M] = neg_objective(L, p)
[f, M] = objective(L, p);  
f = -f;
  

function [f, df, M] = neg_objective_and_gradient(L, p)
[f, df, M] = objective_and_gradient(L, p);
f = -f;
df = -df;


function [df, M] = step_gradient(L, p, p_new, M)
N = length(L);
if numel(p) ~= size(p, 1)
  p = p';
end
if numel(p_new) ~= size(p_new, 1)
  p_new = p_new';
end
% Commented code is an alternative implementation, likely less efficient.
%M_inv = inv(M);
%df = -sum(sum(M_inv .* bsxfun(@times, p_new - p, L - eye(N))', 2));
df = -trace(M \ bsxfun(@times, p_new - p, L - eye(N)));