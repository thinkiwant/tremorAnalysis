function plotPSDofSP(sp)
%this function plot the psd of each spike train of the matrix sp
%seperatively. In addiction, the CST(cumulative Spike Train) of sp is also
%ploted in a special linestyle.
% sp: K*N matrix, K is the # of time series and N is the # of MUs.

fs = 2048;
L = 2^14;%length of Hamming window
%freq resolution of Hamming window = fs/L=0.125Hz

noverlap = 0;
nfft = 2^16;%length of DTFT


[k,n] = size(sp);

cst = PoolCST(sp);
cst =double(cst);

figure
hold on
for i = 1:n
    pwelch(sp(:,i),L,noverlap,nfft,fs);
end
pwelch(cst,L,noverlap,nfft,fs);
xlim([0,20]/fs);
H=findobj
set(H(4),'LineStyle','--','Color','r','LineWidth',1);

para=[];
for i=1:n-1
    para{i}='';
end
para{n}='single MU';
para{n+1} = 'CST';
legend(para)

end
