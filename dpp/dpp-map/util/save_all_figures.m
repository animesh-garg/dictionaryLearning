% Saves all currently open figures to the given folder.
function save_all_figures(folder)
figs = findobj('type', 'figure');
for i = 1:numel(figs)
  saveas(figs(i), fullfile(folder, ['figure' num2str(figs(i)) '.fig']));
end