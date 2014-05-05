% Handles to functions for displaying the text associated with various
% matches and pairs.
function funs = match_visuals()
funs.display_best_matches = @display_best_matches;
funs.display_set_of_pairs = @display_set_of_pairs;
funs.display_pair = @display_pair;
funs.generate_constraints = @generate_constraints;


function matches = sort_matches(matches)
[~, score_order] = sort(matches(3, :), 'descend');
matches1 = matches(1, :);
matches2 = matches(2, :);
matches = [matches1(score_order); matches2(score_order)];


function display_best_matches(M, P, pidx1, pidx2, name1, name2, num_to_disp, disp_scores)
if disp_scores
  varargin = M;
end

matches = sort_matches(M.best_ids);
for j = 1:num_to_disp
  disp(['Match ' num2str(j)]);
  display_pair(matches(1, j), matches(2, j), P, ...
    pidx1, pidx2, name1, name2, varargin);
end


function display_set_of_pairs(method, idxs1, idxs2, P, pidx1, pidx2, name1, name2)
disp(['Set of pairs selected by ' method]);
for i = 1:numel(idxs1)
  disp(['Pair ' num2str(i)]);
  display_pair(idxs1(i), idxs2(i), P, pidx1, pidx2, name1, name2);
end


function display_pair(idx1, idx2, P, pidx1, pidx2, name1, name2, varargin)
nvars = numel(varargin);
assert(nvars <= 1);

disp([name1 ':']);
disp(['Original text: ' P(pidx1).data(idx1).orig_text]);
disp(['Filtered text: ' P(pidx1).data(idx1).text]);

disp([name2 ':']);
disp(['Original text: ' P(pidx2).data(idx2).orig_text]);
disp(['Filtered text: ' P(pidx2).data(idx2).text]);

if nvars == 1
  M = varargin{1};
  
  disp('Feature score comparison');
  feat_fields = {'W', 'V', 'CONST', 'M'};
  for i = 1:numel(feat_fields)
    field = feat_fields{i};
    F = M.(field);
    disp(['Feature ' field ': ' num2str(F(idx1, idx2))]);
  end
end
