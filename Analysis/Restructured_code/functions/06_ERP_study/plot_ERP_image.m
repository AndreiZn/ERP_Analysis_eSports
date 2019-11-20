function [fig_handles] = plot_ERP_image(CFG, EEG)

channel_idx = CFG.channel_idx_to_plot;
channel_lbl = EEG.chanlocs(channel_idx).labels;
exp_id = CFG.exp_id_cur;
event_types = CFG.exp_param(exp_id).event_type;
event_names = CFG.exp_param(exp_id).event_name;
amplitude_limit = CFG.amplitude_limit;
vertical_smoothing_parameter = CFG.vertical_smoothing_parameter;

for eti = 1:numel(event_types)
    event_t = event_types(eti); event_name = event_names{eti};
    figure();
    erpimage(mean(EEG.data(channel_idx, :),1), eeg_getepochevent( EEG, event_t{:},[],'type'), ...
        linspace(EEG.xmin*1000, EEG.xmax*1000, EEG.pnts), channel_lbl, vertical_smoothing_parameter, 0 ,'yerplabel','\muV','erp','on',...
        'limits',[NaN NaN amplitude_limit(1) amplitude_limit(2) NaN NaN NaN NaN] ,'cbar','on','caxis',amplitude_limit,'topo', ...
        {[channel_idx] EEG.chanlocs EEG.chaninfo});
    set(gcf,'Name', event_name)
end

% get handles of all figures and save them
fig_handles = findall(groot, 'Type', 'figure');
