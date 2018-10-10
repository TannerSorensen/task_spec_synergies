load(fullfile('templates','template_struct_converted.mat'), 'template_struct');

keep_articulators = {[1 2 3 4 5], [7]-6, [11 12 15]-10};
vcv_type = {'[p]','[t]','[k]','[a]','[i]'};
graphics_path = 'templates';


cm = linspecer(9); 
scale_factor = 10;
x_offset = 0.6;
em=1;

for i=1:length(template_struct)
    ell = 1; % for unique colors for each contour
    for j=1:3
        articulator_list = unique(template_struct(i).model.segment{j}.i);
        articulator_list = articulator_list(ismember(articulator_list,keep_articulators{j}));
        articulator_indicator = template_struct(i).model.segment{j}.i;
        
        if i==length(template_struct) && j==1
            em=1;
            h1=[];
        elseif i==length(template_struct) &&  j==2
            em=1;
            h2=[];
        end
        for k=1:length(articulator_list)
            x = template_struct(i).model.segment{j}.v(articulator_indicator == articulator_list(k),1); hold on;
            y = template_struct(i).model.segment{j}.v(articulator_indicator == articulator_list(k),2); hold on;
            x = x + (i-1)*x_offset;
            if j==1
                h1(em) = plot(smooth(x,3),smooth(y,3), 'Color', cm(ell,:), 'LineWidth', 3);
            elseif j>1
                h2(em) = plot(smooth(x,3),smooth(y,3), 'Color', cm(ell,:), 'LineWidth', 3);
            end
            ell = ell+1;
            em = em+1;
        end
        if i==length(template_struct) && j==1
            % Create the first legend
            lh1 = legend(h1,{'epiglottis','tongue','mandible','lower lip','chin'},'Location','South','Orientation','horizontal');
            lh1_position = get(lh1,'Position');
            lh1_position(1) = lh1_position(1)+0.05;
            lh1_position(2) = lh1_position(2)+0.2;
            set(lh1,'Position',lh1_position);
            legend('boxoff')
            
            xl = [-0.325 2.7];
            yl = [-0.20 0.35];

            axis equal
            axis off
            xlim(xl)
            ylim(yl)

            % Name the first axis ax1 and create a second axis on top of the first
            ax1 = gca;
            ax2 = axes('Position',get(ax1,'Position'));
        elseif i==length(template_struct) && j==3
            xl = [-0.325 2.7];
            yl = [-0.20 0.35];

            axis equal
            axis off
            xlim(xl)
            ylim(yl)
            % Now, link the first axis to the second and make the second invisible
            linkaxes([ax1 ax2],'xy');
            set(ax2,'Color','none','XTick',[],'YTick',[],'Box','off');

            % Now make the second legend just above the first
            lh2 = legend(h2,{'pharynx','hard palate','soft palate','upper lip'},'Orientation','horizontal');
            lh2_position = lh1_position;
            lh2_position(1) = lh2_position(1)-0.015;
            lh2_position(2) = lh1_position(2)+1*lh2_position(4);
            set(lh2,'Position',lh2_position);
            legend('boxoff')
        end
    end
    
    text(-0.25 + (i-1)*x_offset,0.30,vcv_type{i},'FontSize',14)
end

print(fullfile(graphics_path,['templates.pdf']),'-dpdf','-r0')

