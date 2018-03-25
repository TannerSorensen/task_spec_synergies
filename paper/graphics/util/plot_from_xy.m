function plot_from_xy(xy_data,sections_id,color)
%PLOT_FROM_XY plot the articulator contours whose vertices are in xy_data
%and whose articulator identifiers are in sections_id.
% 
% INPUT:
%  Variable name: xy_data
%  Size: 1x2P, where P is the number of contour vertices
%  Class: double
%  Description: concatenated x- and y-coordinates of the articulator
%    contours from one real-time magnetic resonance image. 
% 
%  Variable name: sections_id
%  Size: 1x2P, where P is the number of contour vertices
%  Class: double
%  Description: array of numeric IDs for X- and Y-coordinates in xy_data; 
%    the correspondences are as follows: 01 Epiglottis; 02 Tongue; 
%    03 Incisor; 04 Lower Lip; 05 Jaw; 06 Trachea; 07 Pharynx; 08 Upper 
%    Bound; 09 Left Bound; 10 Low Bound; 11 Palate; 12 Velum; 13 Nasal 
%    Cavity; 14 Nose; 15 Upper Lip
% 
%  Variable name: color
%  Size: 1x1
%  Class: char
%  Description: string indicating color of lines, e.g., 'k'
% 
% FUNCTION OUTPUT:
%   none
% 
% SAVED OUTPUT:
%   none
% 
% EXAMPLE USAGE:
%   >> plot_from_xy([X(i,:) Y(i,:),[sections_id sections_id],'k')
% 
% Tanner Sorensen
% Signal Analysis and Interpretation Laboratory
% University of Southern California
% 03/16/2018

X=xy_data(1:length(xy_data)/2);
Y=xy_data(length(xy_data)/2+1:end);

X1=X(ismember(sections_id,1:6));
Y1=Y(ismember(sections_id,1:6));

X2=X(ismember(sections_id,7:10));
Y2=Y(ismember(sections_id,7:10));

X3=X(ismember(sections_id,11:15));
Y3=Y(ismember(sections_id,11:15));

plot(X1,Y1,'Color',color,'LineWidth',2);hold on;
plot(X2,Y2,'Color',color,'LineWidth',2);
plot(X3,Y3,'Color',color,'LineWidth',2);%hold off;

axis equal;




    

