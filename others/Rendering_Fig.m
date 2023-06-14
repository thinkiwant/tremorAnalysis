function Rendering_Fig(width, height, fig_name, picture_dir, print_flag)
% Set picture size and rendering figure in svg format
set(gcf,'Units','centimeters','position',[1 1 width height],'PaperUnits','centimeters','PaperPosition',[0 0 width height],...
         'color','w','PaperSize',[8.5, 11]);
if print_flag==1
    print('-painters',[picture_dir,fig_name,'.svg'],'-dsvg','-r360');
elseif print_flag==2
    print('-painters',[picture_dir,fig_name,'.tif'],'-dtiff','-r360');
elseif print_flag==3
    print('-painters',[picture_dir,fig_name,'.png'],'-dpng','-r300');
end

end
