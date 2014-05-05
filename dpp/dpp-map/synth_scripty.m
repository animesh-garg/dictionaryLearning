% Runs softmax optimization and greedy methods.  Saves scores in .mat files
% to outfolder and plots the final score ratios.  See synth_test.m for a
% detailed description of the contents of the output files.
function synth_scripty(outfolder)
file_ops = file_utils();
outfolder = file_ops.ensure_trailing_slash(outfolder);

% DPP matrix sizes.
Ns = [50 75 100 125 150 175 200];

% # of trials.
T = 100;

% Match weight (lambda in the paper).
w_m = 0.1;

% Handles to the methods we compare.
method1 = @softmax;
method2 = @greedy;
method3 = @greedy_sym;

test_fun = @(filename, constrained) ...
  synth_test(filename, Ns, T, w_m, method1, method2, constrained);

test_fun_sym = @(filename, constrained) ...
  synth_test(filename, Ns, T, w_m, method1, method3, constrained);

% Unconstrained, softmax versus greedy.
prefix = [outfolder 'synth_unconstrained'];
filename = [prefix '.mat'];
test_fun(filename, false);
whowins(filename, prefix);

% Unconstrained, softmax versus symmetric greedy.
prefix = [outfolder 'synth_unconstrained_sym'];
filename = [prefix '.mat'];
test_fun_sym(filename, false);
whowins(filename, prefix);

% Constrained, softmax versus greedy.
prefix = [outfolder 'synth_constrained'];
filename = [prefix '.mat'];
test_fun(filename, true);
whowins(filename, prefix);