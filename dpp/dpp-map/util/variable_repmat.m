% Repeats element vec(i) reps(i) times.
function res = variable_repmat(vec, reps)
% Orient reps correctly.
if size(reps, 1) == 1
  reps = reps';
end

% Remove any zeros.
zero_reps = find(reps == 0);
if zero_reps
  reps(zero_reps) = [];
  vec(zero_reps) = [];
end

% Build a vector the same length as the desired result,
% with 1s to indicate the start of a new repetition set.
idx([cumsum([1; reps])]) = 1;
idx = idx(1:end-1);

% Repeat the elements of the original vector.
res = vec(cumsum(idx));
