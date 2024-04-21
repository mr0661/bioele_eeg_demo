%% Loading trials from PD subject and matched control subject

PD_trial    = load('data/PD_REST/801_1_PD_REST.mat');
Cntrl_trial = load('data/PD_REST/894_1_PD_REST.mat');

%% Important Parameters

Sampling_Rate       = PD_trial.EEG.srate
Channel_Locations   = PD_trial.EEG.chanlocs

%% Accessing the EEG data and X,Y,Z accelerometer Data

PD_EEG = PD_trial.EEG.data(1:63,:);     % EEG Data from 63 electrodes
PD_acc = PD_trial.EEG.data(65:67,:);    % X,Y,Z accelerometer data

Cntrl_EEG = Cntrl_trial.EEG.data(1:63,:);     % EEG Data from 63 electrodes
Cntrl_acc = Cntrl_trial.EEG.data(65:67,:);    % X,Y,Z accelerometer data


