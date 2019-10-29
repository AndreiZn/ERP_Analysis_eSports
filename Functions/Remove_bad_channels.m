function [EEG, indelec] = Remove_bad_channels(EEG, set_name, output_suffix, output_folder_cur)

[EEG, indelec, ~, ~] = pop_rejchan(EEG, 'elec',[1:EEG.nbchan] ,'threshold',5,'norm','on','measure','kurt');
output_set_name = [set_name, '_', output_suffix, '.set'];
EEG = pop_saveset( EEG, 'filename',output_set_name,'filepath',output_folder_cur);