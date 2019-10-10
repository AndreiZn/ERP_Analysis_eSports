function callback_reject_button_pressed(CFG, EEG)

% visualize data using the eeglab function eegplot
fig = eeglab_plot_EEG(EEG, CFG);
cur_set_name = [CFG.eeglab_set_name, '_02after_rejection'];
saveas(fig,[CFG.output_plots_folder_cur, '\', cur_set_name '_plot','.png'])
close(fig)

% save the eeglab dataset
output_set_name = [CFG.eeglab_set_name, '_after_trial_rejection', '.set'];
EEG = pop_saveset(EEG, 'filename',output_set_name,'filepath',CFG.output_data_folder_cur);
eeg_checkset(EEG);