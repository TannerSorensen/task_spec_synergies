function U_lar= get_Ular(contour_data, U_jaw, variant_switch)
% GET_ULAR - extract larynx factors for vocal-tract factor analysis as in: Asterios Toutios, Shrikanth S. Narayanan, "Factor 
% analysis of vocal-tract outlines derived from real-time magnetic resonance imaging data",ICPhS, Glasgow, UK, 2015.
% http://sipi.usc.edu/~toutios/
%
% Asterios Toutios
% University of Southern California
% Nov 15, 2017

if strcmp(variant_switch,'toutios2015factor')
    sections_id=contour_data.sections_id;

    D=[contour_data.X,contour_data.Y];

    %D=D-D*U_jaw*pinv(U_jaw);

    mean_data=ones(size(D,1),1)*mean(D);

    Dnorm=D-mean_data;

    vt_section=[7]; % Arytenoid

    % 01 Epiglottis
    % 02 Tongue
    % 03 Incisor
    % 04 Lower Lip
    % 05 Jaw
    % 06 Trachea
    % 07 Low Pharynx
    % 08 Arytenoid
    % 09 High Pharynx
    % 10 Outer Margin
    % 11 Palate
    % 12 Velum
    % 13 Nasal Cavity
    % 14 Nose
    % 15 Upper Lip


    sec_id_2=[sections_id,sections_id];

    Dnorm(:,~ismember(sec_id_2,vt_section))=0;

    [U,V,varpercent,m]=span_pca(Dnorm,size(D,2));

    U_lar=U;
else
    
    % center the data-set
    D = [contour_data.X,contour_data.Y];
    n = size(D,1);
    mean_data = mean(D);
    Dnorm = D - mean_data;

    % subtract the jaw component from the dataset
    Dnorm=Dnorm-Dnorm*U_jaw*pinv(U_jaw);

    %% Principal components analysis
    % subset data to velum
    sections_id = contour_data.sections_id;
    sec_id_2 = [sections_id,sections_id];
    vt_section = 7; % arytenoid label
    Dnorm_zero = Dnorm;
    Dnorm_zero(:,~ismember(sec_id_2,vt_section))=0;

    % principal components analysis of the larynx, minus the jaw component
    [U_larraw,~,latent] = pca(Dnorm_zero);

    %% Guided factor analysis
    % obtain data covariance matrix
    R = Dnorm_zero'*Dnorm_zero/n; % covariance matrix
    
    q_max = 3;
    U_lar = R*U_larraw(:,1:q_max)/chol(diag(latent(1:q_max)));
    
end