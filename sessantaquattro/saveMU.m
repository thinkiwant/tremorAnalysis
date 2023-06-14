tic
partN = 1;  % divide each trial into how many parts
modulePacketList = {"SIL","sGood","SpikeTrainGood","B","GoodIndex","EMG_extend","NullChan"};    % variables to store
modulePacket = "{";
for i = 1:length(modulePacketList)-1
    modulePacket = strcat(modulePacket,modulePacketList{i},',');
end
modulePacket = strcat(modulePacket,modulePacketList{length(modulePacketList)});
modulePacket = modulePacket + "}";
disp(modulePacket);

for ti = [2]    % the number of trial
    eval(sprintf("data = experiment%d;",ti)); 
    segN = length(data);
    for si =1:segN % for each segment
        partL = floor(length(data{si})/partN);  % length for each segment
        parts = 1:partL:partL*partN;
        for part = 1:partN % for each part
            n =floor((size(data{si},1)-6)/64);%% number of modules

            nullCell = {};
            for m = 1:n % for each module
                fprintf("Processing the %d session, %d trial %d part %d Module\n\n",ti,si,part,m);
                modulePacketCmd = strcat("M",num2str(m)," = ",modulePacket,";");
                EMG_Reconstruct = data{si}([1:64]+64*(m-1),[0:partL-1]+parts(part))';            
                
                 ValidCH=[];   
                 for i = 1:size(EMG_Reconstruct,2)
                     if any(EMG_Reconstruct(:,i))
                         ValidCH = [i, ValidCH];
                     else % if it is a null channel, use its adjacent channel 
                         for j = 0:7
                             nearid = getNearByCh(i, j);    
                             if(any(EMG_Reconstruct(:,nearid)))
                                 EMG_Reconstruct(:,i) = EMG_Reconstruct(:,nearid);
                                 break
                             end
                         end
                     end
                 end
                 NullChan = setdiff([1:64],ValidCH);
                if(64-length(ValidCH)>6)    % abandon modules with too much null channels
                     warning("too many null channels, module is skipped.")
                     for i = 1:length(modulePacketList)
                         eval(strcat(modulePacketList{i},"=[];"));
                     end
                     eval(modulePacketCmd);
                     continue;
                end
                disp(sprintf("%d channels are null.\n", 64-length(ValidCH)))%
                DataMatrix = EMG_Reconstruct;
                SJTUDemo_Decomp_Main();
                eval(modulePacketCmd);
            end
            
            
            eval(sprintf("rawData = data{%d}(:,%d:%d);",si,parts(part),parts(part)+partL-1));
            Mstr=[];
            for i = 1:n
                Mstr = [Mstr,strcat(' ''M',num2str(i),'''')];
                if(i~=n)
                    Mstr=[Mstr, ','];
                end
            end
                cmd = strcat("save('Sub7PostOffRestingTrial",num2str(ti),"Trial",num2str(si),"Segment",num2str(part),"',",Mstr,");")
            eval(cmd);
            toc
        end
    end
end
msgbox('Decomposition ends')
