addpath(genpath('functions'))

configStruct=config;

outPath = configStruct.out_path;
load(fullfile(sprintf(outPath,'ac2_var'),'contour_data.mat'))


figure;
for i=1:100
    
    plot_from_xy([contour_data.X(i,:),contour_data.Y(i,:)],contour_data.sections_id,'b');
    plot_from_xy([contour_data.Xsim(i,:),contour_data.Ysim(i,:)],contour_data.sections_id,'r'); 
    axis([-45 45 -45 45]); axis off;

    
    for j=1:6
        
        plot([contour_data.tv{j}.in(i,1) contour_data.tv{j}.out(i,1)], [contour_data.tv{j}.in(i,2) contour_data.tv{j}.out(i,2)],'bo-');
        plot([contour_data.tvsim{j}.in(i,1) contour_data.tvsim{j}.out(i,1)], [contour_data.tvsim{j}.in(i,2) contour_data.tvsim{j}.out(i,2)],'ro-');
        
    end;
    
    pause(0.1); hold off;
    
end;