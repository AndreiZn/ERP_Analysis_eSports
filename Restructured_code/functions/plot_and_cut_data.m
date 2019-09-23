function file_processed = plot_and_cut_data(y, CFG, file_name)
    
    file_processed = 0;
    times = (1:size(y,2))' - 1; times = times/CFG.sample_rate;

    % cut data at the beginning and end
    idx_to_keep = CFG.beginning_cut_at_idx:size(y,2)-CFG.end_cut_at_idx;
    idx_to_cut_beginning = 1:idx_to_keep(1)-1;
    idx_to_cut_end = idx_to_keep(end)+1:size(y,2);
    y_cut = y(:, idx_to_keep);

    % evalute median channel std for further plotting
    median_ch_std_cut = median(std(y_cut,[],2));

    % load sample eeglab file to extract channel labels
    sample_file = dir(fullfile(CFG.root_folder, '**', 'sample_set.set'));
    EEG = pop_loadset('filename','sample_set.set','filepath',sample_file.folder);
    ch_labels = {EEG.chanlocs.labels};

    figure('units','normalized','outerposition',[0 0 1 1])
    ytick_value = zeros(CFG.total_num_channels,1);
    for plot_idx = 1:CFG.total_num_channels
        ch_idx = plot_idx + 1; % 1st channel is time
        ch_data = y(ch_idx,:);
        delta_y = 6*median_ch_std_cut; % delta y between channels on plots
        data_to_plot = ch_data + delta_y*(CFG.total_num_channels-plot_idx+1);
        ytick_value(plot_idx) = mean(data_to_plot);
        plot(times(idx_to_cut_beginning), data_to_plot(idx_to_cut_beginning), 'color', CFG.gray_clr)
        hold on
        plot(times(idx_to_cut_end), data_to_plot(idx_to_cut_end), 'color', CFG.gray_clr)
        clr = lines(plot_idx); clr = clr(end,:);
        plot(times(idx_to_keep), data_to_plot(idx_to_keep), 'color', clr)
    end
    title(['EEG data plot, file: ', file_name], 'Interpreter', 'None')
    xlabel('Time, s')
    ylabel('Amplitude')
    ylim = [0, delta_y*(1+CFG.total_num_channels)];
    plot([times(idx_to_cut_beginning(end)), times(idx_to_cut_beginning(end))], [ylim(1), ylim(2)], '--r', 'linewidth', 3)
    plot([times(idx_to_cut_end(1)), times(idx_to_cut_end(1))], [ylim(1), ylim(2)], '--r', 'linewidth', 3)
    trigger_ch = y(34,:);
    first_trigger_idx = find(trigger_ch ~= 0,1, 'first');
    last_trigger_idx = find(trigger_ch == 1, 1, 'last');
    plot([times(first_trigger_idx), times(first_trigger_idx)], [ylim(1), ylim(2)], '--g', 'linewidth', 3)
    plot([times(last_trigger_idx), times(last_trigger_idx)], [ylim(1), ylim(2)], '--g', 'linewidth', 3)
    set(gca, 'ylim', ylim, 'Ytick', ytick_value(end:-1:1), 'YTickLabel', ch_labels(end:-1:1))

    answer = questdlg('Do you want to change time limits?', 'Time limits', ...
        'Yes', 'No', 'No');
    switch answer
        case 'Yes'
            change_time_limits = 1;
        case 'No'
            change_time_limits = 0;
    end

    if change_time_limits
        
        while ~file_processed
            [idx_x1,~] = ginput(1);
            [idx_x2,~] = ginput(1);

            if idx_x1 > times(end)
                idx_x1 = times(end);
            end
            if idx_x1 < times(1)
                idx_x1 = times(1);
            end
            if idx_x2 > times(end)
                idx_x2 = times(end);
            end
            if idx_x2 < times(1)
                idx_x2 = times(1);
            end 
            
            close(gcf)
            CFG.beginning_cut_at_idx = dsearchn(times,idx_x1);
            CFG.end_cut_at_idx = size(y,2) - dsearchn(times,idx_x2);

            file_processed = plot_and_cut_data(y, CFG, file_name);
        end
        file_processed = 1;
    else 
        saveas(gcf, [CFG.output_plots_folder_cur, '\Plot_', file_name(1:end-3), 'png'])
        file_processed = 1;
    end