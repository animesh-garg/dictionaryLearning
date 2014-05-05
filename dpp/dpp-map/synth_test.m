% Runs the given methods on randomly generated DPPs and saves probability
% and timing results to outfile.  Parameters:
%   Ns = DPP sizes
%   w_m = match weight
%   one_to_one = true to run with constraints, false for unconstrained
% The output file will contain:
%   Ns = the input DPP sizes
%   scales = array of constants by which the random matrices were
%            multiplied to scale their values
%   results = 1 x numel(Ns) struct array with fields:
%     match(i,j,k) = quality score for trial i, scale j, method k
%     DPP(i,j,k) = diversity score for (same as previous)
%     probability(i,j,k) = composition of quality and diversity scores
%     time(i,j,k) = runtime for (same as above)
%     fraction_selected(i,j,k) = fraction of the N total items selected
%     mean_ratio(j,k) = average ratio of method2 / method1 for scale j, measure k
%       (measures are the 5 items above: match, DPP, probability, etc.)
%     median_ratio, q1_ratio, q_3_ratio = same as previous
%       (but median, 1st quartile, and 3rd quartile instead of average)
function results = synth_test(outfile, Ns, num_trials, w_m, method1, method2, one_to_one)
% Scales much larger than this will result in Inf values for the
% determinants of large (say, 200x200) matrices.
scales = [0.1];
num_scales = numel(scales);

results = [];
measures = {'match', 'DPP', 'probability', 'time', 'fraction_selected'};
num_measures = numel(measures);
num_dpp_sizes = numel(Ns);

%% Iterate over all DPP sizes.
for i = 1:num_dpp_sizes
  N = Ns(i);
  
  % Let everything be full rank; no point in using less than full rank
  % since zero eigenvalues don't result in any interesting interactions.
  num_feats = N;
  
  res = WrapperClass();
  for j = 1:num_measures
    res.value.(measures{j}) = zeros(num_trials, num_scales, 2);
  end
  
  %% Execute several trials.
  for t = 1:num_trials
    fprintf('%d / %d (%d)\n', t, num_trials, N);
    
    %% Draw match scores from the standard normal.
    m = randn(N, 1);
    M = diag(sqrt(exp(w_m * m)));
    
    %% Enforcing 1:1 constraints.
    if one_to_one
      %% Sample some pairs.
      N1 = round(sqrt(N) * 2);
      N2 = round(sqrt(N) * 2);
      total_num_pairs = N1 * N2;
      [u, v] = ind2sub([N1, N2], randsample(total_num_pairs, N));
      uv = [u'; v'];
      
      %% Generate features for the individual elements.
      F1 = randn(N1, num_feats);
      F2 = randn(N2, num_feats);
      
      %% Combine to make features for each sampled pair.
      S = (F1(u, :) + F2(v, :)) / 2;
      
      f1 = @(L) method1(L, m, w_m, uv);
      f2 = @(L) method2(L, m, w_m, uv);
    else
      %% Not enforcing 1:1 constraints.
      
      %% Directly generate features for the pairs.
      S = randn(N, num_feats);
      
      f1 = @(L) method1(L, m, w_m);
      f2 = @(L) method2(L, m, w_m);
    end
    
    %% Common code.
    L = S * S';
    run_single_dpp_methods(f1 ,f2, scales, L, m, w_m, measures, res, t);
  end
  
  %% Compute averages and quantiles.
  r = res.value;
  r.mean_ratio = zeros(num_scales, 2);
  r.median_ratio = zeros(num_scales, 2);
  r.q1_ratio = zeros(num_scales, 2);
  r.q3_ratio = zeros(num_scales, 2);
  for k = 1:num_scales
    for j = 1:num_measures
      measure = r.(measures{j});
      
      ratios = measure(:, k, 2) ./ measure(:, k, 1);
      r.mean_ratio(k, j) = mean(ratios);
      quants = quantile(ratios, [0.25, 0.5, 0.75]);
      r.q1_ratio(k, j) = quants(1);
      r.median_ratio(k, j) = quants(2);
      r.q3_ratio(k, j) = quants(3);
    end
  end
  
  %% Save results.
  results = [results r];
end

save(outfile, 'results', 'scales', 'Ns');

%% End of main function.
  
  
%% Print objective and time ratios.
function log_results(measures, res, t, k)
for j = 1:numel(measures)
  measure = res.value.(measures{j});
  fprintf('%s ratio (method2 / method1): %f\n', measures{j}, ...
    mean(measure(t, k, 2) ./ measure(t, k, 1)));
end


%% Computes exponentiated value of single DPP objective function.
%% (Exponentiated to convert from log det to det, the unormalized DPP probability.)
function [prob, match, diversity] = single_dpp_objective(L, m, w_m, C)
match = exp(w_m * sum(m(C)));
diversity = det(L(C, C));
prob = diversity * exp(match);

%% Runs method and records its runtime and objective value.
function run_single_dpp_method(f, L, m, w_m, res, t, k, f_num)
tic;
Y = f();
res.value.time(t, k, f_num) = toc;
[res.value.probability(t, k, f_num), ...
 res.value.match(t, k, f_num), ...
 res.value.DPP(t, k, f_num)] = ...
  single_dpp_objective(L, m, w_m, Y);
res.value.fraction_selected(t, k, f_num) = numel(Y) / size(L, 1);

% Reshape to ensure a row vector.
Y = reshape(sort(Y), 1, []);
disp(['Selection ' num2str(f_num) ': ' num2str(Y)]);


%% Runs run_single_dpp_method twice at all scales.
function run_single_dpp_methods(f1, f2, scales, L, m, w_m, measures, res, t)
for k = 1:numel(scales)
  L_scaled = scales(k) * L;
  run_single_dpp_method(@() f1(L_scaled), L_scaled, m, w_m, res, t, k, 1);
  run_single_dpp_method(@() f2(L_scaled), L_scaled, m, w_m, res, t, k, 2);
  log_results(measures, res, t, k);
end