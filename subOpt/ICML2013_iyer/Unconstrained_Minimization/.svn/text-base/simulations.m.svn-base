% A test simulation file to play around with. 

% Author: Rishabh Iyer (rkiyer@u.washington.edu)

%% Concave over Modular functions over random data
a = 0.5;
n = 100;
lambda = 1;
for i = 1 : n
    m1(i) = rand(); m2(i) = rand();
end
f = sfo_fn_concavemod(n, 'cmod', a, lambda, m1, m2);
f0 = sfo_fn_residual(f, []);
tic; Aopt = sfo_min_norm_point(f0,1:n);
timemn = toc;
% MMin-I/II
tic; [A, B] = mmin3(f, 1:n);
f1 = sfo_fn_residual(f, A);
Aopt1 = sfo_min_norm_point(f1,setdiff(B, A)); 
timemn1 = toc;

% MMin-III
tic;  [Aplus, Bplus] =mmin12(f, 1:n);
if length(setdiff(Bplus, Aplus)) > 0
    f2 = sfo_fn_residual(f, Aplus);
    Aopt2 = sfo_min_norm_point(f2,setdiff(Bplus, Aplus));
end
timemn2 = toc;

disp(sprintf('Running time of Minimum norm without the preprocessing is %f', timemn));
disp(sprintf('Running time of Minimum norm with MMin-III is %f', timemn1));
disp(sprintf('Running time of Minimum norm with MMin-I/II is %f', timemn2));

%% Bipartite Neighborhood functions

clear all;
m = 100;
n = 331;
G = zeros(m, n);
w1 = zeros(n, 1);
w2 = zeros(m, 1);

% The bipartite graph is constructed from a graph stored in 'bipartite.txt'. 
% This graph is constructed from TIMIT corpus with 100 sentences and
% 331 words (see more details in the paper - Lin & Bilmes, 2011 - 'Optimal selection of limited
% vocabulary speech corpora'.

c = load('bipartite.txt');  
for i = 1 : length(c)
    G(c(i, 1) - 2, c(i, 2) - 102) = 1;
end

% Randomly assign the weights to the words and sentences.
w1 = rand(n, 1);
w2 = rand(m, 1);

for i = 1 : m
    B = []; 
    for j = 1 : n
        if G(i, j) == 1
            B = [B, j];
        end
    end
    covered{i} = B;
end

lambda = 15;
f = sfo_fn_bipartite_nb(G, w1, w2, lambda,covered,'sqrt');
f0 = sfo_fn_residual(f, []);
tic; Aopt = sfo_min_norm_point(f0,1:m);
timemn = toc;
% MMin-I/II
tic; [A, B] = mmin3(f, 1:m);
f1 = sfo_fn_residual(f, A);
Aopt1 = sfo_min_norm_point(f1,setdiff(B, A)); 
timemn1 = toc;

% MMin-III
tic;  [Aplus, Bplus] =mmin12(f, 1:m);
if length(setdiff(Bplus, Aplus)) > 0
    f2 = sfo_fn_residual(f, Aplus);
    Aopt2 = sfo_min_norm_point(f2,setdiff(Bplus, Aplus));
end
timemn2 = toc;

disp(sprintf('Running time of Minimum norm without the preprocessing is %f', timemn));
disp(sprintf('Running time of Minimum norm with MMin-III is %f', timemn1));
disp(sprintf('Running time of Minimum norm with MMin-I/II is %f', timemn2));