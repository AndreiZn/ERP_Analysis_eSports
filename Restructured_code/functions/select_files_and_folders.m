% Select the channel location file, the data folder
function CFG = select_files_and_folders(CFG)

%% Select a folder with data files
    CFG.initial_data_folder = uigetdir('./','Select a root folder with data files...');
    subject_folders = dir(CFG.initial_data_folder);
    subject_folders = subject_folders(3:end);
    
    for subi=1:numel(subject_folders)
        subj_folder = subject_folders(subi);
    end
    files = dir(CFG.initial_data_folder);
    dirflag = ~[files.isdir] & ~strcmp({files.name},'..') & ~strcmp({files.name},'.');
    CFG.data_files = files(dirflag);
    CFG.num_sessions = size(CFG.data_files,1);
    fprintf('Number of data files found is: %d \n', CFG.num_sessions);