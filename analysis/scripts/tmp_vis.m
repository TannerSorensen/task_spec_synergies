addpath(genpath(fullfile('..','span_contour_processing')))

%visualize biomarker value
load(fullfile('..','mat_synth','bm_validation'))

figure(1)

semilogx([1e-1; 1e0; 1e1],[la_bm; alv_bm; pal_bm; vel_bm]','LineWidth',2)
hold on
legend({'p','t','y','k'})
ylim([-0.05 1.05])
xlim([1e-5 1e5])
semilogx([1e-2; 1e2],[0; 0],'--k')
semilogx([1e-2; 1e2],[1; 1],'--k')
legend({'p','t','y','k'})
set(gca,'xtick',[1e-2 1e0 1e2],'xticklabels',{'1e-4','1e0','1e4'})
xlabel('JA weight')
ylabel('\lambda')
hold off

% visualize factors
load(fullfile('..','mat_synth','bm_validation'))
factor_name = {'jaw','tongue 1','tongue 2','tongue 3','tongue 4','lips 1','lips 2'};
participant_name = {'JA weight = 1e-1','JA weight = 1e0','JA weight = 1e1'};
figure('DefaultAxesPosition', [0.1, 0.1, 0.8, 0.8])
for participant_idx = 1:3
    load(fullfile('..','mat_synth',['synth_participant' num2str(participant_idx)],'contour_data_jaw1_tng4_lip2_vel1_lar2_f70'))
    
    for factor_idx = 1:7
        subplot(3,7,(7*(participant_idx-1))+factor_idx)
        w = zeros(7,1);
        w(factor_idx) = 1;
        
        plot_from_xy(contour_data.mean_vt_shape' + contour_data.U_gfa*w,contour_data.sections_id,'r'), hold on
        plot_from_xy(contour_data.mean_vt_shape' - contour_data.U_gfa*w,contour_data.sections_id,'b'), hold on
        plot_from_xy(contour_data.mean_vt_shape,contour_data.sections_id,'k'), hold off
        
        if participant_idx == 1
            title(factor_name{factor_idx})
        end
        if factor_idx == 1
            xl = get(gca,'XLim');
            yl = get(gca,'YLim');
            text(xl(1)-(xl(2)-xl(1)), yl(2)-0.5*(yl(2)-yl(1)), participant_name{participant_idx},'FontWeight','bold')
        end
    end
end

% visualize constriction locations
load(fullfile('..','mat_synth','bm_validation'))
tv_name = {'bilabial','alveolar ridge','hard palate','soft palate'};
participant_name = {'JA weight = 1e-1','JA weight = 1e0','JA weight = 1e1'};
figure('DefaultAxesPosition', [0.1, 0.1, 0.8, 0.8])
for participant_idx = 1:3
    load(fullfile('..','mat_synth',['synth_participant' num2str(participant_idx)],'contour_data_jaw1_tng4_lip2_vel1_lar2_f70'))
    
    for tv_idx = 1:4
        subplot(3,4,(4*(participant_idx-1))+tv_idx)
        
        plot_from_xy(contour_data.mean_vt_shape,contour_data.sections_id,'k')
        in = median(contour_data.tv{tv_idx}.in);
        out = median(contour_data.tv{tv_idx}.out);
        scatter(in(1),in(2),[],'r','filled')
        scatter(out(1),out(2),[],'r','filled')
        plot([in(1) out(1)],[in(2) out(2)],'r','LineWidth',2)
        
        if participant_idx == 1
            title(tv_name{tv_idx})
        end
        if tv_idx == 1
            xl = get(gca,'XLim');
            yl = get(gca,'YLim');
            text(xl(1)-(xl(2)-xl(1)), yl(2)-0.5*(yl(2)-yl(1)), participant_name{participant_idx},'FontWeight','bold')
        end
    end
end
