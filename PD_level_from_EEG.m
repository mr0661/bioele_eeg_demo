function level = PD_level_from_EEG(EEG, weights, sampleRate)
if(sampleRate ~= 500)
	warning("Sampling rate is not 500, this is not tested, but might work :) ");
end
if(size(EEG,1) ~= length(weights))
	error("Weights should match!");
end
l = [];
for i = 1:size(EEG, 1)
	l(1) = single_channel(EEG(i, 1:round(end/2)), sampleRate);
end
level = sum(l.*weights);
end

function level = single_channel(EEG_channel, sampleRate)
% this is interp1 but I really don't want to bother 
% reading the definitions, so I made my own 
min_freq = sampleRate / length(EEG_channel);
max_freq = sampleRate;
a = min_freq;
b = max_freq;
m = 1;
n = round(length(EEG_channel))/2;
intr = @(x, m, n, a, b) x*(n-m)/(b-a) + m - a*(n-m)/(b-a);

% calculate frequencies
pd_fft = fft(EEG_channel);
% Strength of the signal (ie power)
pd_pow = abs(pd_fft);

% Pretty arbitrary chosen frequency ranges
low=5;
hi=10;
% lets get closest indexes for those frequencies 
low_idx = round(intr(low, m, n, a, b));
hi_idx = round(intr(hi, m, n, a, b));

% Lets get mean power in those ranges
level = sum(pd_pow(low_idx:hi_idx))/(hi_idx - low_idx + 1);
%h = figure();
%plot(pd_pow(low_idx:hi_idx));
%waitfor(h);
end
