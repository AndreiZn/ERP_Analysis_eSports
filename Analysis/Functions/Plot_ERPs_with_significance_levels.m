function Plot_ERPs_with_significance_levels(ERP_pro_and_nong, bins, combined_results_output_folder, exp_id, p_threshold, num_bins, num_channels, latency_array, output_folder, fig_title, chs_to_plot, xy_labels, subplot_n_lines, subplot_n_cols, x_tick_step)

[latency_significance_matrix] = Return_significant_latencies(combined_results_output_folder, exp_id, p_threshold, latency_array);

for bin_idx = 1:1
    
    figure('position', [0,0,1400,800]);
    
    if isempty(subplot_n_lines)
        subplot_n_lines = 6;
    end
    if isempty(subplot_n_cols)
        subplot_n_cols = 6;
    end
    
    ymin = min([min(min(ERP_pro_and_nong.bindata(:, :, bins(1)))), min(min(ERP_pro_and_nong.bindata(:, :, bins(2))))]);
    ymax = max([max(max(ERP_pro_and_nong.bindata(:, :, bins(1)))), max(max(ERP_pro_and_nong.bindata(:, :, bins(2))))]);
    
    if ymin < -20
        ymin = -20;
    end
    if ymax > 20
        ymax = 20;
    end
    
    for ch_idx = chs_to_plot
        
        if numel(chs_to_plot) > 1
            subplot_idx = find(chs_to_plot == ch_idx) + subplot_n_cols;
            subplot(subplot_n_lines, subplot_n_cols, subplot_idx);
        end
        
        times = ERP_pro_and_nong.times;
        plot(times, ERP_pro_and_nong.bindata(ch_idx, :, bins(1)), 'r');
        hold on;
        plot(times, ERP_pro_and_nong.bindata(ch_idx, :, bins(2)), 'b');
        set(gca, 'xlim', [min(times), max(times)])
        set(gca, 'ylim', [ymin, ymax])
        if ~isempty(x_tick_step)
            set(gca, 'xtick', min(times):x_tick_step:max(times))
        end
        if xy_labels
            xlabel('Latency, ms')
            ylabel('Amplitude, uV')
        end
        title(ERP_pro_and_nong.chanlocs(ch_idx).labels)
        grid on;
        
        significance_indicator = squeeze(latency_significance_matrix(ch_idx, bin_idx, :));
        sign_latency_idx = logical(significance_indicator);
        sign_latency = latency_array(sign_latency_idx);
        
        half_window = round(0.5*(latency_array(2) - latency_array(1))); % draw signif level at +- half window box
        
        for idx = 1:numel(sign_latency)
            X = [sign_latency(idx) - half_window, sign_latency(idx) + half_window];
            area(X, ymax*ones(size(X)), 'FaceColor', [0, 1, 0], 'FaceAlpha', 0.2, 'EdgeAlpha', 0);
        	area(X, ymin*ones(size(X)), 'FaceColor', [0, 1, 0], 'FaceAlpha', 0.2, 'EdgeAlpha', 0);
        end
        plot(times, zeros(size(times)), 'k', 'linewidth', 0.3);
        plot(zeros(2), [ymin, ymax], 'k', 'linewidth', 0.3);
    end
    
    % legend:
    if numel(chs_to_plot) > 1
        subplot(subplot_n_lines, subplot_n_cols, 1);
        
        data_legend_pro = ERP_pro_and_nong.bindata(ch_idx, :, bins(1));
        data_legend_nong = ERP_pro_and_nong.bindata(ch_idx, :, bins(2)) + 4;
        if strcmp(exp_id, '1_1_2')
            X_legend = [300, 440];
        else
            X_legend = [500, 650];
        end
        
        plot(times, data_legend_pro, 'r')
        hold on;
        plot(times, data_legend_nong, 'b');
        set(gca, 'xlim', [min(times), max(times)])
        set(gca, 'ylim', [ymin, ymax])
        xlabel('Latency, ms')
        ylabel('Amplitude, uV')
        title('Legend:')
        grid on;
        area(X_legend, ymax*ones(size(X_legend)), 'FaceColor', [0, 1, 0], 'FaceAlpha', 0.2, 'EdgeAlpha', 0);
        area(X_legend, ymin*ones(size(X_legend)), 'FaceColor', [0, 1, 0], 'FaceAlpha', 0.2, 'EdgeAlpha', 0);
        plot(times, zeros(size(times)), 'k', 'linewidth', 0.3);
        plot(zeros(2), [ymin, ymax], 'k', 'linewidth', 0.3);
        legend('Pro', 'Non-pro', 'p<0.05', 'fontsize', 8, 'location', 'northwest')
    end
    
    output_image_name = [output_folder, exp_id, '_pro_vs_nong_target_with_signif.png'];
    saveas(gcf, output_image_name)
    close(gcf)
end