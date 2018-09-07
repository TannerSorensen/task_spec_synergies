function smoothArea

% Copyright Haskins Laboratories, Inc., 2001-2003
% 270 Crown Street, New Haven, CT 06514, USA
% programmer Yuriy Koblents-Mishke
% e-mail koblents@haskins.yale.edu


% calculations for area, equidistant along vocal tube 
% involve logarithmic interpolation 

global gridLines
global midPoints
global crossArea

global tubeLengthGeometric
global tubeLengthSmooth;

global area
global areaIterpolated


tubeLengthGeometric = [];
tubeLengthSmooth = [];
area = [];
areaIterpolated = [];

if isempty( gridLines ) ||  isempty( midPoints ) ||  isempty( crossArea )
  return
end

% length of tube
difference = [ midPoints( :, 1) - mean( gridLines(1,:,:), 3 )' ... 
            diff( midPoints, 1, 2 ) ];

for i = 1:size(difference,2)
  nrm(i) = norm( squeeze( difference(:,i) ) );
end

tubeLengthGeometric = cumsum( nrm ); %len(i) = sum( nrm(j<=i) )



areaStep = 8.75; % mm or 0.875 cm
minArea = 0.1; % very small value


% equidistant
%tubeLengthSmooth = areaStep * [1: tubeLengthGeometric(end) / areaStep + 2];
% modified by Hosung Nam, HN (070702), to avoid nonlinear jumping in smoothed area function.
tubeLengthSmooth = areaStep * [1: round(tubeLengthGeometric(end) / areaStep) + 2];

% last "section" - extrapolation "along parabolic horn"
lastCrossArea = max( crossArea(end), minArea ); % forced limit on lip section
finalArea = minArea + ( lastCrossArea - minArea ) * (1 + ...
                 ( tubeLengthSmooth(end) - tubeLengthGeometric(end) ) / ...
                   sqrt( lastCrossArea / pi) ...
                                                     )^2;

crossAreaExt = [crossArea  finalArea];
tubeLengthGeometricExt = [ tubeLengthGeometric tubeLengthSmooth(end) ];

% prepare log interpolation 
% logAreaGeometric = log( max( crossAreaExt, minArea ) );
logAreaGeometric = log( max( crossAreaExt, minArea ) / 100  ); %mm to cm

% the interpolation
%logAreaSmooth = [ interp1( tubeLengthGeometricExt, logAreaGeometric, ...
%                           tubeLengthSmooth(1:end-1) ) ...
%                           logAreaGeometric(end) ];
logAreaSmooth = [ interp1( tubeLengthGeometricExt/10, logAreaGeometric, ...
                           tubeLengthSmooth(1:end-1)/10 ) ...
                           logAreaGeometric(end) ]; %mm to cm

% merge
%[tubeLengthMerge, indexTubeLength] = sort( [ tubeLengthGeometricExt tubeLengthSmooth ] );
[tubeLengthMerge, indexTubeLength] = sort( [ tubeLengthGeometricExt tubeLengthSmooth ] / 10 ); %mm to cm
% distances
distanceMerge = diff( tubeLengthMerge, 1, 2 ); 

logAreaMerge = [ logAreaGeometric  logAreaSmooth ];
logAreaMerge = logAreaMerge( indexTubeLength );

% integration
%AS = cumtrapz( tubeLengthMerge, logAreaMerge ) / areaStep;
%ASUM = cumtrapz( tubeLengthMerge, AS ) / areaStep;
AS = cumtrapz( tubeLengthMerge, logAreaMerge ) / (areaStep/10); % mm to cm
ASUM = cumtrapz( tubeLengthMerge, AS ) / (areaStep/10); % mm to cm

% in the equidistant points
APSUM = ASUM( indexTubeLength > length( tubeLengthGeometricExt ) );

% convolute with [-1 1 1 -1] and integrate
AINT = [ -1.5 * logAreaGeometric(1),  -0.5 * logAreaGeometric(1), APSUM(1), ...
         diff( APSUM ),  0.5*logAreaGeometric(end-1) + AS(end) ];

% [ 1:length( AINT ); AINT ]'

AFIL = filter( 0.5*[1 -1 -1 1 ], [1], AINT );
AFIL = cumsum( AFIL(4:end) );


%area = max( exp( 0.75 * logAreaMerge(1) + 0.5 * AINT(3) + AFIL ), minArea );
area = max( exp( 0.75 * logAreaMerge(1) + 0.5 * AINT(3) + AFIL )*100, minArea ); %mm to cm

areaIterpolated = exp( logAreaSmooth )*100;

area(end+1) = crossAreaExt(end);
tubeLengthSmooth(end+1) = tubeLengthSmooth(end) + areaStep;
