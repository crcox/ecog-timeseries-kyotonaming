function [] = plot_all_electrodes_epoch(ecog, tags, vt_electrode_labels, config)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    vt_electrode_labels = string(vt_electrode_labels);
    electrode_labels =  strtrim(string(ecog.DIM(2).label));
    vt_electrode_z = ismember(electrode_labels, vt_electrode_labels);
    ecog.DATA = ecog.DATA(:, vt_electrode_z); % drop electrodes not in the vTL
    vt_electrode_labels = electrode_labels(vt_electrode_z);
    n_electrodes = size(ecog.DATA, 2);


    Hz = 1 / ecog.DIM(1).interval;
    baseline_ticks = Hz * (config.baseline_ms / 1000);
    trial_ticks = Hz * (config.trial_ms / 1000);
    boxcar_ticks = Hz * (config.boxcar_ms / 1000);
    epoch_ticks = baseline_ticks + trial_ticks;
    
    n_sessions = size(tags, 1);

    stim_tbl = table(strtrim(string(cat(1, config.stimuli{:}))), cat(2, tags{:})', 'VariableNames', ["stimulus", "tick"]);
    stimuli = sort(unique(stim_tbl.stimulus));
    n_stimuli = length(stimuli);
    stim_epoch = cell(2, n_stimuli);
    for panel_i = 1:100
        stim_onset = stim_tbl.tick(stim_tbl.stimulus == stimuli{panel_i});
        r = [stim_onset(:) - baseline_ticks, stim_onset(:) + trial_ticks - 1];
        stim_epoch{1, panel_i} = permute(cat(3, ...
            ecog.DATA(r(1, 1):r(1, 2), :), ...
            ecog.DATA(r(2, 1):r(2, 2), :), ...
            ecog.DATA(r(3, 1):r(3, 2), :), ...
            ecog.DATA(r(4, 1):r(4, 2), :) ...
        ), [1, 3, 2]);
        stim_epoch{1, panel_i} = squeeze(mean(reshape(stim_epoch{1, panel_i}, boxcar_ticks, epoch_ticks / boxcar_ticks, n_sessions, n_electrodes), 1));
        baseline_ticks_ds = baseline_ticks / boxcar_ticks;
        % Subtract mean of baseline from every electrode in every session for the current stimulus.
        stim_epoch{2, panel_i} = stim_epoch{1, panel_i} - mean(stim_epoch{1, panel_i}(1:baseline_ticks_ds, :, :), 1);
    end

    % Adjust for downsampling
    Hz = Hz / boxcar_ticks;
    epoch_ticks = epoch_ticks / boxcar_ticks;
    interval_ms = (1000 / Hz);
    x_ms = linspace(-config.baseline_ms, config.trial_ms - interval_ms, epoch_ticks);

    pages = ceil(n_stimuli / config.plots_per_page);

    fig = figure("Visible","on");
    set(fig, 'Units', 'inches', 'Position', [0, 0, 8, 11.5], 'PaperUnits', 'inches', 'PaperSize', [8, 11.5]);
    axes = gobjects(config.plots_per_page * 2, 1);
    for electrode_index = 1:n_electrodes
        electrode_label = vt_electrode_labels(electrode_index);
        fig_dir = fullfile("figures", "epoch", config.subject_label, electrode_label);
        
        if not(isfolder(fig_dir))
            mkdir(fig_dir);
        end

        stim_i = 0;
        data_i = 0;
        for page = 1:pages
            for panel_i = 1:(config.plots_per_page * 2)
                data_i = data_i + 1;
                if mod(panel_i, 2)
                    stim_i = stim_i + 1;
                    if stim_i > n_stimuli
                        break
                    end
                end
                axes(panel_i) = subplot(4, 2, panel_i, "replace");
                plot(x_ms, stim_epoch{data_i}(:, :, electrode_index));
                if panel_i > (config.plots_per_page * 2) - 2
                    xlabel('ms relative to stimulus onset');
                end
                xlim([-200, 2000]);
                if mod(panel_i, 2)
                    ylabel('voltage (raw)');
                else
                    ylabel('voltage (baseline adjusted)');
                end
                title(sprintf('subject: %s electrode: %s stimulus: %s', config.subject_label, electrode_label, stimuli(stim_i)));
                xline(0, '--');
            end
            linkaxes(axes, 'y');
            fig_path = fullfile(fig_dir, sprintf("sub-%s_elec-%s_label-epoch_page-%03d.pdf", config.subject_label, electrode_label, page));
            print(fig_path, '-dpdf');
            for panel_i = 1:4
                cla(axes(panel_i), 'reset');
            end
        end
    end
end
