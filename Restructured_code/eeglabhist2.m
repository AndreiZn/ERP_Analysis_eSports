% EEGLAB history file generated on the 08-Oct-2019
% ------------------------------------------------

EEG.etc.eeglabvers = '14.1.2'; % this tracks which version of EEGLAB is being used, you may ignore it
EEG = pop_loadset('filename','sub0001_1_1_1_init.set','filepath','C:\\Users\\user.T440_IT\\AndreiZn\\ERP_esports\\ERP_esports_data\\sub0001_20190403\\');
EEG = eeg_checkset( EEG );
EEG = pop_eegfiltnew(EEG, 1,30,826,0,[],0);
EEG = eeg_checkset( EEG );
