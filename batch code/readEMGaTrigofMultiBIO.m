filePrefix = 'ARES';
fileList = ['a','b','c','d'];
filePostfix = '001.BIO';

imcompleteList=[];

for i = 1:length(fileList)
    fp = strcat(filepath,'\',fileList(i),'\',filePrefix,upper(fileList(i)),filePostfix);
    disp(fp)
    sig = Read_sessa_bio_file_v1_1(fp);
    trig{i} = sig(66,:)';
    data{i} = sig(1:64,:)';
    [sL{i}, eL{i}] = findInterval(trig{i});
    
end


