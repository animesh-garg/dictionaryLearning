% Runs bootstrapping to estimate confidence intervals.
%  stats = array of measurements
%  n = number of bootstrap iterations to run
%  p = percentile to return (ex: 0.05 for the 5% and 95% conf intervals)
function [low, high] = bootstrap_interval(stats, n, p)
sample_size = numel(stats);
samp = zeros(n, 1);
for i = 1:n
  samp(i) = mean(stats(randsample(sample_size, sample_size, 1)));
end
samp = sort(samp);
low = samp(floor(p * n));
high = samp(ceil((1 - p) * n));