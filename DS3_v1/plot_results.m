%--------------------------------------------------------------------------
% Copyright @ Ehsan Elhamifar, 2014
%--------------------------------------------------------------------------

function plot_results(Y,Z,sInd)

figure
plot(Y(1,:),Y(2,:),'o','LineWidth',4,'color','b','markersize',10,'markerfacecolor','b')
hold on
plot(Y(1,sInd),Y(2,sInd),'+','LineWidth',6,'color','r','markersize',16)
legend('data points','representatives','FontSize',24,'FontName','Times New Roman')
set(gca,'FontSize',24)

figure
imagesc(Z)
colormap(pink)
h = colormap;
colormap(flipud(h))
colorbar
set(gca,'FontSize',24)
set(gcf,'Renderer','Painters')
