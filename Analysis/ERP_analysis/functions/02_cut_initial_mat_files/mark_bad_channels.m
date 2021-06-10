% the function mark_bad_channels allows to visually investigate data and
% mark clearly bad channels
function [cur_fig, bad_ch_idx, bad_ch_lbl] = mark_bad_channels(y, CFG, file_name)

%% Define flags 
% bad channels are not found yet
bad_channels_found = 0;
% plot without beginning and end
cut_beginning_end = 0;
% mark bad channels mode
mark_bad_chs = 1;

%% plot data without any chanels marked as bad ones
bad_chs = [];
% [~] = plot_EEG(y, CFG, file_name, cut_beginning_end, mark_bad_chs, bad_chs);

%% loop while the user confirms that all bad channels are highlighted
while ~bad_channels_found
%     ret = listdlg('ListString',CFG.ch_labels,'PromptString',sprintf('Select channels to be removed:'), 'InitialValue', bad_chs);
%     close(gcf)
    
%     bad_chs = ret;
%     [~] = plot_EEG(y, CFG, file_name, cut_beginning_end, mark_bad_chs, bad_chs);
    
    bad_channels_found = 1;
    
%     answer = questdlg('Confirm that all bad channels have been marked red', 'Bad channels', ...
%         'Yes', 'No', 'Yes');
%     switch answer
%         case 'Yes'
%             bad_channels_found = 1;
%         case 'No'
%             bad_channels_found = 0;
%     end
end

%% save idx and labels of marked channels and save the current figure
bad_ch_idx = bad_chs;
bad_ch_lbl = CFG.ch_labels(bad_chs);
cur_fig = gcf;
