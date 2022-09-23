addpath("m")
data_root = 'data/raw';
load("data/electrodes.mat", "ELECTRODE");
stim_order = readtable("data\picture_namingERP_order.csv");
stim_key = readtable("data\picture_namingERP_key.csv");
stim_key.Stimulus = strtrim(string(stim_key.Stimulus));
stimuli_tbl = join(stim_order, stim_key);
stimuli = {
    stimuli_tbl.Stimulus(stimuli_tbl.Session == 1)
    stimuli_tbl.Stimulus(stimuli_tbl.Session == 2)
    stimuli_tbl.Stimulus(stimuli_tbl.Session == 3)
    stimuli_tbl.Stimulus(stimuli_tbl.Session == 4)
};

config = struct(...
    'plots_per_page', 4, ...
    'plot_window_s', 30, ... seconds
    'plot_events', true, ...
    'stimuli', {stimuli}, ...
    'baseline_ms', 2000, ... milliseconds
    'trial_ms', 5000, ... milliseconds
    'boxcar_ms', 10, ... milliseconds
    'subject_label', "" ...
);

% Sessions will be truncated to include a baseline window before the first
% trial and terminate at the end of the last trial.

%% Pt01
subject_index = 1;
config.subject_label = sprintf('Pt%02d', subject_index);

data_dir = fullfile(data_root, config.subject_label);
data_path = fullfile(data_dir, "namingERP_Pt01.mat");
ECOG = load(data_path);

tags = {
    ECOG.tag_ss01_all
    ECOG.tag_ss02_all
    ECOG.tag_ss03_all
    ECOG.tag_ss04_all
};

vt_electrode_labels = strtrim(string(ELECTRODE{subject_index}));
plot_all_electrodes_ts(ECOG.namingERP_data_PtYK_Pt01, tags, vt_electrode_labels, config);
