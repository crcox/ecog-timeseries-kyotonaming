data_root = 'R:\crcox\ECoG\KyotoNaming\data\raw';
data_dir = fullfile(data_root, "Pt01");
data_path = fullfile(data_dir, "namingERP_Pt01.mat");
ECOG = load(data_path);

load("data\electrodes.mat", "ELECTRODE");

% Session will be truncated to include a baseline window before the first
% trial and terminate at the end of the last trial.
Hz = 1 / ECOG.namingERP_data_PtYK_Pt01.DIM(1).interval;
baseline_ms = 200;
trial_ms = 5000;
boxcar_ms = 10;
baseline_ticks = Hz * (baseline_ms / 1000);
trial_ticks = Hz * (trial_ms / 1000);
boxcar_ticks = Hz * (boxcar_ms / 1000);

%% Pt01
session_ranges_0 = [
    ECOG.tag_ss01_all(1) - baseline_ticks, ECOG.tag_ss01_all(end) - trial_ticks
    ECOG.tag_ss02_all(1) - baseline_ticks, ECOG.tag_ss02_all(end) - trial_ticks
    ECOG.tag_ss03_all(1) - baseline_ticks, ECOG.tag_ss03_all(end) - trial_ticks
    ECOG.tag_ss04_all(1) - baseline_ticks, ECOG.tag_ss04_all(end) - trial_ticks
];
n_sessions = size(session_ranges_0, 1);


% Small differences in session length may appear (+/- a few ms).
% Sessions will be further truncated so that session length is a multiple
% of boxcar window (for downsampling).
session_ticks_0 = diff(session_ranges_0');
session_ticks_trunc = mod(session_ticks_0, boxcar_ticks);
session_ranges(:, 2) = session_ranges_0(:, 2) - session_ticks_trunc(:);
session_ticks = diff(session_ranges');
session_ticks = session_ticks(1);

sessions_ix = zeros(sum(session_ticks), 1);
cur = 0;
for i = 1:size(session_ranges, 1)
    a = cur + 1;
    b = cur + session_ticks;
    tmp = session_ranges(i, 1):(session_ranges(i, 2) - 1);
    sessions_ix(a:b) = tmp;
    cur = b;
end

n_electrodes = size(ECOG.namingERP_data_PtYK_Pt01.DATA, 2);
X = permute(squeeze(...
    mean(...
        reshape(...
            ECOG.namingERP_data_PtYK_Pt01.DATA(sessions_ix, :), ...
            [boxcar_ticks, session_ticks / boxcar_ticks, n_sessions, n_electrodes]),...
        1)), [1, 3, 2]);

interval = ((Hz / boxcar_ticks) / 1000);
electrode = string(ELECTRODE{1}(1, :));
window_s = 30; % seconds
window_ticks = window_s / interval;

fig = figure();
set(fig, 'Units', 'inches', 'Position', [0, 0, 8, 11.5], 'PaperUnits', 'inches', 'PaperSize', [8, 11.5]);
axes = gobjects(4, 1);
cur = 0;
electrode_label = "A01";
electrode_index = 1;
subject_label = "Pt01";
subject_index = 1;
session_index = 1;
session_ticks = size(X, 1);
fig_dir = "figures/Pt01/A01/";
lastpage_ticks = mod(session_ticks, window_ticks * 4);
pages = ((session_ticks - lastpage_ticks) / (window_ticks * 4)) + 1;
for page = 1:pages
    for i = 1:4
        a_ticks = cur + 1;
        if a_ticks > session_ticks
            break
        end
        b_ticks = cur + window_ticks;
        if b_ticks > session_ticks
            b_ticks = session_ticks;
        end
        a_s = (a_ticks - 1) * interval;
        b_s = (b_ticks - 1) * interval;
        b_s_full = ((cur + window_ticks) - 1) * interval;
        axes(i) = subplot(4, 1, i, "replace");
        seconds = linspace(a_s, b_s, (b_ticks - a_ticks) + 1);
        ix = a_ticks:b_ticks;
        plot(seconds, X(ix, 1, 1));
        if i == 4 || (b_ticks == session_ticks)
            xlabel('seconds from session onset');
        end
        ylabel('voltage');
        if i == 1
            title(sprintf('subject: %s electrode: %s session: %d', "Pt01", electrode, 1));
        end
        xlim([a_s, b_s_full]);
        cur = b_ticks;
    end
    linkaxes(axes, 'y');
    fig_path = fullfile(fig_dir, sprintf("sub-%s_sess-%d_elec-%s_label-ts_page-%03d.pdf", subject_label, session_index, electrode_label, page));
    print(fig_path, '-dpdf');
end
% set(fig, "PaperUnits", "inches");
% set(fig, "PaperSize", [11, 8.5]);
% set(fig, "PaperType", "A1");


E = struct();
size(ECOG.namingERP_data_PtYK_Pt01.DATA)
