function fig = eeglab_plot_EEG(EEG)

% get sample rate
srate = EEG.srate;

% define distance between plots for each channel
regular_spacing = median(6*std(EEG.data,[],2));
extreme_case_spacing = 1000; % microvolts
spacing = min([regular_spacing, extreme_case_spacing]);

% max time in seconds
max_time_s = size(EEG.data,2)/srate;

% plot data using the eeglab function eegplot 
eegplot('noui', EEG.data, 'winlength', max_time_s, 'srate', srate, 'spacing', spacing);

% get axis handle
fig = gcf;
chldrn = fig.Children;
ax_idx = 4; % usually works, but unstable
for i=1:numel(chldrn)
    if isa(chldrn(i),'matlab.graphics.axis.Axes') && ~isempty(chldrn(i).UserData)
        ax_idx = i;
    end
end
ax = chldrn(ax_idx);

% define x_tick_time_step 
%n_ticks = 20;
x_tick_time_step = 10;% round(max_time_s/n_ticks); 

% set xticks
xticks(ax, 0:srate*x_tick_time_step:size(EEG.data,2));
xticklabels(ax, 0:x_tick_time_step:max_time_s);

% set yticks
yt = get(ax, 'YTick');
yt = yt(2:end);
set(ax, 'YTick', yt);
ch_labels = {EEG.chanlocs.labels};
set(ax, 'YTickLabel', fliplr(ch_labels));

% add grid
grid on;