function calDFT(data,fs)
if size(data,1)==1
    data = data';
end

[L, ~] = size(data);
N = 2^nextpow2(L);

y = fft(data,N);
P1 = abs(y)/N;
P2 = P1(1:N/2+1);
P2(2:end-1)=P2(2:end-1)*2;
f = 0:fs/N:fs/2;
plot(f,P2);
xlabel('Freq (Hz)');
ylabel('Amplitude (Au)')

