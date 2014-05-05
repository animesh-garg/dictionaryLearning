% Loads data from infile and runs greedy and softmax on the data, saving
% the selected sets to outfile.
function test_methods(infile, outfile, match_weights)
load(infile);

% Configure method parameters.
methods_array = repmat(struct(), 1, 2);
[methods_array.fun] = deal(@greedy, @softmax);
methods_array(1).weights = match_weights;
methods_array(2).weights = match_weights;
[methods_array.name] = deal('Greedy', 'SoftMax');
[methods_array.compare_to] = deal([], 1);

% Run baselines on each set of matches.
num_names = numel(names);
for b = 1:numel(methods_array)
  disp(['Baseline ' methods_array(b).name]);
  
  num_weights = numel(methods_array(b).weights);
  methods_array(b).sel_ids = cell(num_weights, num_names, num_names);
  methods_array(b).chosen = cell(num_weights, num_names, num_names, 2);
  
  for w = 1:num_weights
    disp(['Weight: ' num2str(methods_array(b).weights(w))]);
    
    for i = 1:num_names
      for j = i+1:num_names
        % Select pairs.
        C = methods_array(b).fun(M{i, j}.best_sim.M, ...
          M{i, j}.best_ids(3, :), methods_array(b).weights(w), ...
          M{i, j}.cluster_ids);
        
        % Save selection.
        methods_array(b).sel_ids{w, i, j} = C;
        methods_array(b).chosen{w, i, j, 1} = M{i, j}.best_ids(1, C);
        methods_array(b).chosen{w, i, j, 2} = M{i, j}.best_ids(2, C);
      end
    end
  end
end

save(outfile, 'methods_array');