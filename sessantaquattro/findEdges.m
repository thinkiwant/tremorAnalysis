function [rList, fList] = findEdges(trig)

fs=2000;
threshold = mean([min(trig),max(trig)]); % set the threshold for low voltage (mV）

t = find(trig>=-100 & trig<threshold);
len = length(t);
j=2;
if isempty(t)
    rList = [];
    fList = [];
    return;
end
if t(1)==1
    c=t(1)-1;
    fList(1) = t(1);
else
    fList(1) = t(1);
    c = t(2)-1;
end
for i = 2:len
    if (c~= t(i)-1)
        fList(j) = t(i);
        rList(j-1) = t(i-1);
        j = j +1;
    end
    c=t(i);
end
rList(j-1) = t(end);
j=j-1;
sprintf('falling list: %d, j:%d',length(fList),j);
sprintf('rising list: %d, j:%d',length(rList),j);

plot(trig);
hold on;
plot(fList,ones(1,j)*1000,'ro',rList,ones(1,j)*1000,'kx');
hold off;
end