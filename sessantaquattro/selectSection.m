function [selectedSig] = selectSection(sig, chan, fs)

if nargin == 1
    plotChan = 1;
else
    plotChan = chan;
end

[m,n] = size(sig);
if m<n
    sig = sig';
end

if nargin ~= 3
    fs=2000;
end

t=0:length(sig)-1;
t=t/fs;

clickLen = length(sig)*0.1/fs;
f1 = figure;
plot(t,sig(:,plotChan))
ylabel('EMG / (mV)');
xlabel('Time / (Second)');

hold on;
%plot(startList,ones(1,length(startList))*1000,'ro',endList,ones(1,length(endList))*1000,'kx');      
sprintf('Please select the zone.')
[x,y,b] = ginput(1);
zoom = 0;
xList=[];
yList=[];
verticalBar = [min(sig(plotChan,:)),max(sig(plotChan,:))];
i=0;
while(1)

    if b ==1
        xList=[xList,x];
        yList = [verticalBar',yList];
        h = plot([x,x+1/fs]',verticalBar','r-');
        i=i+1
        hL(i)=h;
    elseif b==2
        if zoom == 0
            xlim([x-clickLen,x+clickLen]);
            zoom = 1;
        else
            xlim([1,length(sig)]/fs);
            zoom = 0;
        end
    elseif b == 3

        delete(hL(i))
        i=i-1;

        xList(1)=[];
        yList(:,1)=[];     
        size(xList)
        size(yList)
    end
    [x,y,b] = ginput(1);
    if(isempty(x))
        selectedSig=floor(xList*fs);
        
        close(f1)
        return
    end
end
end