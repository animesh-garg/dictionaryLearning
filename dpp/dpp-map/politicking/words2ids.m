% Maps each word in P to an id, which is stored in id2word.  Sets W to a
% (# of words)x(# of documents) matrix with each entry indicating the
% number of time a word occurs in a document.
function [P, id2word, W, W_norm, doc_lengths] = ...
  words2ids(P, stopwords, doc_freq_thresh, doc_size_thresh, varargin)
assert(numel(varargin) <= 1);

% Remove partitions in P and keep just the text field to make Q.
Q = repmat(struct('orig_text', '', 'text', ''), 0, 1);
for i = 1:numel(P)
  Q(end+1:end+numel(P(i).data)) = P(i).data;
end
Q = rmfield(Q, 'orig_text');

% Add all words to id2word and record each document's length.
id2word = {};
N = numel(Q);
doc_lengths = zeros(N, 1);
for i = 1:N
  words = regexp(Q(i).text, '[^ ]+', 'match');
  doc_lengths(i) = numel(words);
  id2word(end + (1:doc_lengths(i))) = words;
end
[id2word, ~, orig_ids] = unique(id2word);
num_words = numel(id2word);

% For each document, map its words to ids.
W = sparse(num_words, N);
doc_lengths = cumsum(doc_lengths);
prev_doc_end = 0;
for i = 1:N
  [ids, ~, orig_ids_i] = unique(orig_ids(prev_doc_end+1:doc_lengths(i)));
  W(ids, i) = hist(orig_ids_i, 1:numel(ids));
  prev_doc_end = doc_lengths(i);
end

% Load stopwords.
stopwords_fid = fopen(stopwords, 'r');
tline = fgetl(stopwords_fid);
stopwords = {};
while ischar(tline)
  stopwords{end + 1} = strtrim(tline);
  tline = fgetl(stopwords_fid);
end

% Remove stopwords.
stop_ids = [];
for i = 1:numel(stopwords)
  stop_match = find(ismember(id2word, stopwords{i}));
  if stop_match
    stop_ids(end + 1) = stop_match;
  end
end
id2word(stop_ids) = [];
W(stop_ids, :) = [];

% Remove empty blocks.
word_sums = full(sum(W, 1));
empty_blocks = find(word_sums == 0);
W(:, empty_blocks) = [];

% Filter words that occur in more than doc_freq_thresh proportion of the blocks.
df = sum(W > 0, 2);
filter_words = find(df > doc_freq_thresh * size(W, 2));
id2word(filter_words) = [];
W(filter_words, :) = [];

% Filter near-empty blocks.
word_sums = full(sum(W, 1));
num_words_required = mean(word_sums) * doc_size_thresh;
small_blocks = find(word_sums < num_words_required);
W(:, small_blocks) = [];

% Remove words that were only in near-empty blocks.
filter_words = find(sum(W, 2) == 0);
id2word(filter_words) = [];
W(filter_words, :) = [];

% Combine empty_blocks with small_blocks.
for i = 1:numel(empty_blocks)
  old_idx = find(small_blocks >= empty_blocks(i));
  small_blocks(old_idx) = small_blocks(old_idx) + 1;
end
small_blocks = sort([small_blocks empty_blocks], 'ascend');
P = remove_docs(P, small_blocks);

% Compute document lengths, then normalize word counts.
doc_lengths = sum(W, 1);
[W_norm, nonzero_cols] = normalize_cols(W);
assert(numel(nonzero_cols) == size(W, 2));
assert(size(W, 1) == numel(id2word));

% Save results to file if one is provided.
if numel(varargin) == 1
  save(varargin{1}, 'P', 'id2word', 'W', 'W_norm', 'doc_lengths', '-append');
end


function P = remove_docs(P, to_remove)
doc_count = 0;
for i = 1:numel(P)
  prev_doc_count = doc_count;
  doc_count = doc_count + numel(P(i).data);
  P(i).data(to_remove((to_remove > prev_doc_count) & ...
    (to_remove <= doc_count)) - prev_doc_count) = [];
end
