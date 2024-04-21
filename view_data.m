close all;
if ~exist("test_case")
	test_case = 'PD';
end

%% Loading trials from PD subject and matched control subject
if strcmp(test_case, 'PD')
	% PD and tremors are present
	trial = load('data/PD_REST/801_1_PD_REST.mat');
elseif strcmp(test_case, 'CONTROL')
	% Control set
	trial = load('data/PD_REST/894_1_PD_REST.mat');
else
	error('unknown test case');
end
sampleRate = trial.EEG.srate;

%% Accessing the EEG data 
EEG = trial.EEG.data(1:63,:);     % EEG Data from 63 electrodes
acc_xyz = trial.EEG.data(65:67,:);    % X,Y,Z accelerometer data

%% and X,Y,Z accelerometer Data
acc = acc_xyz(1, :); % we assume that we can use only X, as good enough representation

%% Time matching the data
time = (0:(length(acc)-1))/sampleRate;

%% We are not going to give any special weight to any 
%% sensor, it would be beneficial to end results to do so
%% but we do not have data yeat to support adjusting the weights
w = ones(1, 63);

%% Print all eeg and accelerometer data
figure;
hold on;
yyaxis left;
p1 = plot(time, EEG);
yyaxis right;
p2 = plot(time, acc_xyz);
title("EEG and accelerometer");
legend([p1(1), p2(1)], "EEG", "acc");
hold off;

%% Print one nice eeg channel and acc x
figure;
hold on;
yyaxis left;
p3 = plot(time, EEG(5, :));
yyaxis right;
p4 = plot(time, acc);
title("Single EEG and accelerometer channel");
legend([p3(1), p4(1)], "EEG", "acc");
hold off;

%% Lets process data in segments:
segment_length = 1000;
segment_start = 1;
segment_end = segment_start + segment_length;
level = [];
tremor = [];
acc_metric = [];
segment_time = [];
while (segment_end < length(acc))
	segment = segment_start:(segment_end - 1);
	level(end + 1) = PD_level_from_EEG(EEG(:, segment), w, sampleRate);
	tremor(end + 1) = sum(abs(fft(acc(segment))));
	acc_metric(end + 1) = sum(acc(segment));
	segment_time(end + 1) = time(segment_start);
	segment_start = segment_start + segment_length;
	segment_end = segment_end + segment_length;
end
figure;
yyaxis left;
plot(segment_time, level);
yyaxis right;
hold on;
plot(segment_time, acc_metric);
plot(segment_time, tremor);
legend("Tremor level from EEG", "Accelemeter", "Tremor power");
title("Tremor detection");
hold off;

%% Lets quantify each segment to be either stable (0) or tremor(1) 
% This chooses value assuming we have both tremor and stable data
ground_truth = imbinarize(normalize(tremor, 'range'), graythresh(normalize(tremor, 'range')));

%% Lets quantify each segment from the level
% we are lacking good objective way to do this so we do arbitrary thresholding.
% This chooses value assuming we have both tremor and stable data present
from_eeg = imbinarize(normalize(level, 'range'), graythresh(normalize(level, 'range')));


%% Lets see how well we did:
both = ground_truth * 10 + from_eeg;

correct_positives = sum(both == 11)
correct_negatives = sum(both == 0)
false_negatives = sum(both == 10)
false_positives = sum(both == 1)
