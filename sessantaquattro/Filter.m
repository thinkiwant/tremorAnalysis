function EMG_Filtered = Filter(EMG,fs,filterType,freArgs)
% Intergret some common useful filters in one function
% freArg 包含滤波器参数
% BandStop, freArg : stop frequency, Fre
% BandPass, freArg, two parameters, [flow, fhigh];
% 零相位滤波
switch filterType
    case "BandStop"
        Fre = freArgs;
        EMG_Filtered = Filter_BandStop(Fre,EMG,fs);
    case "BandPass"
        flow = freArgs(1);
        fhigh = freArgs(2);
        EMG_Filtered = Filter_BandPass(flow,fhigh,EMG,fs);
    case "LowPass1"
        % chebyshev filter
        Flowpass = freArgs(1);
        Flowstop = freArgs(2);
        EMG_Filtered = Filter_LowPass(Flowpass, Flowstop, EMG,fs);
    case "LowPass2"
        % butterworth filter
        EMG_Filtered = Filter_LowPass_WF( freArgs,EMG, fs);
    case "HighPass"
        Fre = freArgs;
        EMG_Filtered = Filter_HighPass(Fre,EMG,fs);
end
end
%% Function  Filter_BandStop
%
% Butterworth Bandstop filter designed using FDESIGN.BANDSTOP.
% All frequency values are in Hz.
% Cut-off frequency of Band-Stop filters which eliminate
% powerline noise or other noises and its harmonics

function EMG_BS = Filter_BandStop(frequency,EMG,fs)

Fs = fs;  % Sampling Frequency

Fpass1 = frequency - 1;          % First Passband Frequency
Fstop1 = frequency - 0.5;          % First Stopband Frequency
Fstop2 = frequency + 0.5;          % Second Stopband Frequency
Fpass2 = frequency + 1;          % Second Passband Frequency
Apass1 = 1;           % First Passband Ripple (dB)
Astop  = 30;          % Stopband Attenuation (dB)
Apass2 = 1;           % Second Passband Ripple (dB)
match  = 'stopband';  % Band to match exactly

% Construct an FDESIGN object and call its BUTTER method.
h  = fdesign.bandstop(Fpass1, Fstop1, Fstop2, Fpass2, Apass1, Astop, ...
                      Apass2, Fs);
Hd = design(h, 'butter', 'MatchExactly', match);

SOS             = Hd.sosMatrix;
G               = Hd.ScaleValues;
EMG_BS  = filtfilt(SOS, G, EMG);

end

%% Function  Filter_BandPass
%
% BANDPASS Returns a discrete-time filter object.
% Chebyshev Type I Bandpass filter designed using FDESIGN.BANDPASS.
% All frequency values are in Hz.
% Filter of Band Pass from 20Hz to 390Hz which extract EMG 
% and eliminate motion artifact
%
function EMG_BP= Filter_BandPass(flow,fhigh,EMG,fs)

% Fs = fs;  % Sampling Frequency
% 
% Fstop1 = flow-15;          % First Stopband Frequency
% Fpass1 = flow;          % First Passband Frequency
% Fpass2 = fhigh;         % Second Passband Frequency
% Fstop2 = fhigh+50;         % Second Stopband Frequency
% Astop1 = 30;     % First Stopband Attenuation (dB)
% Apass  = 1;     % Passband Ripple (dB)
% Astop2 = 30;     % Second Stopband Attenuation (dB)
% match  = 'passband';  % Band to match exactly
% 
% % Construct an FDESIGN object and call its CHEBY1 method.
% h  = fdesign.bandpass(Fstop1, Fpass1, Fpass2, Fstop2, Astop1, Apass, ...
%                       Astop2, Fs);
% Hd = design(h, 'butter', 'MatchExactly', match);
% SOS             = Hd.sosMatrix;
% G               = Hd.ScaleValues;
% EMG_BPma        = filtfilt(SOS, G, EMG);

BP_MA                     =               [flow fhigh];
Wn_BP_MA                                =   BP_MA/(fs/2);
[num_BP_MA,den_BP_MA]     =   butter(4,Wn_BP_MA);
EMG_BP=filtfilt(num_BP_MA,den_BP_MA,EMG);

end

%% Function Filter_LowPass
%
% Cut-off frequency of Low-Pass filter which eliminate
% double tremor frequency component of EMG for Phase
% Detection

% butterworth filter, could add other filters
function EMG_LPpd = Filter_LowPass( Fpass, Fstop, EMG,fs )

% LP_PD           =   [6.5   7.5   0.1   20];        % Hz
LP_PD            = [Fpass, Fstop, 0.1, 20];
                % Column 1 through 4:
                % Fpass, Fstop (Hz), Apass1, Astop (dB)
                % Cut-off frequency of Low-Pass filter which eliminate
                % double tremor frequency component of EMG for Phase
                % Detection

                
% Design low pass EMG Phase Detection filter
h                   =	fdesign.lowpass('fp,fst,ap,ast', LP_PD(1), LP_PD(2), LP_PD(3), LP_PD(4), fs);
Output.Hd_PD        =	design(h, 'cheby1', 'MatchExactly', 'passband', 'SystemObject', true);
Output.SOS_PD       =   Output.Hd_PD.SOSMatrix;
Output.G_PD         =   Output.Hd_PD.ScaleValues;

% Implement IIR filter by coef 'Output.SOS_PD', 'Output.G_PD'
EMG_LPpd	=   filtfilt(Output.SOS_PD,Output.G_PD,EMG);                

end

%% Function Filter_LowPass_WF
%
% Cut-off frequency of Low Pass filter which extract 
% Low-Frequency Waveform (Signiture pattern of EMG)

function EMG_LPwf = Filter_LowPass_WF( freArgs,EMG, fs)

if length(freArgs) == 2
    
    % Butterworth Lowpass filter designed using FDESIGN.LOWPASS.
    % All frequency values are in Hz.
    Fs = fs;  % Sampling Frequency
    
    Fpass = freArgs(1);          % Passband Frequency   % frequency lowpass 
    Fstop = freArgs(2);          % Stopband Frequency   % frequency lowstop 
    Apass = 1;           % Passband Ripple (dB)
    Astop = 60;          % Stopband Attenuation (dB)
    match = 'stopband';  % Band to match exactly
    
    % Construct an FDESIGN object and call its BUTTER method.
    h  = fdesign.lowpass(Fpass, Fstop, Apass, Astop, Fs);
    Hd = design(h, 'butter', 'MatchExactly', match);
    SOS  =   Hd.sosMatrix;
    G    =   Hd.ScaleValues;
    EMG_LPwf  = filtfilt(SOS,G,EMG);
    
elseif length(freArgs) == 1 
    LP_WF                         =   freArgs;         % Hz
    % Cut-off frequency of Low-Pass filter which extract 
    % Low-Frequency Waveform (Signiture pattern of EMG)
    Wn_LP_WF                                =   LP_WF/(fs/2);
    [num_LP_WF,den_LP_WF]                   =   butter(4,Wn_LP_WF,'low');
    EMG_LPwf                      	        =   filtfilt(num_LP_WF,den_LP_WF,EMG);
    
elseif nargin ==2
    error('input number is 3 or 1');
end

end



%% Function Filter_HighPass_DC
%
% Cut-off frequency of High-Pass filter which eliminate  
% direct current(DC) component

function EMG_HPdc = Filter_HighPass(fre, EMG, fs)

HP_DC                                   =   fre;   % 1Hz
Wn_HP_DC                                =   HP_DC/(fs/2);
[num_HP_DC,den_HP_DC]                   =   butter(4,Wn_HP_DC,'high');
EMG_HPdc                      	        =   filtfilt(num_HP_DC,den_HP_DC,EMG);
    
end