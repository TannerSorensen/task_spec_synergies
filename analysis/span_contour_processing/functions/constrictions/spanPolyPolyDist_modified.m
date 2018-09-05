function [d,xPoly1Closest,yPoly1Closest,xPoly2Closest,yPoly2Closest] = spanPolyPolyDist_modified(xPoly1, yPoly1, xPoly2, yPoly2)
%function [d,xPoly1Closest,yPoly1Closest,xPoly2Closest,yPoly2Closest] = spanPolyPolyDist_modified(xPoly1, yPoly1, xPoly2, yPoly2)
%
% Calculates the closest distance between the polygons whose vertices are 
% given in the (xPoly1,yPoly1) and (xPoly2,yPoly2) vectors.
%
% The distance and the closest point(s) on the polygon is(are) returned.
%
% Uses the functions spanPointPolyDist_modified.m and spanSegmentsCross.m
%
% From Mathworks.com, modified by E.Bresch, USC SPAN Group, 2008
% Modified by Vikram Ramanarayanan, USC SPAN, Sept 2009 for use with VTAD
% computations...

xPoly1 = xPoly1(:);
yPoly1 = yPoly1(:);
xPoly2 = xPoly2(:);
yPoly2 = yPoly2(:);

d = inf;
xPoly1Closest = [];
yPoly1Closest = [];
xPoly2Closest = [];
yPoly2Closest = [];

%check if polygons intersect by checking all segments;
%use the notation from http://local.wasp.uwa.edu.au/~pbourke/geometry/lineline2d/
for i1=1:(length(xPoly1)-1)
    for i2=1:(length(xPoly2)-1)
        x1 = xPoly1(i1);
        x2 = xPoly1(i1+1);
        y1 = yPoly1(i1);
        y2 = yPoly1(i1+1);
        x3 = xPoly2(i2);
        x4 = xPoly2(i2+1);
        y3 = yPoly2(i2);
        y4 = yPoly2(i2+1);
        
        uaNumerator  = (x4-x3)*(y1-y3)-(y4-y3)*(x1-x3);
        ubNumerator  = (x2-x1)*(y1-y3)-(y2-y1)*(x1-x3);
        uDenominator = (y4-y3)*(x2-x1)-(x4-x3)*(y2-y1);
        
        if (uDenominator ~= 0)
            %lines are not parallel
            ua = uaNumerator/uDenominator;
            ub = ubNumerator/uDenominator;
            if (0<=ua) && (ua<=1) && (0<=ub) && (ub<=1)
                %segments intersect
                d = 0;
                xPoly1Closest = [xPoly1Closest ; x1+ua*(x2-x1)];
                yPoly1Closest = [yPoly1Closest ; y1+ua*(y2-y1)];
                xPoly2Closest = [xPoly2Closest ; x1+ua*(x2-x1)];
                yPoly2Closest = [yPoly2Closest ; y1+ua*(y2-y1)];
            end
        end
    end
end

if d==0
    return
end

%no intersection has been found; find min distance!
for i1=1:length(xPoly1)
    xPoint = xPoly1(i1);
    yPoint = yPoly1(i1);
    [dTemp,xPolyClosestTemp,yPolyClosestTemp] = spanPointPolyDist_modified(xPoint, yPoint, xPoly2, yPoly2);
    if dTemp < d
        %overwrite closest point
        d=dTemp;
        xPoly1Closest = xPoint;
        yPoly1Closest = yPoint;
        xPoly2Closest = xPolyClosestTemp;
        yPoly2Closest = yPolyClosestTemp;
    elseif dTemp == d
        %append another equally close point to the list of closest points
        xPoly1Closest = [xPoly1Closest ; xPoint];
        yPoly1Closest = [yPoly1Closest ; yPoint];
        xPoly2Closest = [xPoly2Closest ; xPolyClosestTemp];
        yPoly2Closest = [yPoly2Closest ; yPolyClosestTemp];
    end
end
for i2=1:length(xPoly2)
    xPoint = xPoly2(i2);
    yPoint = yPoly2(i2);
    [dTemp,xPolyClosestTemp,yPolyClosestTemp] = spanPointPolyDist_modified(xPoint, yPoint, xPoly1, yPoly1);
    if dTemp < d
        %overwrite closest point
        d=dTemp;
        xPoly1Closest = xPolyClosestTemp;
        yPoly1Closest = yPolyClosestTemp;
        xPoly2Closest = xPoint;
        yPoly2Closest = yPoint;
    elseif dTemp == d
        %append another equally close point to the list of closest points
        xPoly1Closest = [xPoly1Closest ; xPolyClosestTemp];
        yPoly1Closest = [yPoly1Closest ; yPolyClosestTemp];
        xPoly2Closest = [xPoly2Closest ; xPoint];
        yPoly2Closest = [yPoly2Closest ; yPoint];
    end
end

return