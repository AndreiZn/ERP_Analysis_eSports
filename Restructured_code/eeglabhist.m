% EEGLAB history file generated on the 05-Nov-2019
% ------------------------------------------------

EEG.etc.eeglabvers = '14.1.2'; % this tracks which version of EEGLAB is being used, you may ignore it
EEG = eeg_checkset( EEG );
EEG = pop_loadset('filename','sub0022_2_2_2_IC_marked_for_rejection.set','filepath','E:\\ERP_esports\\ERP_esports_output\\stage_6_reject_IC_semi_automatic\\data\\sub0022_20190407\\');
EEG = eeg_checkset( EEG );
figure; pop_plottopo(EEG, [1:32] , 'sub0022_2_2_2_epochs', 0, 'ydir',1);
EEG = pop_subcomp( EEG, [1   4   8  10  11  14  18  19  23  24  28  29  30  31], 0);
EEG = eeg_checkset( EEG );
