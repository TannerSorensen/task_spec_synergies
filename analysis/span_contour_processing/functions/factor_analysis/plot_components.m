function plot_components(config_struct, contour_data, variant_switch, q)

sections_id=contour_data.sections_id;

D=[contour_data.X,contour_data.Y];
U=contour_data.U_gfa;
mean_vt_shape=contour_data.mean_vt_shape;

mean_data=ones(size(D,1),1)*mean(D);
std_data=ones(size(D,1),1)*std(D);

std_weights = std(contour_data.weights);

if strcmp(variant_switch,'toutios2015factor')
    Dnorm=(D-mean_data)./std_data;
else
    Dnorm=D-mean_data;
end

components=[1:q.jaw ...
    (q.jaw+1):(q.jaw+q.tng) ...
    (q.jaw+q.tng+1):(q.jaw+q.tng+q.lip) ...
    (q.jaw+q.tng+q.lip+1):(q.jaw+q.tng+q.lip+q.vel) ...
    (q.jaw+q.tng+q.lip+q.vel+1):(q.jaw+q.tng+q.lip+q.vel+q.lar)];

close all;

for j=1:(q.jaw+q.tng+q.lip+q.vel+q.lar);  % component under examination
    
    parameters=zeros(1,q.jaw+q.tng+q.lip+q.vel+q.lar);
    
    i=components(j);
    
    %DD = Dnorm*U(:,i)*pinv(U(:,i));
    
    parameters(i)=-2*std_weights(i);
    plot_from_xy(weights_to_vtshape(parameters, mean_vt_shape, U, variant_switch),sections_id(1,:),'b'); hold on
    
    parameters(i)=2*std_weights(i);
    plot_from_xy(weights_to_vtshape(parameters, mean_vt_shape, U, variant_switch),sections_id(1,:),'r'); 
    
    plot_from_xy(mean(D),sections_id(1,:),'k'); hold off
        
    axis([-40 20 -30 30]); axis off;

    print(fullfile(config_struct.out_path,sprintf('factor_%d_jaw%d_tng%d_lip%d_vel%d_lar%d.pdf',j,q.jaw,q.tng,q.lip,q.vel,q.lar)),'-dpdf')
    
    close all
end



