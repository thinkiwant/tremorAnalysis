function [Temp128, Amp, DuraT] = STAmuWH128(FireT, EMG128, WinPrior, WinPost, dt, PlotFig, Wsync,NumCh)
% STAmu estimte the 4 templates from the 4 channels using firing time of
% Delsys output. remove shorter than 16.7ms ISI firings.
% Input:
% FireT (N X 1): firing data of 1 MU from Delsys
% EMG4 (N X m): m channels of EMG, for delsys, m =4
% WinPrior (1x1): window length in second prior to the time of firing 
% WinPost (1x1): window length in second post the time of firing 
%dt (1x1): sampling interval
% PlotFig: logic number: 1 plot templates, 0 no plots
% Wsync (K X 1): number of MU has synchronized firing events. K: # of firing
% Output:
% Temp4 (N x 4): estimated templates of m channels.
% Amp (4 x 1): peak to peak amplitude from each channel
% 10/04/11, Xiaogang Hu, SMU@RIC

% 10/05/11, remove minimum # of time of firing by calculating adjacent short ISIs, plot templates
% 10/06/11, calculate peak to peak of templates.
% 12/12/11, calculate p-p duration.
% 12/20/11, calculate # of peaks (maxima and minima). call peakdet.m %%% this is disabled now.
% 4/11/12, take weighted average based on synchronization
% 11/22/12, Hanning window is applied to the templates to get rid of the boundary effect

if length(FireT) ~= length(EMG128)
    error('firing time data should have the same length as the EMG data!!');
%elseif WinPrior <= 0
    %error('Window length prior to firing has to be larger than 0!!')
%elseif WinPost < 0
    %error('Window length post firing has to be larger than or equal to 0!!')
end

MinISI = 1/60; % minimum ISI=16.7 ms. or MFR = 60 Hz.
IndFire = find(FireT); % firing time should be denoted by 1 in the data.
% check if there is actual firing event.
if isempty(IndFire)
    % returns zeros on the templates and p-p amplitude.
    Temp128 = zeros(1 + (abs(WinPrior) + abs(WinPost))  / dt, NumCh); Amp = zeros(NumCh,1);
    DuraT = zeros(NumCh,1); PeakN = zeros(NumCh,1);
    return;
end

%% check constraints: FR < 60 Hz
% the firings prior and post to the current firing has to be larger than 20ms. if not, ignore the firing that causes the short interval
IndLowISI =1;
while (~isempty(IndLowISI))
    ISI = diff(IndFire) * dt;
    IndLowISI = find(ISI < MinISI); % index of lower ISI than minmum ISI threshold.
    IndAdjacent = find(diff(IndLowISI) == 1); % find if there are two adjacent ISI is < MinISI
    if isempty(IndLowISI)
        % constraint satisfied, do nothing
    else
        if isempty(IndAdjacent) % if no adjacent short ISI
            IndFire(IndLowISI + 1) =[]; % remove the later firing instance that causes shorter ISI
            Wsync(IndLowISI + 1) =[]; % remove the sync weight of that firing event.  @@ added 04/11/12
        else
             IndFire(IndLowISI(IndAdjacent + 1)) = []; % remove the middle firing instance if there are 2 adjacent short ISI.
             Wsync(IndLowISI(IndAdjacent + 1)) =[]; % remove the sync weight of that firing event.  @@ added 04/11/12
        end
        IndLowISI = find(diff(IndFire) * dt < MinISI); % index of lower ISI than minmum ISI threshold.
    end
end

%% do STA
IndPrior = floor(abs(WinPrior) / dt); % points prior to time of firing
IndPost = floor(abs(WinPost) / dt); % points post time of firing
Temp128 = zeros(IndPrior + IndPost + 1, size(EMG128, 2));
%for i = 1:size(EMG4, 2) % # of channels
    for j = 1:length(IndFire) % # of firing instance
        try
            Temp128 = Temp128 + EMG128((IndFire(j) - IndPrior) : (IndFire(j) + IndPost), :) * Wsync(j); %@@@@ add weight wi 04/11/12
        catch
            continue % 
        end
    end
%end
%Temp4 = Temp4 ./ length(IndFire); % 4 templates time series  
Temp128 = Temp128 ./ sum(Wsync);  %@@@@@ devided by the sum of weight wi 04/11/12
[tempa,~] = size(Temp128);
HannW = hann(tempa);
% HannW = hann(length(Temp128));
HannWTotal = HannW*ones(1,NumCh);
Temp128 = Temp128 .* HannWTotal; % Apply the hanning window to smooth the edge.

Rang1 = minmax((Temp128)');  % the peak to peak range of each channel.
Amp = diff(Rang1')';% the peak to peak amp of each channel.
%% get P-P duration
DuraT = zeros(NumCh,1);
for k = 1:NumCh
    DuraT(k) = abs(find(Temp128(25:75,k)==max(Temp128(25:75,k)), 1, 'first') - find(Temp128(25:75,k)==min(Temp128(25:75,k)), 1, 'first')) * dt;
end
%% get # of peaks

%PeakN = zeros(4,1);
if 0
for ch = 1:NumCh
    %maxtab=[]; mintab=[];
    %[maxtab, mintab] = peakdet(Temp4(20:end,ch), 0.1); 
    if abs(Amp(ch)) ==0 
        Amp(ch) = 0.000001;
    end
    [maxtab, mintab] = peakdet(Temp128(20:end,ch), 0.06*abs(Amp(ch))); % threshold for peak detection is 0.1* P-P of the templates
    if isempty(maxtab)
        maxtab = [0,0];
    end
    if isempty(mintab)
        mintab =  [0,0];
    end
    PeakN(ch) = length(maxtab(:,1)) + length(mintab(:,1));
end
end
%% plot templates
if PlotFig
    PtP = [min(Rang1(:,1)), max(Rang1(:,2))]; % find the largest P-P
    %figure; hold on;
    for m = 1:size(EMG128, 2)
        subplot(2,2,m); hold on
        if WinPrior < 0
           plot(WinPrior:dt:WinPost, Temp128(:,m), 'LineWidth',1.5)
        else
           plot((-1 * WinPrior:dt:WinPost) + WinPrior/2, Temp128(:,m), 'LineWidth',1.5)
        end
        grid on; ylim(PtP * 1.2);
    end
end

