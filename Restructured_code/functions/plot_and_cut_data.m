function [file_processed, cur_fig, y_cut] = plot_and_cut_data(y, CFG, file_name)
    
    file_processed = 0;
    times = y(CFG.time_channel,:)';

    cut_beginning_end = 1;
    y_cut = plot_EEG(y, CFG, file_name, cut_beginning_end);

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

            [file_processed, cur_fig, y_cut] = plot_and_cut_data(y, CFG, file_name);
        end
        file_processed = 1;
    else
        cur_fig = gcf;
        file_processed = 1;
    end