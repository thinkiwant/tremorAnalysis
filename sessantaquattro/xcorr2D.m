function r = xcorr2D(fig1,fig2)

fig1bar = mean(mean(fig1));
fig2bar = mean(mean(fig2));
fig1c = fig1 - fig1bar;
fig2c = fig2 - fig2bar;

D12 = sum(sum((fig1c.*fig2c)));
D11 = sum(sum(fig1c.^2));
D22 = sum(sum(fig2c.^2));

r = D12/sqrt(D11*D22);
end