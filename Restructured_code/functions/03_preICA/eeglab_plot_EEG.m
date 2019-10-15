function fig = eeglab_plot_EEG(EEG, CFG)

% get sample rate
srate = EEG.srate;

% define distance between plots for each channel
%regular_spacing = median(6*std(EEG.data,[],2));
%extreme_case_spacing = 1000; % microvolts
%spacing = min([regular_spacing, extreme_case_spacing]);

% older scripts didn't have plot_ICA_components field; Thus, it's necessary
% to add it to avoid errors
if ~isfield(CFG, 'plot_ICA_components')
    CFG.plot_ICA_components = 0;
end
if ~isfield(CFG, 'eeglab_plot_fullscreen')
    CFG.eeglab_plot_fullscreen = 1;
end

if CFG.plot_ICA_components
    IC_all = 1:CFG.num_components_to_plot;
    IC_marked_for_rejection = find(EEG.reject.gcompreject);
    eegplot('noui', EEG.icaact(IC_all,:,:), 'winlength', EEG.trials, 'srate', srate, 'spacing', CFG.eeg_plot_spacing);
else
    if length(size(EEG.data)) == 2 % channels x time points
        % max time in seconds
        max_time_s = size(EEG.data,2)/srate;
        % plot data using the eeglab function eegplot
        eegplot('noui', EEG.data, 'winlength', max_time_s, 'srate', srate, 'spacing', CFG.eeg_plot_spacing);
    else % channels x time points x n_trials
        eegplot('noui', EEG.data, 'winlength', EEG.trials, 'srate', srate, 'spacing', CFG.eeg_plot_spacing);
    end
end

% get axis handle
fig = gcf;
if CFG.eeglab_plot_fullscreen
    set(fig, 'units','normalized','outerposition',[0 0 1 1])
end
chldrn = fig.Children;
ax_idx = 4; % usually 4 works, but it's better to check additionally
for i=1:numel(chldrn)
    if isa(chldrn(i),'matlab.graphics.axis.Axes') && ~isempty(chldrn(i).UserData)
        ax_idx = i;
    end
end
ax = chldrn(ax_idx);

% Change the color of marked components to red
if CFG.plot_ICA_components
    lines = get(ax, 'Children');
    for lini = IC_marked_for_rejection
        ln = lines(lini);
        ln.Color = [1 0 0];
    end
end   
    
if length(size(EEG.data)) == 2 % channels x time points
    % define x_tick_time_step
    %n_ticks = 20;
    x_tick_time_step = 10;% round(max_time_s/n_ticks);
    
    % set xticks
    xticks(ax, 0:srate*x_tick_time_step:size(EEG.data,2));
    xticklabels(ax, 0:x_tick_time_step:max_time_s);
else
    % remove automatic "garbage" xtick
    set(ax, 'XTick', [])
    
    % find axis that has xticklabels on top of the plot
    for i=1:numel(chldrn)
        if isa(chldrn(i),'matlab.graphics.axis.Axes') && numel(chldrn(i).XTick) > 10
            ax_idx = i;
        end
    end
    ax_top = chldrn(ax_idx);
    
    x_tick_epoch_step = 10;
    x_ticks = get(ax_top, 'XTick'); xtick_labels = get(ax_top, 'XTickLabels');
    if numel(x_ticks) > 10
        set(ax_top, 'XTick', [x_ticks(1), x_ticks(10:x_tick_epoch_step:end)])
        set(ax_top, 'XTickLabels', [xtick_labels(1,:); xtick_labels(10:x_tick_epoch_step:end,:)])
    end
end

if ~CFG.plot_ICA_components
    % set yticks
    yt = get(ax, 'YTick');
    yt = yt(2:end);
    set(ax, 'YTick', yt);
    ch_labels = {EEG.chanlocs.labels};
    set(ax, 'YTickLabel', fliplr(ch_labels));
end

% add grid
grid on;

% No action required when moving mouse across the figure
set(gcf, 'WindowButtonMotionFcn', '')
