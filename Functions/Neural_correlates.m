function [mental_conc, visuospatial_att, emotion_state] = Neural_correlates(EEG, epoch_boundary)

mental_conc_ch = 'Fp1';
visuospatial_att_ch = 'Oz';
emotion_state_ch1 = 'F3';
emotion_state_ch2 = 'F4';

mental_conc_ch_idx = [];
visuospatial_att_ch_idx = [];
emotion_state_ch1_idx = [];
emotion_state_ch2_idx = [];

mental_conc_band = [4 7]; % theta band
visuospatial_att_band = [8 12]; % alpha band
emotion_state_band = [1 30]; 

chan_info = EEG.chanlocs;
for ch_idx = 1:numel(chan_info)
    label = chan_info(ch_idx).labels;
    if strcmp(mental_conc_ch, label)
        mental_conc_ch_idx = ch_idx;
    end
    if strcmp(visuospatial_att_ch, label)
        visuospatial_att_ch_idx = ch_idx;
    end
    if strcmp(emotion_state_ch1, label)
        emotion_state_ch1_idx = ch_idx;
    end
    if strcmp(emotion_state_ch2, label)
        emotion_state_ch2_idx = ch_idx;
    end
end

% Calculate spectral power
[spectra, freq] = pop_spectopo(EEG, 1, epoch_boundary, 'EEG','electrodes','on');
close(gcf)

mental_conc = NaN;
if ~isempty(mental_conc_ch_idx)
    low_fr_idx = find(freq > mental_conc_band(1), 1);
    up_fr_idx = find(freq > mental_conc_band(2), 1) - 1;
    mental_conc = mean(spectra(1, low_fr_idx:up_fr_idx));
end

visuospatial_att = NaN;
if ~isempty(visuospatial_att_ch_idx)
    low_fr_idx = find(freq > visuospatial_att_band(1), 1);
    up_fr_idx = find(freq > visuospatial_att_band(2), 1) - 1;
    visuospatial_att = mean(spectra(1, low_fr_idx:up_fr_idx));
end

emotion_state = NaN;
if ~isempty(emotion_state_ch1_idx) && ~isempty(emotion_state_ch2_idx)
    low_fr_idx = find(freq > emotion_state_band(1), 1);
    up_fr_idx = find(freq > emotion_state_band(2), 1) - 1;
    emotion_state = mean(spectra(1, low_fr_idx:up_fr_idx));
end