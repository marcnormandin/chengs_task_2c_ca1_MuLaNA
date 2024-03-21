close all
clear all
clc

nSamples = 1000;

% Generate random samples in [0, 2pi)
sample = ml_stats_gen_uniform_samples(nSamples, 0, 2*pi);

% Generate a uniform peak around 90 degrees
peak = ml_stats_gen_uniform_samples(200, pi/2-pi/6, pi/2+pi/6);

% Make a set of samples that have the peak added to it
sampleWithPeak = cat(2, sample, peak);

figure
% Show the circular data with not peak
subplot(1,2,1);
histogram(sample)
[HRT, HRTpvalue] = ml_stats_hermansrassonp(sample);
title(sprintf('Hermans-Rasson (crit, p-value) = (%0.2f, %0.2f)', HRT, HRTpvalue));

% Show the circular data with the peak
subplot(1,2,2);
histogram(sampleWithPeak);
[HRT, HRTpvalue] = ml_stats_hermansrassonp(sampleWithPeak);
title(sprintf('Hermans-Rasson (crit, p-value) = (%0.2f, %0.2f)', HRT, HRTpvalue));
