dataB = sigB(25,:);
dataD = sigD(34,:);
for i = 1:length(eLB)
    sub_dataB = dataB(sLB(i):eLB(i));
    [c,lags] = xcorr(dataD,sub_dataB);
    figure;
    stem(lags,c);
    xlabel('shift');
    ylabel('corr');
    name = 'corss-correlation of';
    name = strcat(name, int2str(i),' th trial');
    title(name);
end