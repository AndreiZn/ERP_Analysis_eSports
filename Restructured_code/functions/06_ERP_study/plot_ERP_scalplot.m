function [CFG, ERP, fig] = plot_ERP_scalplot(CFG, ERP)

latency = CFG.scalplot_latency;
amplitude_limit = CFG.amplitude_limit;

ERP = pop_scalplot(ERP, CFG.ERP_bins,  latency, 'Blc', 'pre', 'Colorbar', 'on', 'Colormap', 'jet', 'Electrodes', 'ptslabels', 'FontName', 'Courier New',...
 'FontSize',  10, 'Legend', 'bn-bd-me-la', 'Maplimit', amplitude_limit, 'Mapstyle', 'both', 'Maptype', '2D', 'Mapview', '+X', 'Maximize',...
 'on', 'Plotrad',  0.55, 'Position', [ 888 330 358 411], 'Value', 'insta');

fig = gcf;