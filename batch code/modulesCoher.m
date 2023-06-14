tiledlayout('flow');
for i = 1:3
    for j = i:3
        nexttile();
        eval(strcat('calCohe(SPo2',num2str(i),',SPo2',num2str(j),');'));
        subtitle(strcat(num2str(i),' vs. ', num2str(j)));
    end
end
lgd = legend({'subset of Coherence','Average Coherence','Confidence Level'});
lgd.Layout.Tile = 11;
s=sgtitle('Coherence among 3 Muscles (DBS-on, Resting 1)');
s.FontSize=20;