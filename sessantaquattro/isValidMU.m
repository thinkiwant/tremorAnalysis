function [isValid] = isValidMU(s)
%this function is designed to return the index of sources which are likely
%to be valid decomposition resuls by judge from the monotonously increasing
%trend of the psd between 20~100 Hz scale. The result is shown to be not
%accurate enough when compared with the manual detection.

fs = 2048;
list = ones(size(s,2),1);
for i = 1:length(list)
    [pxx,f] = pwelch(s(:,i),5000,2000,2^13,2000);
    [b,a] = butter(2,2/(fs/2),'low');
    fpxx = filter(b,a,pxx);
    plot(f,fpxx);
    dfpxx = diff(fpxx);
    id = (f>20&f<100);
    if(all(dfpxx(id(1:end-1))>=0))
        %isvalid = true
    else
        %isvalid = false
        list(i) = 0;
    end
end
isValid = list;

end
