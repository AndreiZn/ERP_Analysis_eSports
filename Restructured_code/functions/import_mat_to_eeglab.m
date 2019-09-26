function [EEG] = import_mat_to_eeglab(CFG, y, eeglab_set_name, sub_ID)

assignin('base','y',y)
EEG = pop_importdata('dataformat','array','nbchan',0,'data','y','setname',eeglab_set_name,'srate',CFG.sample_rate,'subject',sub_ID,'pnts',0,'xmin',0);
EEG = eeg_checkset(EEG);
EEG = pop_chanevent(EEG, CFG.groupid_channel,'edge','leading','edgelen',0);
EEG = eeg_checkset(EEG);
EEG = pop_select(EEG,'channel',CFG.EEG_channels);
EEG = eeg_checkset(EEG);
EEG = pop_editset(EEG, 'chanlocs', CFG.electrode_location_file);
EEG = eeg_checkset(EEG);
