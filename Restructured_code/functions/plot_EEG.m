function y_cut = plot_EEG(y, CFG, file_name, cut_beginning_end)

if cut_beginning_end
% cut data at the beginning and end
idx_to_keep = CFG.beginning_cut_at_idx:size(y,2)-CFG.end_cut_at_idx;
idx_to_cut_beginning = 1:idx_to_keep(1)-1;
idx_to_cut_end = idx_to_keep(end)+1:size(y,2);
else
    idx_to_keep = 1:size(y,2);
end
y_cut = y(:, idx_to_keep);

times = y(CFG.time_channel,:);

% evalute median channel std for further plotting
median_ch_std_cut = median(std(y_cut,[],2));
    
figure('units','normalized','outerposition',[0 0 1 1])
ytick_value = zeros(CFG.total_num_channels,1);
for plot_idx = 1:CFG.total_num_channels
    ch_idx = plot_idx + 1; % 1st channel is time
    ch_data = y(ch_idx,:);
    delta_y = 6*median_ch_std_cut; % delta y between channels on plots
    data_to_plot = ch_data + delta_y*(CFG.total_num_channels-plot_idx+1);
    ytick_value(plot_idx) = mean(data_to_plot);
    
    clr = lines(plot_idx); clr = clr(end,:);
    plot(times(idx_to_keep), data_to_plot(idx_to_keep), 'color', clr)
    hold on
    
    if cut_beginning_end
        plot(times(idx_to_cut_beginning), data_to_plot(idx_to_cut_beginning), 'color', CFG.gray_clr)
        plot(times(idx_to_cut_end), data_to_plot(idx_to_cut_end), 'color', CFG.gray_clr)
    end
    
end

title(['EEG data plot, file: ', file_name], 'Interpreter', 'None')
xlabel('Time, s')
ylabel('Amplitude')
ylim = [0, delta_y*(1+CFG.total_num_channels)];

if cut_beginning_end
    plot([times(idx_to_cut_beginning(end)), times(idx_to_cut_beginning(end))], [ylim(1), ylim(2)], '--r', 'linewidth', 3)
    plot([times(idx_to_cut_end(1)), times(idx_to_cut_end(1))], [ylim(1), ylim(2)], '--r', 'linewidth', 3)
end

trigger_ch = y(CFG.trigger_channel,:);
first_trigger_idx = find(trigger_ch ~= 0,1, 'first');
last_trigger_idx = find(trigger_ch == 1, 1, 'last');
plot([times(first_trigger_idx), times(first_trigger_idx)], [ylim(1), ylim(2)], '--g', 'linewidth', 3)
plot([times(last_trigger_idx), times(last_trigger_idx)], [ylim(1), ylim(2)], '--g', 'linewidth', 3)
set(gca, 'ylim', ylim, 'Ytick', ytick_value(end:-1:1), 'YTickLabel', CFG.ch_labels(end:-1:1))
