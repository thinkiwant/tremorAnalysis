function counts=findsuperimposecount(rawfirdata)
%using this function, find the count of how many spikes overlap within a
%certain interval.
%'rawfirdata' is the raw firing data input and 'counts' is the number of overlaps per
%firing per trial. length(counts) is the number of trials and
%length(counts{:}) is the number of firing events per trial
 %tic
 % originally wrote by Henry Shin  SMU@RIC
 % revised by Xiaogang Hu
 
 
%CHANGE TOTAL INTERVAL LENGTH HERE (in seconds)
intlength=.005; %seconds  

%divide up input
time=rawfirdata(:,1);%reference time of all events
%firdata=sparse(rawfirdata(:,2:end));%only firing data (sparse matrix to save memory space)
firdata=rawfirdata(:,2:end);%only firing data, no sparse
numtrials=size(firdata,2); %number of trials

%logical conversion of the matrix of firing events
%logicalfir=logical(firdata);
%sampling rate of firings
fs=1/(time(2)-time(1));
halfintindlen=round(intlength*fs/2); %half interval index length

counts=cell(numtrials,1);
%get counts
for trial=1:numtrials
    firindex=find(firdata(:,trial)); %index value of each firing event
    beginindex=firindex-halfintindlen;%starting index of every interval
    beginindex(beginindex <= 0) =1; %@@@@@@@@@@ added by Xiaogang. fix out of matrix dimension error
    
    endindex=firindex+halfintindlen;%ending index of every interval
    endindex(endindex > size(firdata,1)) =size(firdata,1); %@@ added by Xiaogang. fix out of matrix dimension error
    
    firnum=length(firindex); %number of events
    counts{trial}=zeros(firnum,1); %preset zeros for speed
    for mu=1:firnum
        %find the sum of the number of overlaps in an interval across all firdata
        %minus 1 for itself
        %counts{trial}(mu)= sum(sum(firdata(beginindex(mu):endindex(mu),:)))-1;
        tmp0 = sum(sum(firdata(beginindex(mu):endindex(mu),:)))-1;
        %tmp1 = ((numtrials - tmp0) / numtrials) ^3;
        %tmp1 = sqrt(1 / (tmp0 + 1));
        tmp1 = (1 / (tmp0 + 1) ); % Syn weightings for STA
        counts{trial}(mu)= tmp1;
    end
end
%toc
