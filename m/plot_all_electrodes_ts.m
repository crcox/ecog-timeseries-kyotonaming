function [] = plot_all_electrodes_ts(ecog, tags, vt_electrode_labels, config)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    vt_electrode_labels = string(vt_electrode_labels);
    electrode_labels =  strtrim(string(ecog.DIM(2).label));
    [vt_electrode_z, vt_electrode_ix] = ismember(vt_electrode_labels, electrode_labels);
    ecog.DATA = ecog.DATA(:, vt_electrode_z); % drop electrodes not in the vTL
    [~, vt_electrode_sort] = sort(vt_electrode_ix);
    vt_electrode_labels = vt_electrode_labels(vt_electrode_sort);
    n_electrodes = size(ecog.DATA, 2);

    Hz = 1 / ecog.DIM(1).interval;
    baseline_ticks = Hz * (config.baseline_ms / 1000);
    trial_ticks = Hz * (config.trial_ms / 1000);
    boxcar_ticks = Hz * (config.boxcar_ms / 1000);
    
    n_sessions = size(tags, 1);
    [session_ranges, session_ticks, session_ix] = session_range(tags, baseline_ticks, trial_ticks, boxcar_ticks);


    X = permute(squeeze(...
        mean(...
            reshape(...
                ecog.DATA(session_ix, :), ...
                [boxcar_ticks, session_ticks / boxcar_ticks, n_sessions, n_electrodes]),...
            1)), [1, 3, 2]);
    
    % Adjust for downsampling
    Hz = Hz / boxcar_ticks;
    session_ticks = size(X, 1);
    interval_ms = (1000 / Hz);
    interval_s = interval_ms / 1000;

    plot_window_ticks = config.plot_window_s * Hz;
    for i = 1:n_sessions
        tags{i} = round((tags{i} - session_ranges(i, 1)) / boxcar_ticks);
    end
    
    lastpage_ticks = mod(session_ticks, plot_window_ticks * config.plots_per_page);
    pages = ((session_ticks - lastpage_ticks) / (plot_window_ticks * config.plots_per_page)) + 1;

    fig = figure();
    set(fig, 'Units', 'inches', 'Position', [0, 0, 8, 11.5], 'PaperUnits', 'inches', 'PaperSize', [8, 11.5]);
    axes = gobjects(config.plots_per_page, 1);
    for session_index = 1:n_sessions
        for electrode = 1:n_electrodes
            electrode_index = vt_electrode_ix(electrode);
            electrode_label = vt_electrode_labels(electrode);
            fig_dir = fullfile("figures", config.subject_label, electrode_label);
            
            if not(isfolder(fig_dir))
                mkdir(fig_dir);
            end

            cur = 0;
            for page = 1:pages
                for i = 1:config.plots_per_page
                    a_ticks = cur + 1;
                    if a_ticks > session_ticks
                        break
                    end
                    b_ticks = cur + plot_window_ticks;
                    if b_ticks > session_ticks
                        b_ticks = session_ticks;
                    end
                    a_s = (a_ticks - 1) * interval_s;
                    b_s = (b_ticks - 1) * interval_s;
                    b_s_full = ((cur + plot_window_ticks) - 1) * interval_s;
                    axes(i) = subplot(4, 1, i, "replace");
                    seconds = linspace(a_s, b_s, (b_ticks - a_ticks) + 1);
                    ix = a_ticks:b_ticks;
                    plot(seconds, X(ix, electrode_index, session_index));
                    if i == 4 || (b_ticks == session_ticks)
                        xlabel('seconds from session onset');
                    end
                    ylabel('voltage');
                    if i == 1
                        title(sprintf('subject: %s electrode: %s session: %d', config.subject_label, electrode_label, session_index));
                    end
                    xlim([a_s, b_s_full]);
                    if config.plot_events
                        z = tags{session_index} >= a_ticks & tags{session_index} <= b_ticks;
                        if any(z)
                            event_labels = config.stimuli{session_index}(z);
                            event_ticks = tags{session_index}(z);
                            event_s = (event_ticks - 1) * interval_s;
                            xline(event_s, '--', event_labels);
                        end
                    end
                    cur = b_ticks;
                end
                linkaxes(axes, 'y');
                fig_path = fullfile(fig_dir, sprintf("sub-%s_sess-%d_elec-%s_label-ts_page-%03d.pdf", config.subject_label, session_index, electrode_label, page));
                print(fig_path, '-dpdf');
            end
        end
    end
end
