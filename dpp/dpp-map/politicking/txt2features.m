% Reads from the given text infile and computes word-based features.  Saves
% these features to outfile.
function txt2features(infile, outfile)
% Read data from text files into the structure P.
P = read_data(infile);
save(outfile, 'P');

% Filter stopwords, frequent words, short docs, and docs with no neighbors
% in an epsilon-NN graph.  Compute subsequent word counts.
% 1) Stopwords based on:
%    http://dev.mysql.com/doc/refman/5.5/en/fulltext-stopwords.html
stopwords = 'stopwords.txt';
% 2) Max proportion of docs a word can occur in without getting cut.
doc_freq_thresh = 0.1;
% 3) At least this fraction of the mean number of words is required for
%    a document to persist.
doc_size_thresh = 0.5;
% 4) Run it.
[P, id2word, W, W_norm, doc_lengths] = ...
    words2ids(P, stopwords, doc_freq_thresh, doc_size_thresh, outfile);
  
% Get spectral features.
% 1) Variance for Gaussian similiarity (larger for greater similarity).
gauss_sigma = 1;
G = gauss_sim(W_norm, W_norm, gauss_sigma, outfile);
% 2) Threshold for edge existance: eps_val * mean + (1 - eps_val) * max.
%    Larger eps_val means more edges, but value should stay in [0, 1].
eps_val = 9 / 10;
% 3) Allowed gap size between eigenvalues (larger for more features).
gap_size = 5;
% 4) Run it.
V = spectral_embedding(G, eps_val, gap_size, outfile);