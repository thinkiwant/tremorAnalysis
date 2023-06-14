% This mat file is batch code file to calculate phase difference between
% MUST
%% 
load("mu_data.mat");
%Question: Which way to pool must is better?
need_concatenation = false;
% sig1 and sig2 are two MU spike trains from extensor and flexor
if(need_concatenation)
    sig1 = ext_st_flat;
    sig2 = flx_st_flat;
    L = min(length(sig1),length(sig2));
    sig1 = sig1(1:L);
    sig2 = sig2(1:L);
else
    sig1 = ext_cst;
    sig2 = flx_cst;
end
% kinematic signal
imu = rawData(:, 257);
fs = 2000;
L = length(sig1);
t = (0:L-1)/fs;

figure
sp(1) = subplot(3, 1, 1);
plot(t, [sig1, sig2], 'LineWidth', 2);
set(gca, 'FontSize', 16)
axis([0, inf, -1, 2])
ylabel("(Arbitrary Unit)")
title("Motor unit spike trains")
legend({"Extensor", "Flexor"})
[sig1_f, sig2_f, tremor_freq] = tremor_pass_filter(imu, sig1, sig2);

sp(2) = subplot(3, 1, 2);
plot(t, [sig1_f, sig2_f], 'LineWidth', 2);
set(gca, 'FontSize', 16)
legend({"Extensor", "Flexor"})
title(sprintf("MU spike train signal filtered around %.1f Hz (bandwidth 2 Hz)",tremor_freq))
ylabel("(Arbitrary Unit)")

sp(3) = subplot(3, 1, 3);
hold on
h1 = hilbert(sig1_f);
h2 = hilbert(sig2_f);
% Qustion: Is unwrapping necessary?
need_unwrapping = true;
if(~need_unwrapping)
    deg1 = rad2deg(angle(h1));
    deg2 = rad2deg(angle(h2));
else
    deg1 = unwrap(rad2deg(angle(h1)));
    deg2 = unwrap(rad2deg(angle(h2)));
end
deg_diff = deg1 - deg2;
plot(t, [deg1, deg2, deg_diff], 'LineWidth', 2);
legend({"Extensor", "Flexor", "Phase difference"})
title("Instantaneous phase")
ylabel("Phase (degree)")
xlabel("Time (second)")
set(gca, 'FontSize', 16)
fprintf("mean phase difference: %.2f\n", mean(deg_diff))
linkaxes(sp, 'x');

%%
function [flx_st_filtered, ext_st_filtered, tremor_freq] = tremor_pass_filter(imu, flx_st, ext_st)
% This function calculates tremor frequency according to kinematic data,
% and filters motor unit spike trains signals for both Flx and Ext muscles
% with a bandpass filter center at tremor frequency.
fs = 2000;
tremor_upper_freq = 6;
tremor_lower_freq = 3;
L = length(imu);
t = (0:L-1)/fs;
[pxx, f] = pwelch(imu, [], [], [], 2000);
tremor_band_idx = find(f>= tremor_lower_freq & f<= tremor_upper_freq);
[~, tremor_freq_idx] = max(pxx(tremor_band_idx));
tremor_freq = f(tremor_band_idx(tremor_freq_idx));
bandwidth = 2;
[b, a] = butter(1, [[-0.5, 0.5]*bandwidth+tremor_freq] / (fs/2), 'bandpass');
flx_st_filtered = filtfilt(b, a, flx_st);
ext_st_filtered = filtfilt(b, a, ext_st);
end
