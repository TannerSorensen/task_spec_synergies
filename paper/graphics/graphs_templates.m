load(fullfile('templates','template_struct_converted.mat'), 'template_struct');

keep_articulators = {[1 2 3 4 5], [7]-6, [11 12 15]-10};
vcv_type = {'[p]','[t]','[k]','[a]','[i]'};
graphics_path = 'templates';

cm = linspecer(9); 
scale_factor = 10;

for i=1:length(template_struct)
    figure(i)
    ell = 1; % for unique colors for each contour
    for j=1:3
        articulator_list = unique(template_struct(i).model.segment{j}.i);
        articulator_list = articulator_list(ismember(articulator_list,keep_articulators{j}));
        articulator_indicator = template_struct(i).model.segment{j}.i;
        
        for k=1:length(articulator_list)
            x = template_struct(i).model.segment{j}.v(articulator_indicator == articulator_list(k),1); hold on;
            y = template_struct(i).model.segment{j}.v(articulator_indicator == articulator_list(k),2); hold on;
            h(ell) = plot(smooth(x,3),smooth(y,3), 'Color', cm(ell,:), 'LineWidth', 6);
            ell = ell+1;
        end
    end
    
    if i==length(template_struct)
        xl = [-0.35 0.55];
        yl = [-0.20 0.35];
        
        axis equal
        xlim(xl)
        ylim(yl)
        
        lh = legend(h,'epiglottis','tongue','mandible','lower lip','chin','pharynx','hard palate','soft palate','upper lip',...
            'Location','East');
        lh.FontSize = 22;
        
        axis off
    else
        xl = [-0.35 0.20];
        yl = [-0.20 0.35];
        
        axis equal
        xlim(xl)
        ylim(yl)
        axis off
    end
    
    text(-0.25,0.30,vcv_type{i},'FontSize',48)
    
    fig = gcf;
    fig.PaperUnits = 'normalized';
%     fig.PaperPosition = scale_factor*[0 0 abs(diff(xl)) abs(diff(yl))];
    fig.PaperPosition = [0 0 1 1];
    print(fullfile(graphics_path,['template_' num2str(i) '.pdf']),'-dpdf','-r0')
end




