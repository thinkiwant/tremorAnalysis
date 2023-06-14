%% To generate MU action potential
for i = 1:length(MUSPGroup)
    emg = EMGGroup{i};
    for j = 1:length(MUSPGroup{i})
        MUAPGroup{i}{j} = HighDensityMUAP(emg,MUSPGroup{i}{j},2000,'NeedleType','MonoPolar');
    end
end
%%
figure;
trial1 = 1;

MuscleCoher;
figure;
trial1 = 2;

MuscleCoher
figure;
trial1 = 3;

MuscleCoher

%% calculate correlation between MUs

trial1 = 2;
trial2 = 3;
limitC = 0.60;

cln = length(MUSPGroup{trial2});
rw = length(MUSPGroup{trial1});
sbploti=0;
similarModuleID=[];
similarMUID=[];
for id1 = 1:rw
    for id2 = 1:cln
        sbploti = sbploti+1;
        if(trial1 == trial2 & id1>id2)
            continue
        end
        subplot(cln,rw,sbploti);
        muap1 = MUAPGroup{trial1}{id1};
        muap2 = MUAPGroup{trial2}{id2};
        clear cMatrix;
        for i = 1:length(muap1)
            for j = 1:length(muap2)
                %cMatrix(i,j) = calMUAPxcorr(muap1{i},muap2{j});      
                cMatrix(i,j) = xcorr2D(muap1{i},muap2{j}); 
            end
        end

        [r,c] = find(cMatrix>limitC);
        if(trial1 == trial2 & id1 == id2)
            asym = find(r~=c);
            r = r(asym);
            c = c(asym);
            halfid = find(r<c);
            r = r(halfid);
            c = c(halfid);
        end
            Midtemp = ones(2,length(r));
            Midtemp(1,:) = id1;
            Midtemp(2,:) = id2;
            similarModuleID = [similarModuleID,Midtemp];
            similarMUID = [similarMUID,[r';c']];
        clims=[0,1];
        imagesc(cMatrix, clims)
        hold on;
        plot(c,r,'ro');
        hold off;
        %title("Cross correlation coefficient");
        set(gca,'FontSize',18);
    end
end
sg = strcat("Cross correlation coefficient (DBS-off, loading Phase 2 vs. 3, Circle: ",num2str(limitC),")");
sgtitle(sg);
colorbar
similarModuleID;
similarMUID;
size(similarMUID,2)


%%
function [COR] = calMUAPxcorr(muap1, muap2)
    for i = 1:size(muap1,2)
        [c,~] = xcorr(muap1(:,i),muap2(:,i),'normalized');
        cList(i) = max(c);
    end
    COR = mean(cList(~isnan(cList)));
end

