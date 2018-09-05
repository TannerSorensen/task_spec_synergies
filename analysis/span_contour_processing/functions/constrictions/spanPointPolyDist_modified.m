function [d,xPolyClosest,yPolyClosest] = spanPointPolyDist_modified(xPoint, yPoint, xPoly, yPoly)
%function [d,xPolyClosest,yPolyClosest] = spanPointPolyDist_modified(xPoint, yPoint, xPoly, yPoly)
%
% Calculates the closest distance between the point (xPoint,yPoint) and the
% polygon whose vertices are given in the (xPoly,yPoly) vectors.
%
% The closest point(s) on the polygon is(are) returned.
%
% From Mathworks.com, modified by E.Bresch, USC SPAN Group, 2008
% Modified by Vikram Ramanarayanan, USC SPAN, Sept 2009.


x  = xPoint(1);
y  = yPoint(1);
xv = xPoly(:);
yv = yPoly(:);

% linear parameters of segments that connect the vertices
% Ax + By + C = 0
A = -diff(yv);
B =  diff(xv);
C = yv(2:end).*xv(1:end-1) - xv(2:end).*yv(1:end-1);

% find the projection of point (x,y) on each rib
AB = 1./(A.^2 + B.^2);
vv = (A*x+B*y+C);
xp = x - (A.*AB).*vv;
yp = y - (B.*AB).*vv;

% Test for the case where a polygon rib is 
% either horizontal or vertical. From Eric Schmitz
id = find(diff(xv)==0);
xp(id)=xv(id);
clear id
id = find(diff(yv)==0);
yp(id)=yv(id);

% find all cases where projected point is inside the segment
idx_x = (((xp>=xv(1:end-1)) & (xp<=xv(2:end))) | ((xp>=xv(2:end)) & (xp<=xv(1:end-1))));
idx_y = (((yp>=yv(1:end-1)) & (yp<=yv(2:end))) | ((yp>=yv(2:end)) & (yp<=yv(1:end-1))));
idx = idx_x & idx_y;

% distance from point (x,y) to the vertices
dv = sqrt((xv(1:end)-x).^2 + (yv(1:end)-y).^2);

if(~any(idx)) % all projections are outside of polygon ribs
   d = min(dv);
   I = find(dv==d);
   x_poly = xv(I);
   y_poly = yv(I);
else
   % distance from point (x,y) to the projection on ribs
   dp = sqrt((xp(idx)-x).^2 + (yp(idx)-y).^2);
   min_dv = min(dv);
   I1 = find(dv==min_dv);
   min_dp = min(dp);
   I2 = find(dp==min_dp);
   [d,I] = min([min_dv min_dp]);
   
   %Note that for VTADs computation we want the closest VERTEX...
   
%    if I==1, %the closest point is one of the vertices
       x_poly = xv(I1);
       y_poly = yv(I1);
%    elseif I==2, %the closest point is one of the projections
%        idxs = find(idx);
%        x_poly = xp(idxs(I2));
%        y_poly = yp(idxs(I2));
%    end
end

xPolyClosest = x_poly;
yPolyClosest = y_poly;

return