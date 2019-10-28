% EEGLAB history file generated on the 28-Oct-2019
% ------------------------------------------------

EEG.etc.eeglabvers = '14.1.2'; % this tracks which version of EEGLAB is being used, you may ignore it
EEG = eeg_checkset( EEG );
EEG = pop_loadset('filename','sub0002_2_2_2_IC_marked_for_rejection.set','filepath','E:\\ERP_esports\\ERP_esports_output\\stage_6_reject_IC_automatic\\data\\sub0002_20190402\\');
EEG = eeg_checkset( EEG );
pop_selectcomps(EEG, [1:31] );
