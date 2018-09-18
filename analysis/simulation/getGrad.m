function [dzdt,dwdt] = getGrad(z,w,file)
% GETGRAD - returns time derivative of task variables and factor weights,
% splitting by file identifier so that discontinuities are not differenced.
% 
% INPUT: 
%  z - (Nx6 array of double) constriction degrees (columns) in real-time
%    magnetic resonance imaging video frames
%  w - (Nx8 array of double) factor coefficients (columns) of contours in
%    real-time magnetic resonance imaging video frames
%  file - (length-N array of double) file index; gradient is not computed 
%    across file breaks
% 
% FUNCTION OUTPUT: 
%  dzdt - (Nx6 array of double) gradient of constriction degrees over time
%  dwdt - (Nx6 array of double) gradient of factor coefficients over time
% 
% SAVED OUTPUT: 
%  none
% 
% Tanner Sorensen
% Signal Analysis and Interpretation Laboratory
% Tanner Sorensen, March 7, 2016

fileBreaks = [1; find(diff(file)==1); size(z,1)];

dzdt = NaN(size(z,1),size(z,2));
dwdt = NaN(size(w,1),size(w,2));
for i=2:max(file)+1
    ii = fileBreaks(i-1):fileBreaks(i);
    [~,dzdt(ii,:)] = gradient(z(ii,:));
    [~,dwdt(ii,:)] = gradient(w(ii,:));
end

end