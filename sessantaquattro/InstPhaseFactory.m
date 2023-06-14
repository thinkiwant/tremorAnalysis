function InstPhase = InstPhaseFactory
InstPhase.gather = @ gatherST;
InstPhase.tremor_pass_filter = @ tremor_pass_filter;
InstPhase.Sig2Phase = @ Sig2Phase;
InstPhase.getTremorPhaseDiff = @ getTremorPhaseDiff;
InstPhase.getVoluntaryPhaseDiff = @ getVoluntaryPhaseDiff;

end

function [ST_Pooled] = gatherST(ST, mode)

if(nargin == 2)
    mode_in = mode;
else
    mode_in = 'CST';
end

if(mode_in == 'CST')
    ST_Pooled = PoolCST(ST);
else
    ST_Pooled = reshape(ST, [], 1);
end
end

function [flx_st_filtered, ext_st_filtered, imu_filtered,  tremor_freq] = tremor_pass_filter(imu, flx_st, ext_st)
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

flx_st_filtered = band_pass_filtered(flx_st, tremor_freq);
ext_st_filtered = band_pass_filtered(ext_st, tremor_freq);
imu_filtered = band_pass_filtered(imu, tremor_freq);
end

function [sig_filtered] = band_pass_filtered(sig, pass_freq, bandwidth)
fs = 2000;
if(nargin < 3)
    bandwidth = 1;
end
[b, a] = butter(2, [[-0.5, 0.5]*bandwidth+pass_freq] / (fs/2), 'bandpass');
sig_filtered = filtfilt(b, a, sig);
end

function [phase] = Sig2Phase(sig)

hlbt = hilbert(sig);

phase = unwrap(rad2deg(angle(hlbt)));
end

function [phase_diff, st1_f, st2_f] = getTremorPhaseDiff(st1, st2, imu)

st1_g = gatherST(st1);
st2_g = gatherST(st2);

[st1_f, st2_f, ~, ~] = tremor_pass_filter(imu, st1_g, st2_g);
phase1 = Sig2Phase(st1_f);
phase2 = Sig2Phase(st2_f);

phase_diff = wrapTo360(phase1 - phase2);
end

function [phase_diff, st1_f, st2_f] = getVoluntaryPhaseDiff(st1, st2)

st1_g = gatherST(st1);
st2_g = gatherST(st2);

st1_f = band_pass_filtered(st1_g, 2, 2);
st2_f = band_pass_filtered(st2_g, 2, 2);
phase1 = Sig2Phase(st1_f);
phase2 = Sig2Phase(st2_f);

phase_diff = wrapTo360(phase1 - phase2);
end
