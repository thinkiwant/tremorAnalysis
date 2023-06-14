function [pcohr,f,limitC] = PCoher(sig1, sig2, sig3, varargin)
% calculate the coherence of signals sig1 and sig2. 

l1 = length(sig1);
l2 = length(sig2);
l3 = length(sig3);
L = min([l1,l2,l3]);

fs = 2000;
segT = 2^13;    %the length of a segment
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
segL = floor(L/segT); %the number of segment

sig1Reshape = reshape(sig1(1:segL*segT),[segT,segL]);
sig2Reshape = reshape(sig2(1:segL*segT),[segT,segL]);
sig3Reshape = reshape(sig3(1:segL*segT),[segT,segL]);

fft1 = fft(sig1Reshape);
fft2 = fft(sig2Reshape);
fft3 = fft(sig3Reshape);
fft1 = fft1(1:segT/2+1,:);
fft2 = fft2(1:segT/2+1,:);
fft3 = fft3(1:segT/2+1,:);
fft1(2:end-1) = fft1(2:end-1)*2;
fft2(2:end-1) = fft2(2:end-1)*2;
fft3(2:end-1) = fft3(2:end-1)*2;
fft11 = fft1.*conj(fft1);
fft22 = fft2.*conj(fft2);
fft33 = fft3.*conj(fft3);
fft12 = fft1.*conj(fft2);
fft23 = fft2.*conj(fft3);
fft31 = fft3.*conj(fft1);

asptr1 = sum(fft11,2);
asptr2 = sum(fft22,2);
asptr3 = sum(fft33,2);
xsptr12 = sum(fft12,2);
xsptr23 = sum(fft23,2);
xsptr31 =  sum(fft31,2);

spt11_3 = asptr1 - (xsptr31.*conj(xsptr31))./asptr3;
spt22_3 = asptr2 - (xsptr23.*conj(xsptr23))./asptr3; 
spt12_3 = xsptr12 - (conj(xsptr31).*conj(xsptr23))./asptr3; 

pcohr = spt12_3.*conj(spt12_3)./(spt11_3.*spt22_3);

f = fs*[0:segT/2]/segT;
confLvl = 1-(1-alpha)^(1/(segL-2));
limitC = confLvl;
if nargout == 0
    plot(f,pcohr,'LineWidth',1)
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