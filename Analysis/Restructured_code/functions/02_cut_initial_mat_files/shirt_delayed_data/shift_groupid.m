% shift_groupid function works with 01_ERP_data_cut data folder
% Shift groupid by observed latency CFG.groupid_latency_ms
function CFG = shift_groupid(CFG)

%% Define function-specific variables
CFG.output_data_folder_name = ['stage_1_shift', filesep, 'data'];
CFG.output_plots_folder_name = ['stage_1_shift', filesep, 'plots'];

CFG.output_data_folder = [CFG.output_folder_path, filesep, CFG.output_data_folder_name];
if ~exist(CFG.output_data_folder, 'dir')
    mkdir(CFG.output_data_folder)
end

CFG.output_plots_folder = [CFG.output_folder_path, filesep, CFG.output_plots_folder_name];
if ~exist(CFG.output_plots_folder, 'dir')
    mkdir(CFG.output_plots_folder)
end

%% Loop through folders
subject_folders = dir(CFG.data_folder_path );
subject_folders = subject_folders(3:end);

for subi=1:numel(subject_folders)
    % read subject folder
    subj_folder = subject_folders(subi);
    folderpath = fullfile(subj_folder.folder, subj_folder.name);
    files = dir(folderpath);
    dirflag = ~[files.isdir] & ~strcmp({files.name},'..') & ~strcmp({files.name},'.') & ~strcmp({files.name},'.DS_Store');
    files = files(dirflag);
    for filei=1:numel(files)
        % read file
        file_struct = files(filei);
        filepath = fullfile(file_struct.folder, file_struct.name);
        file = load(filepath);
        y = file.y_cut; bad_ch_idx = file.bad_ch_idx; bad_ch_lbl = file.bad_ch_lbl;
        file_name = file_struct.name(1:end-4);
        
        % get experiment ID
        exp_id = file_struct.name(9:13);
        
        % create output folders
        CFG.output_data_folder_cur = [CFG.output_data_folder, filesep, subj_folder.name];
        if ~exist(CFG.output_data_folder_cur, 'dir')
            mkdir(CFG.output_data_folder_cur)
        end 
        CFG.output_plots_folder_cur = [CFG.output_plots_folder, filesep, subj_folder.name];
        if ~exist(CFG.output_plots_folder_cur, 'dir')
            mkdir(CFG.output_plots_folder_cur)
        end

        % get channel idx-s
        time_ch = CFG.time_channel;
        %eeg_ch = CFG.EEG_channels;
        groupid_ch = CFG.groupid_channel;
        DI_ch = CFG.DI_channel;
        arduino_ch = CFG.ard_channel;
        
        % get the total event length (image appearance + inner interval) and the length of image appearance
        image_app_s = CFG.exp_param(exp_id).epoch_boundary_s(2) - CFG.exp_param(exp_id).epoch_boundary_s(1);
        total_event_s = image_app_s + CFG.exp_param(exp_id).target_spacer_s;
        CFG.event_length_s = total_event_s;
        CFG.image_appearance_time_s = image_app_s;
        
        %calculte the number of the events from the groupid data
        groupid = y(groupid_ch, :);
        groupid_events = groupid(groupid >= 0);
        num_events = round(numel(find(diff(groupid_events)))/2);
        
        % get data from the variable y
        time = y(time_ch, :);
        groupid = y(groupid_ch, :);
        DI = y(DI_ch, :);
        arduino = y(arduino_ch, :);
        
        % calculate the sample rate of the EEG device
        eeg_sample_rate = 1/(time(2) - time(1));
        CFG.eeg_sample_rate = eeg_sample_rate;
        
        % change scale for visualization purposes
        arduino = arduino / max(arduino);
        DI = DI / max(DI);
        
        % visualize initial data
        if CFG.visualize_init_data_flag
            figure();
            plot(time, groupid)
            hold on
            plot(time, arduino)
            plot(time, DI)
            legend('groupid', 'arduino', 'DI')
        end
        
        % save initial variables
        groupid_init = groupid;
        arduino_init = arduino;
        DI_init = DI;
        
        % convert to time samples (detect time points when the groupid and arduino values were changing and when the tapping occurred)
        [groupid, ~, arduino, DI] = convert_to_ts(groupid, [], arduino, DI, [], CFG);
        
        assert(numel(groupid) == num_events, 'number of groupid triggers is not equal to the number of events')
        assert(numel(arduino) == num_events, 'number of arduino triggers is not equal to the number of events')
        assert(numel(DI) == num_events, 'number of DI triggers is not equal to the number of events')
        
        % calculate delay of the DI channel
        
        %delay_ms(filei, 1:num_events) = 1000*(DI - arduino)/eeg_sample_rate;
        % calculate delay of the groupid channel
        %delay_G_Ard_ms(filei, 1:num_events) = 1000*(groupid - arduino)/eeg_sample_rate;
        
        %disp(numel(find(delay_ms(filei,:) < 0)))
        
        %visualize data with triggers
        if CFG.visualize_trig_data_flag
            figure();
            % handles
            h = zeros(6,1);
            h(1) = plot(time, 1.2 * groupid_init);
            hold on
            h(2) = plot(time, 1.1 * arduino_init);
            h(3) = plot(time, DI_init);
            xlim([0, time(end)])
            ylim([-1, 2])
            for idx = 1:numel(groupid)
                h(4) = plot([groupid(idx), groupid(idx)]/eeg_sample_rate, [-1 2], 'LineStyle', '--', 'Color', 'b');
                h(5) = plot([arduino(idx), arduino(idx)]/eeg_sample_rate, [-1 2], 'LineStyle', '--', 'Color', 'r');
                h(6) = plot([DI(idx), DI(idx)]/eeg_sample_rate, [-1 2], 'LineStyle', '--', 'Color', 'k');
            end
            legend(h, {'groupid'; 'arduino'; 'DI'; 'groupid trigger'; 'arduino trigger'; 'DI trigger'});
        end
        
        % visualize delay over time
        if CFG.visualize_delay_over_time_flag
            figure();
            plot_data = 1000*(DI - arduino)/eeg_sample_rate;
            h = plot(plot_data);
            xlabel('Event #')
            ylabel('Delay, ms')
            legend(h, {'DI delay'});
            ylim([0, 1.1*max(plot_data)])
            set(gca, 'fontsize', 14)
            
            
            figure();
            plot_data = 1000*(groupid - arduino)/eeg_sample_rate;
            h = plot(plot_data);
            xlabel('Event #')
            ylabel('Delay, ms')
            legend(h, {'GroupID delay'});
            ylim([0, 1.1*max(plot_data)])
            set(gca, 'fontsize', 14)
        end
        
        keyboard
        
        
        
        % shidt groupid
        groupid = y(CFG.groupid_channel, :);
        shift_ts = round(CFG.sample_rate * CFG.groupid_latency_ms/1000);
        % form new indices
        total_num_samples = size(groupid,2);
        new_idx = shift_ts+1:total_num_samples;
        new_groupid = [groupid(1,new_idx), zeros(1,shift_ts)];
        y(CFG.groupid_channel, :) = new_groupid;
        
        % shift EEG data
        EEG_channels = [CFG.time_channel, CFG.EEG_channels];
        eeg = y(EEG_channels, :);
        shift_ts = round(CFG.sample_rate * CFG.base_station_latency_ms/1000);
        new_idx = shift_ts+1:total_num_samples;
        new_eeg = [eeg(:,new_idx), zeros(numel(EEG_channels),shift_ts)];
        y(EEG_channels, :) = new_eeg;
        
%         cur_fig = figure();
%         plot(groupid);
%         hold on
%         plot(y(CFG.groupid_channel, :))
%         plot(eeg(CFG.time_channel,:))
%         plot(y(CFG.time_channel, :))
%         legend('init groupid', 'shifted groupid', 'init time ch', 'shifted time ch')
%         % save plot
%         saveas(cur_fig, [CFG.output_plots_folder_cur, filesep, 'Plot_', file_struct.name(1:end-3), 'png'])
%         close(cur_fig);
        
        % to keep processing pipeline consistent, it's easier to save y as
        % y_cut for the next script
        y_cut = y;
        
        % save cut_data and bad_chs
        if strcmp(file_struct.name(end-3:end), '.mat')
            file_name = file_struct.name(1:end-4);
        else
            file_name = file_struct.name;
        end
        save([CFG.output_data_folder_cur, filesep, file_name, '_shifted_data'], 'y_cut', 'bad_ch_idx', 'bad_ch_lbl')
    end
end