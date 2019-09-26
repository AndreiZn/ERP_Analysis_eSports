function [EEG] = import_mat_to_eeglab(CFG, mat_file_path, eeglab_set_name, sub_ID)

EEG = pop_importdata('dataformat','matlab','nbchan',0,'data',mat_file_path,'setname',eeglab_set_name,'srate',CFG.sample_rate,'subject',sub_ID,'pnts',0,'xmin',0);
EEG = eeg_checkset(EEG);
EEG = pop_chanevent(EEG, CFG.total_num_channels,'edge','leading','edgelen',0);
EEG = eeg_checkset(EEG);
EEG = pop_select(EEG,'channel',CFG.EEG_channels);
EEG = eeg_checkset(EEG);
EEG = pop_editset(EEG, 'chanlocs', CFG.electrode_location_file);
EEG = eeg_checkset(EEG);
