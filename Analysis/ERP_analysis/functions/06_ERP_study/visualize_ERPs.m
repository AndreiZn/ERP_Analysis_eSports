%%% Visuzlize ERPs %%%

function visualize_ERPs(CFG,ERP_combined)

ERP_exmp = ERP_combined(end);

if CFG.plot_ERPs
    for ch_idx = ch_ids
        
        lbls = {ERP_exmp.chanlocs.labels};
        CFG.channel_lbl_to_plot = lbls{ch_idx};
        CFG.channel_idx_to_plot = ch_idx;%find(contains({ERP.chanlocs.labels},CFG.channel_lbl_to_plot));
        if CFG.plot_diff_only
            CFG.bin_to_plot = 3; % difference between responses to target and non-target stimuli
            line_styles = {'-b'};
        else
            CFG.bin_to_plot = [1, 2, 3];
            line_styles = {'-r'; '-b'; '-g'};
        end
        
        for exp_idx = 1:numel(exp_IDs)
            
            exp_id_cur = exp_IDs(exp_idx);
            ERP_idx = find(contains({ERP_combined.exp_id},exp_id_cur));
            
            CFG.output_plots_folder_cur = [CFG.output_plots_folder, filesep, exp_id_cur{:}];
            if ~exist(CFG.output_plots_folder_cur, 'dir')
                mkdir(CFG.output_plots_folder_cur)
            end
            
            
            
            figure('units','normalized','outerposition',[0 0 0.3 1])
            times = ERP_combined(ERP_idx(1)).times;
            
            if CFG.normalize_ERP
                delta_y = 4;
            else
                if CFG.plot_diff_only
                    delta_y = 10;
                else
                    delta_y = 40;
                end
            end
            
            ytick_value = zeros(numel(ERP_idx),1);
            ytick_label = cell(numel(ERP_idx),1);
            
            for dst_i = 1:numel(ERP_idx)
                dst_idx = ERP_idx(dst_i);
                ERP_cur = ERP_combined(dst_idx);
                
                for bin_idx = 1:numel(CFG.bin_to_plot)
                    bin_to_plot = CFG.bin_to_plot(bin_idx);
                    ERP_data = ERP_cur.bindata(CFG.channel_idx_to_plot, :, bin_to_plot);
                    const_delta = delta_y*(numel(ERP_idx)-dst_i+1);
                    if CFG.normalize_ERP
                        max_amp = max(max(abs(ERP_cur.bindata(CFG.channel_idx_to_plot, :, CFG.bin_to_plot))));
                        ERP_data = ERP_data/max_amp;
                    end
                    data_to_plot = ERP_data + const_delta;
                    baseline = linspace(const_delta, const_delta, numel(times));
                    
                    ytick_value(dst_i) = mean(baseline);
                    ytick_label{dst_i} = ERP_cur.subject;
                    line_style = line_styles{bin_idx};
                    plot(times, data_to_plot, line_style)
                    hold on
                end
                
                plot(times, baseline, '--k')
            end
            
            title(['ERP data plot, channel: ', CFG.channel_lbl_to_plot], 'Interpreter', 'None')
            xlabel('Time, ms')
            ylabel('Amplitude, mcV')
            ylim = [0, delta_y*(1+numel(ERP_idx))];
            plot([0, 0], [0, max(ylim)], '--k')
            time_400_ms_idx = dsearchn(times', 400);
            plot([times(time_400_ms_idx), times(time_400_ms_idx)], [0, max(ylim)], '--k')
            set(gca, 'ylim', ylim, 'Ytick', ytick_value(end:-1:1), 'YTickLabel', ytick_label(end:-1:1))
            
            plot_name = ['ERP_channel_', CFG.channel_lbl_to_plot];
            saveas(gcf,[CFG.output_plots_folder_cur, filesep, plot_name,'.png'])
            close(gcf)
        end
    end
end