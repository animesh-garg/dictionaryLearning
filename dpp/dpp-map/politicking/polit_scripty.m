% Ex:
% infolder = '/path/to/politicking/data';
% outfile = 'fill_in_whatever_you_want_here.mat';
% result_file = 'fill_in_whatever_you_want_here_again.mat';
% polit_scripty(infolder, outfile, result_file)
%
% outfile will contain the following:  
%   names = 1x8 cell array of the candidates' names
%   pidxs = mapping from the names to their index within P
%   id2word = 1x3809 cell array containing all the words used for comparing
%             the candidates; the words have been stemmed, so they may look
%             a little weird
%   doc_lengths = 1x1430 cell array containing the length (# of words after
%                 filtering) of each political statement
%   P = 8x1 struct array with fields:
%     name = candidate's name
%     data = 1 x # of statements struct array with fields:
%       orig_text = text of the statement as found in the transcript
%       text = filtered, stemmed text containing a subset of the original
%   W = 3809x1430 matrix of word counts; each column corresponds to one
%       political statement
%   W_norm = L2-normalized version of W
%   V = 38x1430 matrix of L2-normalized spectral features
%   Note: In the paper, none of the fancier features were used; only W_norm.
%   M = 8x8 cell array (with only entries above the diagonal filled in)
%     M{i,j} = struct with fields:
%       W, V = similarities between these features for statements made by
%              politicians i and j
%       CONST = constant feature matrix
%       M = weighted, normalized combination of W, V, and CONST
%       best_ids = 3 x # of unpruned statement pairs matrix where:
%         row 1 = index into candidate i's statements
%         row 2 = index into candidate j's statements
%         row 3 = match scores (quality) for these pairs
%       best_feats = features for the unpruned pairs (an average of the 
%                    features for the two statements in each pair)
%       best_sim = similarities of features for the unpruned pairs
%       cluster_ids = result of running k-means clustering
%         row 1 = clustering run on candidate i's statements, with just the
%                 cluster ids of the unpruned statements recorded here
%         row 2 = similarly for candidate j
%
% result_file will contain the following:
%   methods_array = 1x2 struct array with fields:
%     fun = handle to the MAP method tested
%     weights = match weights tried (lambda in the paper)
%     name = MAP method name for display purposes
%     compare_to = index of method to compare to during scoring
%     sel_ids(k,i,j) = subset selected at weight k for candidates i and j
%                      (only below the diagonal is filled)
%     chosen(k,i,j,1) = indices into candidate i's selected statements
%     chosen(k,i,j,2) = indices into candidate j's selected statements
%     ratios = num_weights x 3 matrix of statistics on the ratio of the
%              score of this method to the method indexed by compare_to
%              (will be all zeros if comare_to is [])
function polit_scripty(infolder, outfile, result_file)
RandStream.setDefaultStream(RandStream('mt19937ar', 'seed', 1));

% Convert text files to features and features to matching scores.  Note
% that there are many parameters internal to the txt2features and 
% features2matches functions that can be tuned.
txt2features(infolder, outfile);
features2matches(outfile);

% Test and score softmax and greedy methods.
match_weights = 0.1:0.1:1;  % (lambda from the paper)
test_methods(outfile, result_file, match_weights);
score_methods(outfile, result_file);

% Plot the resulting scores.
plot_eval(result_file);


function plot_eval(infile)
to_plot = load(infile);

for i = 1:numel(to_plot.methods_array)
  mi = to_plot.methods_array(i);
  j = to_plot.methods_array(i).compare_to;
  if numel(j) > 0
    figure(i);
    plot(mi.weights(:), mi.ratios(:, 2), 'b.-');
    ylabel(['log probability ratio (' mi.name ' / ' to_plot.methods_array(j).name ')']);
    xlabel('lambda');
  end
end
