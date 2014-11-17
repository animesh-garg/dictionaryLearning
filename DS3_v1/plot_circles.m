%--------------------------------------------------------------------------
% Copyright @ Ehsan Elhamifar, 2014
%--------------------------------------------------------------------------

function plot_circles(Y,Z,sInd)

figure
axis square
C = 'c';
numSeginTraj = 68; %for circles lenTraj 5
%numSeginTraj = 63; %for circles lenTraj 10
%Plot original time series removing the chunking
for i = 1:size(Y,2)
    y = Y{i};   
    if mod(i,numSeginTraj)==0
        C = rand(1,3);    
    end
    if mod(i,numSeginTraj)==0 || i ==1
        plot(y(1:end-1,1), y(1:end-1,2), 'LineStyle','--', 'color',C,'LineWidth',2 )
    else
        plot(y(end-1:end,1), y(end-1:end,2), 'LineStyle','--', 'color',C,'LineWidth',2 )
    end
    hold on
end

%plot representatives
for i = 1:length(sInd)
   y = Y{sInd(i)};
   plot(y(:,1), y(:,2), 'LineStyle','-', 'LineWidth',10,'color',rand(1,3))
   hold on
end

%legend('data points','representatives','FontSize',24,'FontName','Times New Roman')
set(gca,'FontSize',24)

%plot sparsity of the representative set
figure
imagesc(Z)
colormap(pink)
h = colormap;
colormap(flipud(h))
colorbar
set(gca,'FontSize',24)
set(gcf,'Renderer','Painters')
