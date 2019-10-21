function [CFG, EEG] = load_eventlist_and_epoch(CFG, EEG)

% Import ERPLAB eventlist from a text file
elist_path = CFG.elist_path;
EEG  = pop_editeventlist(EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99}, 'BoundaryString', { 'boundary' }, 'List', elist_path, 'SendEL2', 'EEG', 'UpdateEEG', 'codelabel', 'Warning', 'on' );

% Overwrites EEG.event.type using information from EEG.EVENTLIST.eventinfo
EEG = pop_overwritevent(EEG, 'codelabel');
EEG = eeg_checkset(EEG);

% Split into epochs and remove baseline
EEG = pop_epochbin(EEG, CFG.epoch_boundary_ms,  'pre');
EEG = eeg_checkset(EEG);

%EEG = pop_saveset( EEG, 'filename',output_set_name,'filepath',output_folder_cur);