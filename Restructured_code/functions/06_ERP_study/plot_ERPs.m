function [CFG, ERP, fig] = plot_ERPs(CFG, ERP)

amplitude_limit = CFG.amplitude_limit;
epoch_boundary = CFG.epoch_boundary_ms;
SEM = CFG.SEM;
ERP = pop_ploterps(ERP, CFG.ERP_bins,  1:ERP.nchan, 'AutoYlim', 'off', 'yscale', amplitude_limit, 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 6 6], 'ChLabel',...
    'on', 'FontSizeChan',  10, 'FontSizeLeg',  12, 'FontSizeTicks',  10, 'LegPos', 'bottom', 'Linespec', {'r-' , 'b-' }, 'LineWidth',  1, 'Maximize',...
    'on', 'Position', [ 103.714 16.0476 106.857 31.9048], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale',...
    [epoch_boundary(1) epoch_boundary(2)   epoch_boundary(1):200:epoch_boundary(2)], 'YDir', 'normal', 'SEM', SEM);

fig = gcf;