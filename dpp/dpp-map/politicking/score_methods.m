% Loads the results from infile and computes intrinsic evaluation measures
% on them, saving the results to outfile.
function score_methods(infile, outfile)
load(infile);
load(outfile);

num_names = numel(names);
filled = logical(triu(ones(num_names), 1));
mv_funs = match_visuals();
for b = 1:numel(methods_array)
  num_weights = numel(methods_array(b).weights);
  methods_array(b).eval = repmat(struct('match_eval', zeros(num_names), ...
    'sim_eval', zeros(num_names), 'total', zeros(num_names), ...
    'k_eval', zeros(num_names)), 1, num_weights);
  methods_array(b).ratios = zeros(num_weights, 3);
  
  for w = 1:num_weights
    num_matches = 0;
    for i = 1:num_names
      for j = i+1:num_names
        C = methods_array(b).sel_ids{w, i, j};
        C1 = methods_array(b).chosen{w, i, j, 1};
        C2 = methods_array(b).chosen{w, i, j, 2};
        
        % Display selected pairs.
        mv_funs.display_set_of_pairs(methods_array(b).name, ...
           C1, C2, P, pidxs(i), pidxs(j), names{i}, names{j});
         
        % Compute intrinsic evaluation measures.
        [methods_array(b).eval(w).match_eval(i, j), ...
         methods_array(b).eval(w).sim_eval(i, j), ...
         methods_array(b).eval(w).total(i, j)] = ...
          intrinsic_eval(C,  M{i, j}.best_sim.M, ...
          M{i, j}.best_ids(3, :), ...
          methods_array(b).weights(w));
        methods_array(b).eval(w).k_eval(i, j) = numel(C);
        
        num_matches = num_matches + 1;
      end
    end
    
    % Ratio of method's scores to that of another method.
    if numel(methods_array(b).compare_to) > 0
      ratios = log(methods_array(b).eval(w).total(filled) ./ ...
        methods_array(methods_array(b).compare_to).eval(w).total(filled));
       [methods_array(b).ratios(w, 1), methods_array(b).ratios(w, 3)] = ...
         bootstrap_interval(ratios, 1000, 0.05);
       methods_array(b).ratios(w, 2) = mean(ratios);
    end
  end
end

save(outfile, 'methods_array');


function [match_eval, sim_eval, total] = intrinsic_eval(C, L, M, w_m)
match_eval = w_m * sum(M(C));
sim_eval = det(L(C, C));
total = sim_eval * exp(match_eval);

fprintf('Total: %f\n', total);
fprintf('k: %f\n', numel(C));