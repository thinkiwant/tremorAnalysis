function [startList, endList, actionList, trig] = findInterval(trig, fs_input)
%trig should be the channel of trigger signal, 
%startList, endList include the time series where a trial starts or ends.
%actionList include the time series where a single trigger locates. And
%trig is the modified trig series.
if nargin == 1
    fs = 2000;
else
    fs = fs_input;
end

high = max(trig);
[rList, fList] = findEdges(trig);
if isempty(rList)&isempty(fList)
    startList=[];
    endList=[];
    actionList=[];
    disp("No trigger found");
    return
end
if(rList(1)<=fList(1))
    trig(1:rList(1))=high;
end
if(rList(end)<=fList(end))
    trig(fList(end):end)=high;
end
[rList, fList] = findEdges(trig);

iter = 1;
clickUplimit = 0.5*fs;%defines the interval between actions (e.g. start(i)-end(i))
clickslowlimit = 1;
actionInterval = 0.8 * fs; % the length of the window where am action type is identified.
disp(clickslowlimit)
lastDownId = fList(1);
actionList=[];
startList=[];
endList=[];
while(iter<=length(fList))
    cul = 0;
    while(iter<=length(fList) && fList(iter) - lastDownId < actionInterval)
        %if(rList(iter)-fList(iter) < clickUplimit && rList(iter)-fList(iter) > clickslowlimit)
        if(rList(iter)-fList(iter) < clickUplimit)
            cul = cul+1;
            iter = iter+1;
%         elseif(rList(iter)-fList(iter) < clickUplimit)
%             cul = 0;
%             laseDownid = fList(iter);
%             iter = iter + 1;
        else
            iter = iter+1;
            break
            %high = max(trig);
            %trig(fList(iter)+0.1*fs:rList(iter+1)-0.1*fs)=high;
            figure()
            plot(trig)
            xlim([fList(iter)-fs*0.2,rList(iter)+fs*0.2]);
            sprintf('Please click the position where the next edges locate.')
            [x,y,b] = ginput(1);
            high = max(trig);
            low = min(trig);
            sig = true;
            while(b==1)
                if sig
                    trig(x:rList(iter)) = high;
                else
                    trig(x:rList(iter)) = low;
                end
                sig = ~sig;
                plot(trig)
                xlim([fList(iter)-fs*0.5,rList(iter)+fs*0.5]);
                [x,y,b] = ginput(1);
              
            end
            [rList, fList] = findEdges(trig);
        end
    end
    if(iter<=length(fList))
        lastDownId = fList(iter);
    end
    switch(cul)
        case 1
            actionList = [actionList, rList(iter-1)];
        case 2
            startList = [startList, fList(iter-2)];% start from the first impulse
        case 3
            endList = [endList, rList(iter-1)]; %end at the last impulse
        otherwise
            startList
            endList
            actionList
            warning("Unknown click type, cumulative clicks: %d.", cul);
    end      
end
    if(length(startList) ~= length(endList))
        startList
        endList
        actionList
        behavior = input("unmatched index pairs, please choose to correct the trigger automatically or manually. A/M [A]",'s');
        if ~strcmp(behavior,'M')
            [startList, endList] = pickTrialFromIndexList(startList, endList);
        else
            figure
            plot(trig)
            hold on;
            plot(startList,ones(1,length(startList))*1000,'ro',endList,ones(1,length(endList))*1000,'kx'); 
            hold off;
            sprintf('Please modify the triggers.')
            [x,y,b] = ginput(1);
            high = max(trig);
            low = min(trig);
            zoom = 0;
            xlimtemp=[1,length(trig)];
            while((b==1)|(b==2)|(b==3))
                if b ==1    %set low level
                    trig(x:x+clickUplimit/8)=low;
                    plot(trig);
                    xlim(xlimtemp);
                elseif b==2 % to zoom in and out
                    if zoom == 0
                        xlimtemp = [x-clickUplimit*5,x+clickUplimit*5];
                        xlim(xlimtemp);
                        zoom = 1;
                    else
                        xlimtemp = [1,length(trig)];
                        xlim(xlimtemp);
                        zoom = 0;
                    end
                elseif b==3    %set high level
                    trig(x:x+clickUplimit/3)=high;
                    plot(trig);
                    xlim(xlimtemp);
                end
                %xlim([fList(iter)-fs*0.5,rList(iter)+fs*0.5]);
                [x,y,b] = ginput(1);
            end
            [startList,endList,actionList] = findInterval(trig);
        end 
    end
    close
end