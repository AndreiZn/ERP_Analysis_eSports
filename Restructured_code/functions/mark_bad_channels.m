function mark_bad_channels(y, CFG, file_name)

bad_channels_found = 0;

cut_beginning_end = 0;
mark_bad_chs = 1;
bad_chs = [];
[~] = plot_EEG(y, CFG, file_name, cut_beginning_end, mark_bad_chs, bad_chs);

while ~bad_channels_found
    ret = listdlg('ListString',CFG.ch_labels,'PromptString',sprintf('Select channels to be removed:'), 'InitialValue', bad_chs);
    close(gcf)
    
    bad_chs = ret;
    [~] = plot_EEG(y, CFG, file_name, cut_beginning_end, mark_bad_chs, bad_chs);
    
    answer = questdlg('Confirm that all bad channels have been marked red', 'Bad channels', ...
        'Yes', 'No', 'Yes');
    switch answer
        case 'Yes'
            bad_channels_found = 1;
        case 'No'
            bad_channels_found = 0;
    end
end

saveas(gcf, [CFG.output_plots_folder_cur, '\Plot_Bad_chs_', file_name, '.png'])
close(gcf)