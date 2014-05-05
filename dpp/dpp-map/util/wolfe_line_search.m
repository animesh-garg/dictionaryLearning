% Finds a step size that satisfies the strong Wolfe conditions.
%
% f_handle = handle to objective
% f = objective evaluated at x
% step_df_handle = handle to gradient w.r.t. step_size
% step_df = gradient in terms of step_size, evaluated at x
% aux_info = auxilliary information returned by step_df_handle
% x = starting point
% p = search direction
% step_init = first step size to try
% max_step = maximum step size
% step_eps = smallest change in step size to consider
% max_iters = maximum number of step_size values to try
function [step_size, f_i, aux_info] = wolfe_line_search(...
  f_handle, f, step_df_handle, step_df, aux_info, ...
  x, p, c1, c2, ...
  step_init, max_step, step_eps, max_iters)
% Make sure the given direction is a descent direction.
assert(step_df < 0);

step_size = step_init;
prev_f = f;
prev_aux_info = aux_info;
prev_step = 0;
wolfe_zoom_handle = @(in0, in1, in2, in3, in4) wolfe_zoom(c1, c2, ...
  f_handle, f, step_df_handle, step_df, x, p, step_eps, max_iters, ...
  in0, in1, in2, in3, in4);
for i = 1:max_iters
  [f_i, f_aux] = f_handle(x + step_size * p);
  
  % Check Armijo condition (sufficient decrease).  If it is not satisfied,
  % then the step size is too large, and we should zoom in between the
  % current step size and the previous.
  if f_i > f + c1 * step_size * step_df || (i > 1 && f_i >= prev_f)
    [step_size, f_i, aux_info] = ...
      wolfe_zoom_handle(i, prev_step, step_size, prev_f, prev_aux_info);
    return;
  end
  
  [step_df_i, aux_info] = step_df_handle(f_aux);
  
  % Check curvature condition.  If it is satisfied also, we are done.
  if abs(step_df_i) <= -c2 * step_df
    return;
  end
  
  % Check another indicator that step size is too large.  If true, then we
  % should zoom in between the current step size and the previous.
  if step_df_i >= 0
    % Function value is better at the current step size than at the
    % previous in this case, but the gradient indicates going further 
    % won't further improve it.
    [step_size, f_i, aux_info] = ...
      wolfe_zoom_handle(i, step_size, prev_step, f_i, aux_info);
    return;
  end
  
  % Update below ensures step size will be at most max_step.
  if step_size >= max_step
    %fprintf('Returning max step size %f from line search.\n', max_step);
    return;
  end
  
  if i == max_iters
    %fprintf('Returning from line search after reaching max # of iterations.\n');
    return;
  end
  
  prev_step = step_size;
  step_size = min(2 * step_size, max_step);
  prev_f = f_i;
  prev_aux_info = aux_info;
end


function [step_size, f_i, aux_info] = wolfe_zoom(...
  c1, c2, ...
  f_handle, f, step_df_handle, step_df, x, p, step_eps, max_iters, ...
  num_iters, step_low, step_high, f_low, low_aux_info)
for i = num_iters:max_iters
  step_size = mean([step_low, step_high]);
     
  % If the limit of numerical precision we care about has been reached,
  % just return the best step size found thus far.
  if abs(step_size - step_low) < step_eps || i == max_iters
    step_size = step_low;
    f_i = f_low;
    aux_info = low_aux_info;
    if i == max_iters
      %fprintf('Returning from line search after reaching max # of iterations.\n');
    end
    return;
  end
  
  [f_i, f_aux] = f_handle(x + step_size * p);
  if f_i > f + c1 * step_size * step_df || f_i >= f_low
    step_high = step_size;
  else
    [step_df_i, aux_info] = step_df_handle(f_aux);
    if abs(step_df_i) <= -c2 * step_df
      return;
    end
    
    if step_df_i * (step_high - step_low) >= 0
      step_high = step_low;
    end
    
    step_low = step_size;
    f_low = f_i;
    low_aux_info = aux_info;
  end
end
