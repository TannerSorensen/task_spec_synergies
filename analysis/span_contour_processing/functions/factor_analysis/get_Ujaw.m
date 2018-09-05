function U_jaw = get_Ujaw(contour_data,variant_switch)
% GET_UJAW - extract jaw factor for vocal-tract factor analysis as in: Asterios Toutios, Shrikanth S. Narayanan, "Factor 
% analysis of vocal-tract outlines derived from real-time magnetic resonance imaging data",ICPhS, Glasgow, UK, 2015.
% http://sipi.usc.edu/~toutios/
%
% Asterios Toutios
% University of Southern California
% Nov 15, 2017

if strcmp(variant_switch,'toutios2015factor')
    sections_id=contour_data.sections_id;

    D=[contour_data.X,contour_data.Y];

    d=size(D,2);

    mean_data=ones(size(D,1),1)*mean(D);

    Dnorm=D-mean_data;

    vt_section=[5,3]; %Jaw + Incisor

    % 01 Epiglottis
    % 02 Tongue
    % 03 Incisor
    % 04 Lower Lip
    % 05 Jaw
    % 06 Trachea
    % 07 Pharynx
    % 08 Upper Bound
    % 09 Left Bound
    % 10 Low Bound
    % 11 Palate
    % 12 Velum
    % 13 Nasal Cavity
    % 14 Nose
    % 15 Upper Lip

    sec_id_2=[sections_id,sections_id];

    Dnorm(:,~ismember(sec_id_2,vt_section))=0;

    [U,V,varpercent,m]=span_pca(Dnorm,d);

    close all;

    U_jawraw=U;

    %%% GFA

    vt_section=[1:6];


    sections_id=contour_data.sections_id;

    D=[contour_data.X,contour_data.Y];

    mean_data=ones(size(D,1),1)*mean(D);

    Dnorm=D-mean_data;

    sec_id_2=[sections_id,sections_id];

    Dnorm(:,~ismember(sec_id_2,vt_section))=0;

    n = size(D,1);

    % Covariance matrix
    R = Dnorm'*Dnorm/n;

    % GFA Overall
    
    t1=U_jawraw(:,1);

    v=t1'*R*t1;

    h1=t1/sqrt(v);

    f1=(h1'*R)';

    %a1=inv(R)*f1;

    R2=R-f1*f1';

    U_jaw=f1;

else
    
    % center the data-set
    D = [contour_data.X,contour_data.Y];
    [n,d] = size(D);
    mean_data = mean(D);
    Dnorm = D - mean_data;
    
    % zero out non-jaw and non-incisor contour vertices
    sections_id = contour_data.sections_id;
    sec_id_2 = [sections_id,sections_id];
    vt_section = [5,3]; % jaw and incisor labels
    Dnorm_zero = Dnorm;
    Dnorm_zero(:,~ismember(sec_id_2,vt_section)) = 0;
    
    % obtain principal axes U_jawraw and variances LATENT on principal axes
    [U_jawraw,~,latent]=pca(Dnorm_zero);

    % zero out non-jaw, non-lip, and non-tongue contour vertices
    vt_section = 1:6;
    Dnorm_zero = Dnorm;
    Dnorm_zero(:,~ismember(sec_id_2,vt_section)) = 0;

    % compute covariance matrix of jaw, lip, and tongue contour vertices
    R = Dnorm_zero'*Dnorm_zero/(n-1);

    % obtain jaw factor
    q_max = 3;
    U_jaw = R*U_jawraw(:,1:q_max)/(chol(diag(latent(1:q_max))));
    
end