function [file_processed, cur_fig] = plot_and_cut_data(y, CFG, file_name)
    
    file_processed = 0;
    times = (1:size(y,2))' - 1; times = times/CFG.sample_rate;

    % cut data at the beginning and end
    idx_to_keep = CFG.beginning_cut_at_idx:size(y,2)-CFG.end_cut_at_idx;
    idx_to_cut_beginning = 1:idx_to_keep(1)-1;
    idx_to_cut_end = idx_to_keep(end)+1:size(y,2);
    y_cut = y(:, idx_to_keep);

    % evalute median channel std for further plotting
    median_ch_std_cut = median(std(y_cut,[],2));
    
    plot_EEG()

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

            [file_processed, ~] = plot_and_cut_data(y, CFG, file_name);
        end
        file_processed = 1;
    else
        save([CFG.output_data_folder_cur, '\', file_name], 'y_cut')
        cur_fig = gcf;
        file_processed = 1;
    end