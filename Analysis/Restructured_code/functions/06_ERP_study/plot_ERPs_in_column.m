function plot_ERPs_in_column(ERPs_cur, ch_idx, bin_idx)

num_files = size(ERPs_cur,1);
ERP_exmp = ERPs_cur(end);
lbls = {ERP_exmp.chanlocs.labels};
channel_lbl_to_plot = lbls{ch_idx};
highlight_color = {'r'; 'c'};

figure('units','normalized','outerposition',[0 0 0.3 1])
times = ERP_exmp.times;
delta_y = 40;

ytick_value = zeros(num_files,1);
ytick_label = cell(num_files,1);

for dst_i = 1:num_files
    ERP_cur = ERPs_cur(dst_i);   
    ERP_data = ERP_cur.bindata(ch_idx, :, bin_idx);
    const_delta = delta_y*(num_files-dst_i+1);
    data_to_plot = ERP_data + const_delta;
    baseline = linspace(const_delta, const_delta, numel(times));
    mean_line = mean(data_to_plot)*ones(numel(times),1);
    ytick_value(dst_i) = mean(baseline);
    ytick_label{dst_i} = ERP_cur.subject;
    plot(times, data_to_plot, 'Color', 'b')
    hold on
    plot(times, mean_line, '--k')
    
    tp_g_mean_idx = data_to_plot > mean_line';
    if ERP_cur.pro == 1
        gr_idx = 1;
    else
        gr_idx = 2;
    end
    h = scatter(times(tp_g_mean_idx), data_to_plot(tp_g_mean_idx), 5, highlight_color{gr_idx});

end

h_pro = plot(0,0,'color','r');
h_npro = plot(0,0,'color','c');

title(['ERP data plot, exp: ' ERP_cur.exp_id, ', channel: ', channel_lbl_to_plot], 'Interpreter', 'None')
xlabel('Time, ms')
ylabel('Amplitude, mcV')
ylim = [0, delta_y*(1+num_files)];
plot([0, 0], [0, max(ylim)], '--k')
set(gca, 'ylim', ylim, 'Ytick', ytick_value(end:-1:1), 'YTickLabel', ytick_label(end:-1:1))
legend([h_pro, h_npro], {'ERP above mean, pro'; 'ERP above mean, non-pro'})
%plot_name = ['ERP_channel_', CFG.channel_lbl_to_plot];
