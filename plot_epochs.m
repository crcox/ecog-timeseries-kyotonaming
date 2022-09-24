addpath("m")
data_root = 'R:\crcox\ECoG\KyotoNaming\data\raw';
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
    'stimuli', {stimuli}, ...
    'baseline_ms', 200, ... milliseconds
    'trial_ms', 2000, ... milliseconds
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
plot_all_electrodes_epoch(ECOG.namingERP_data_PtYK_Pt01, tags, vt_electrode_labels, config);


%% Pt02
subject_index = 2;
config.subject_label = sprintf('Pt%02d', subject_index);

data_dir = fullfile(data_root, config.subject_label);
data_path = fullfile(data_dir, "namingERP_Pt02.mat");
ECOG = load(data_path);

tags = {
    ECOG.Tag_ss01_all
    ECOG.Tag_ss02_all
    ECOG.Tag_ss03_all
    ECOG.Tag_ss04_all
};

vt_electrode_labels = strtrim(string(ELECTRODE{subject_index}));
plot_all_electrodes_epoch(ECOG.namingERP_data_Pt02, tags, vt_electrode_labels, config);


%% Pt03
subject_index = 3;
config.subject_label = sprintf('Pt%02d', subject_index);

data_dir = fullfile(data_root, config.subject_label);
data_path = fullfile(data_dir, "namingERP_Pt03.mat");
ECOG = load(data_path);

tags = {
    ECOG.Tag_ss01_all
    ECOG.Tag_ss02_all
    ECOG.Tag_ss03_all
    ECOG.Tag_ss04_all
};

vt_electrode_labels = strtrim(string(ELECTRODE{subject_index}));
plot_all_electrodes_epoch(ECOG.namingERP_data_Pt03, tags, vt_electrode_labels, config);

%% Pt04
subject_index = 4;
config.subject_label = sprintf('Pt%02d', subject_index);

data_dir = fullfile(data_root, config.subject_label);
data_path = fullfile(data_dir, "Pt04_namingERP_2017.mat");
ECOG = load(data_path, 'Pt04_namingERP_anony_SS01_02', 'Pt04_namingERP_anony_SS03_04', 'tag_ss01', 'tag_ss02', 'tag_ss03', 'tag_ss04');

tags = {
    ECOG.tag_ss01
    ECOG.tag_ss02
    ECOG.tag_ss03 + size(ECOG.Pt04_namingERP_anony_SS01_02.DATA, 1);
    ECOG.tag_ss04 + size(ECOG.Pt04_namingERP_anony_SS01_02.DATA, 1);
};

ECOG.Pt04_namingERP = struct(...
    'DATA', [ECOG.Pt04_namingERP_anony_SS01_02.DATA; ECOG.Pt04_namingERP_anony_SS03_04.DATA], ...
    'DIM', ECOG.Pt04_namingERP_anony_SS01_02.DIM);

vt_electrode_labels = strtrim(string(ELECTRODE{subject_index}));
plot_all_electrodes_epoch(ECOG.Pt04_namingERP, tags, vt_electrode_labels, config);


%% Pt05
subject_index = 5;
config.subject_label = sprintf('Pt%02d', subject_index);

data_dir = fullfile(data_root, config.subject_label);
data_path = fullfile(data_dir, "namingERP_Pt05.mat");
ECOG = load(data_path);

tags = {
    ECOG.tag_ss01
    ECOG.tag_ss02
    ECOG.tag_ss03
    ECOG.tag_ss04
};

vt_electrode_labels = strtrim(string(ELECTRODE{subject_index}));
plot_all_electrodes_epoch(ECOG.namingERP_data_Pt05, tags, vt_electrode_labels, config);


%% Pt06
subject_index = 6;
config.subject_label = sprintf('Pt%02d', subject_index);

data_dir = fullfile(data_root, config.subject_label);
data_path = fullfile(data_dir, "Pt06_namingERP_anony.mat");
ECOG = load(data_path);

tags = {
    ECOG.tag01_all
    ECOG.tag02_all
    ECOG.tag03_all
    ECOG.tag04_all
};

vt_electrode_labels = strtrim(string(ELECTRODE{subject_index}));
plot_all_electrodes_epoch(ECOG.Pt06_namingERP_anony, tags, vt_electrode_labels, config);


%% Pt07
subject_index = 7;
config.subject_label = sprintf('Pt%02d', subject_index);

data_dir = fullfile(data_root, config.subject_label);
data_path = fullfile(data_dir, "namingERP_Pt07.mat");
ECOG = load(data_path);

tags = {
    ECOG.Tag_ss01
    ECOG.Tag_ss02
    ECOG.Tag_ss03 + size(ECOG.namingERPdataPt07.DATA, 1);
    ECOG.Tag_ss04 + size(ECOG.namingERPdataPt07.DATA, 1);
};

ECOG.namingERPdataPt07.DATA = [ECOG.namingERPdataPt07.DATA; ECOG.namingERPdataPt07_ss0304.DATA];

vt_electrode_labels = strtrim(string(ELECTRODE{subject_index}));
plot_all_electrodes_epoch(ECOG.namingERPdataPt07, tags, vt_electrode_labels, config);


%% Pt08
subject_index = 8;
config.subject_label = sprintf('Pt%02d', subject_index);

data_dir = fullfile(data_root, config.subject_label);
data_path = fullfile(data_dir, "namingERP_Pt08.mat");
ECOG = load(data_path);

tags = {
    ECOG.tag_01
    ECOG.tag_02
    ECOG.tag_03
    ECOG.tag_04
};

vt_electrode_labels = strtrim(string(ELECTRODE{subject_index}));
plot_all_electrodes_epoch(ECOG.namingERPdataPt08, tags, vt_electrode_labels, config);


%% Pt09
subject_index = 9;
config.subject_label = sprintf('Pt%02d', subject_index);

data_dir = fullfile(data_root, config.subject_label);
data_path = fullfile(data_dir, "namingERP_Pt09.mat");
ECOG = load(data_path);

tags = {
    ECOG.tag01
    ECOG.tag02
    ECOG.tag03
    ECOG.tag04
};

vt_electrode_labels = strtrim(string(ELECTRODE{subject_index}));
plot_all_electrodes_epoch(ECOG.namingERPdataPt09, tags, vt_electrode_labels, config);


%% Pt10
subject_index = 10;
config.subject_label = sprintf('Pt%02d', subject_index);

data_dir = fullfile(data_root, config.subject_label);
data_path = fullfile(data_dir, "namingERP_Pt10.mat");
ECOG = load(data_path);

tags = {
    ECOG.tagall01
    ECOG.tagall02
    ECOG.tagall03
    ECOG.tagall04
};

vt_electrode_labels = strtrim(string(ELECTRODE{subject_index}));
plot_all_electrodes_epoch(ECOG.namingERPdataPt10, tags, vt_electrode_labels, config);
