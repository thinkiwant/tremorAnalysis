function [cohr,f,limitC] = Coher(sig1, sig2, varargin)
% calculate the coherence of signals sig1 and sig2.

l1 = length(sig1);
l2 = length(sig2);
L = min(l1,l2);

fs = 2000;
segT = 2^14;    %length for each segment
%segT = floor(L/100);
alpha = 0.95;
for i = 1:2:length(varargin)
    switch varargin{i}
        case 'fs'
            fs = varargin{i+1};
    end
end

%L = length(sig1);
% if length(sig2)~=L
%     error("un matched signal length");
% end
segL = floor(L/segT);   %the number of segments for each signal

sig1Reshape = reshape(sig1(1:segL*segT),[segT,segL]);
sig2Reshape = reshape(sig2(1:segL*segT),[segT,segL]);

fft1 = fft(sig1Reshape);
fft2 = fft(sig2Reshape);
fft1 = fft1(1:segT/2+1,:);
fft2 = fft2(1:segT/2+1,:);
fft1(2:end-1) = fft1(2:end-1)*2;
fft2(2:end-1) = fft2(2:end-1)*2;
fft11 = fft1.*conj(fft1);
fft22 = fft2.*conj(fft2);
fft12 = fft1.*conj(fft2);

asptr1 = mean(fft11,2);
asptr2 = mean(fft22,2);
xsptr = mean(fft12,2);

cohr = xsptr.*conj(xsptr)./(asptr1.*asptr2);
f = fs*[0:segT/2]'/segT;
confLvl = 1-(1-alpha)^(1/(segL-1));
limitC = confLvl;
if nargout == 0
    plot(f,cohr,'LineWidth',1)
    hold on 
    plot(f,ones(size(f))*confLvl,'r--','LineWidth',1)
    hold off
    legend('Coherence',strcat(num2str(alpha*100),'% Confidence Level'))
    formatSpec = '%.2f';
    title(strcat("Coherence (L=",num2str(segL),", Freq Res=",num2str(fs/segT, formatSpec),"Hz)"));
    xlabel('Frequency (Hz)')
    ax = gca;
    set(ax,'FontSize',16);
    axis([0, 50,0,1])
end
end