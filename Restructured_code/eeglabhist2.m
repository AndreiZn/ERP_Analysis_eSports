% EEGLAB history file generated on the 09-Oct-2019
% ------------------------------------------------

EEG.etc.eeglabvers = '14.1.2'; % this tracks which version of EEGLAB is being used, you may ignore it
EEG = pop_loadset('filename','sub0001_1_1_1_init.set','filepath','C:\\Users\\user.T440_IT\\AndreiZn\\ERP_esports\\ERP_esports_data\\sub0001_20190403\\');
EEG = eeg_checkset( EEG );
EEG = eeg_checkset( EEG );
EEG = pop_epoch( EEG, {  }, [-0.2        0.45], 'newname', 'sub0001_1_1_1 epochs', 'epochinfo', 'yes');
EEG = eeg_checkset( EEG );
EEG = pop_rmbase( EEG, [-200    0]);
EEG = eeg_checkset( EEG );
EEG = pop_rmbase( EEG, [-200    0]);
EEG = eeg_checkset( EEG );
