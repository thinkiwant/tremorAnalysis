N = length(GoodList);

it = 1;
for i = 1:N
    ref = xcorr(SpikeTrainGood(:,GoodList(i)),SpikeTrainGood(:,GoodList(i)));
    for j=i+1:N
        c = xcorr(SpikeTrainGood(:,GoodList(i)),SpikeTrainGood(:,GoodList(j)));
        if max(c)>ref*0.5
            sameMU{it}=[GoodList(i),GoodList(j)];
            it=it+1;
        end
    end
end
            