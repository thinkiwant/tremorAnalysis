%a=[9  12  14  17   18  21  23  26]
% normal=[0.486 0.453 0.416 0.503 0.381 0.375 0.483 0.368 0.712 0.576 0.597 0.475 0.550 0.327 0.337];
% control=[0.069 0.092 0.083 0.048 0.101 0.196 0.182 0.122 ];
normal = tremorFreqCoher{1};
control = tremorFreqCoher{2};
total=[normal,control];
m = length(normal);
n = length(control);
Mnormal = mean(total(1:m));
Mcontrol = mean(total(m+1:end));
SumA = sum(total);
TS = Mcontrol-Mnormal   %计算检验统计量
Rearranges = combnk(total,m);   %组合，重排，本例有70行
MeanControls = sum(Rearranges,2)/m;   %重排后Control组的样本均值，本例有70行
MeanDrugs = (SumA-sum(Rearranges,2))/n;   %重排后Drug组的样本均值，本例有70行
PermutationValues = MeanDrugs - MeanControls;   %置换值，本例有70行
[t,n]=size(PermutationValues);
hist(PermutationValues )    % 产生直方图

GreaterNumbers=0;    %计算超过检验统计量的置换值的个数
for i=1:t
    if PermutationValues(i,1)>=TS
        GreaterNumbers=GreaterNumbers+1;
    end
end;

PValue=GreaterNumbers/t %计算P值