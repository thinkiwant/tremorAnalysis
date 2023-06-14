function [v, n] = findPeak(sig,k)
% return both the amplitude v and the index n of the kth highest peak of column vectors of sig. The
% returned variable, n is formed in shape of 1 x size(sig,2).
% figure();
% subplot(511);
% stem(sig);
% subplot(512)
if nargin == 1
    k=1;
end
dsig = diff(sig);
dsig1 = [zeros(1,size(dsig,2));dsig];
ndsig = [dsig;zeros(1,size(dsig,2))];
% stem(dsig1)
% subplot(513);
% stem(ndsig)
% subplot(514)
id_incr = (dsig1>0);
id_de = (ndsig<=0);
idPeak = id_incr & id_de;

% stem(idPeak)

sig(~idPeak) = -inf;

[B,I] = sort(sig,'descend');
v = B(k,:);
n = I(k,:);

end
