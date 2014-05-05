% Loads the features in outfile and combines them to compute match scores
% for each pair of speakers.  Prunes low-match-score items and saves the
% rest along with their k-means cluster IDs.
function features2matches(outfile)
load(outfile);

% Decide on speakers.
names = {'BACHMANN', 'CAIN', 'GINGRICH', 'HUNTSMAN', ...
  'PAUL', 'PERRY', 'ROMNEY', 'SANTORUM'};
num_names = numel(names);

% Locate these speakers in the main struct and reduce the feature matrices
% accordingly.
pidxs = zeros(1, num_names);
num_pres = zeros(1, num_names);
num_docs = zeros(1, num_names);
const_feat = 0;  % Currently not used.
F = repmat(struct('W', [], 'V', [], 'CONST', []), 1, num_names);
for i = 1:num_names
  [pidxs(i), num_pres(i), num_docs(i)] = locate_name_in_struct(P, names{i});
  ith_ids =  num_pres(i) + [1:num_docs(i)];
  F(i).W = W_norm(:, ith_ids);
  F(i).V = V(:, ith_ids);
  
  % Add a constant feature to make elements more similar.
  F(i).CONST(1, 1:numel(ith_ids)) = const_feat;
end

% Compute match scores between all segments.  Note that spectral features
% have weight zero and so are currently not used.
word_weight = 1;  % Weight to put on word match scores.
spectral_weight = 0;  % Weight to put on spectral match scores.
gauss_sigma = 0.5;  % Larger for larger spectral scores.
num_to_disp = 5;  % # of best matches to print.
disp_scores = 1;  % 1 to show match scores, 0 to omit.
M = cell(num_names);
feat_fields = fieldnames(F);
mv_funs = match_visuals();
for i = 1:num_names
  for j = i+1:num_names
    M{i, j} = compute_match_scores(F(i), F(j), ...
      word_weight, spectral_weight, gauss_sigma);
    
%     % Don't match a segment to itself.
%     if i == j
%       for fi = 1:numel(feat_fields)
%         ff = feat_fields{fi};
%         M{i, j}.(ff) = M{i, j}.(ff) - diag(diag(M{i, j}.(ff)));
%       end
%       M{i, j}.M = M{i, j}.M - diag(diag(M{i, j}.M));
%     end
    
    % Find and display best matches.
    M{i, j}.best_ids = get_best_matches(M{i, j}.M, i ~= j);
    mv_funs.display_best_matches(M{i, j}, P, pidxs(i), pidxs(j), ...
      names{i}, names{j}, num_to_disp, disp_scores);
    
    % Build similarity matrix on best matches.
    match1 = M{i, j}.best_ids(1, :);
    match2 = M{i, j}.best_ids(2, :);
    for fi = 1:numel(feat_fields)
      ff = feat_fields{fi};
      Fiff = F(i).(ff);
      Fjff = F(j).(ff);
      if strcmp(ff, 'CONST') && const_feat == 0
        M{i, j}.best_feats.(ff) = zeros(size(Fiff(:, match1)));
      else
        [M{i, j}.best_feats.(ff), ~] = ...
          normalize_cols(Fiff(:, match1) + Fjff(:, match2));
      end
    end
    
    % Compute similarity between pair feature vectors.
    % (All pairs of best pairs.)
    M{i, j}.best_sim = ...
      compute_match_scores(M{i, j}.best_feats, M{i, j}.best_feats, ...
      word_weight, spectral_weight, gauss_sigma);
    
    % Re-scale the match scores so they have substantial dynamic range, [0, 1].
    M{i, j}.best_ids(3, :) = (M{i, j}.best_ids(3, :) - min(M{i, j}.best_ids(3, :)));
    M{i, j}.best_ids(3, :) = M{i, j}.best_ids(3, :) ./ max(M{i, j}.best_ids(3, :));
    
    % Increase the constraint strength by requiring that no more than
    % one element from each k-means cluster be selected.
    M{i, j}.cluster_ids = [generate_constraints(F(i), match1)';
      generate_constraints(F(j), match2)'];
  end
end

save(outfile, 'names', 'M', 'pidxs', '-append');


function M = compute_match_scores(F1, F2, ...
  word_weight, spectral_weight, gauss_sigma)
% Compute components of match score.
M.W = word_weight * (F1.W' * F2.W);
M.V = spectral_weight * gauss_sim(F1.V, F2.V, gauss_sigma);
M.CONST = F1.CONST' * F2.CONST;

% Store full match score, normalizing so exact match has score 1.
M.M = (M.W + M.V + M.CONST) / (word_weight + spectral_weight + M.CONST(1));


function matches = get_best_matches(M, flip_dir)
[score1, match1] = max(M);
if flip_dir
  % Compute the best matches in the opposite direction.
  [score2, match2] = max(M, [], 2);
  matches = [match1 1:size(M, 1); 1:size(M, 2) match2'; score1 score2'];
  
  % Remove any exact duplicate pairs.
  start = size(M, 2);
  for i = start:-1:1
    if any((matches(1, end:-1:i+1) == matches(1, i)) & ...
        (matches(2, end:-1:i+1) == matches(2, i)))
      matches(:, i) = [];
    end
  end
else
  matches = [match1; 1:size(M, 2); score1];
end


function nn_groups = generate_constraints(F, selected)
% Create 2 * sqrt(# of elements) clusters.
opts = statset('MaxIter', 500);
idx = kmeans(F.W', ceil(2 * sqrt(size(F.W, 2))), ...
  'Distance', 'cosine', 'Replicates', 5, 'Options', opts);
nn_groups = idx(selected);