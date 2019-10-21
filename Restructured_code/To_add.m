

%% Plot ERPs
if plot_ERP_flag
    [ERP] = Plot_ERP_waveforms(ERP, EEG.nbchan, epoch_boundary, ar_rm_from_ch, set_name, output_folder_cur, plot_animation_flag);
end
%% Plot ERP images
if plot_ERP_Im_flag
    for channel_idx = 1:EEG.nbchan
        Plot_ERP_Image(EEG, target_bin, set_name, output_folder_cur, channel_idx)
    end
end