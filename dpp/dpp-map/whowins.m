% Takes the scores stored in 'infile' and plots them, storing the results
% in files with the prefix given by the 'outfile' argument.
function whowins(infile, outfile)
load(infile);
measures = fieldnames(results(1));
num_measures = numel(measures);
num_dpp_sizes = numel(Ns);
pos = [100 100 230 180];

% Probabilities.
figure
set(gcf,'Position',pos);
hold on
for i = 1:length(results)
  P = permute(results(i).probability,[1 3 2]);
  logratios = log(P(:,1) ./ P(:,2));
  y(i,1:3) = quantile(logratios,[0.25 0.5 0.75]);
end
plot(Ns,y(:,1),'b--');
plot(Ns,y(:,2),'r.-');
plot(Ns,y(:,3),'b--');
plot(Ns,zeros(num_dpp_sizes,1),'k:');
ax = axis;
if(ax(3) > -0.5)
  ax(3) = -0.5;
end
if(ax(4) < 0.5)
  ax(4) = 0.5;
end
axis(ax);
xlabel('N');
ylabel('log prob. ratio (vs. greedy)')
if exist('outfile','var')
  set(gcf,'PaperPositionMode','auto');
  print('-depsc','temp.eps');
  system('epstopdf temp.eps');
  system('rm temp.eps');
  system(['mv temp.pdf ' outfile '_quality.pdf']);
end

% Time.
figure
set(gcf,'Position',pos);
hold on
for i = 1:length(results)
  T = permute(results(i).time,[1 3 2]);
  ratios = T(:,1) ./ T(:,2);
  y(i,1:3) = quantile(ratios,[0.25 0.5 0.75]);
end
plot(Ns,y(:,1),'b--');
plot(Ns,y(:,2),'r.-');
plot(Ns,y(:,3),'b--');
plot(Ns,ones(num_dpp_sizes,1),'k:');
ax = axis;
if(ax(3) > 0.9)
  ax(3) = 0.9;
end
if(ax(4) < 1.1)
  ax(4) = 1.1;
end
axis(ax);
xlabel('N');
ylabel('time ratio (vs. greedy)')
if exist('outfile','var')
  set(gcf,'PaperPositionMode','auto');
  print('-depsc','temp.eps');
  system('epstopdf temp.eps');
  system('rm temp.eps');
  system(['mv temp.pdf ' outfile '_time.pdf']);
end