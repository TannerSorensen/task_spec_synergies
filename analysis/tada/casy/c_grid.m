% grid, midline, area building

function c_grid

% Copyright Haskins Laboratories, Inc., 2001-2003
% 270 Crown Street, New Haven, CT 06514, USA
% programmer Yuriy Koblents-Mishke
% e-mail koblents@haskins.yale.edu

global TUN_GridCenter 

global FIX_Larynx
global FIX_Periarytenoid
global FIX_PharynxLo
global FIX_PharynxHi
global FIX_Velum
global FIX_VelMax
global FIX_Maxilla
global FIX_Alveolus
global FIX_Teeth
global FIX_TeethLip
global FIX_Lip
global FIX_Terminus 

global VAR_Epiglottis

global VAR_Larynx
global VAR_LarEpi
global VAR_Hyoid
global VAR_Root
global VAR_RootTong
global VAR_TongBlade
global VAR_BladeTip
global seg1
global VAR_Floor
global seg2
global VAR_Teeth
global VAR_TeethLip
global VAR_Lip
global VAR_Terminus 



global gridErr
gridErr = [];

x=1; % self-explaining constants
y=2;
 

step = 5/2; % in mm - step between horisontal or/and vertical gridlines
stepAng = pi / 2 / 18;  % step between angular gridlines (in radians)


% the first horisonal gridlines - than up in vertical direction
s0 = max( VAR_Larynx(y), FIX_Larynx(y) );
s1 = TUN_GridCenter(y);

% 1-st group of gridlines - horisontal ones 
gridFree1(y,:) = s0 : step : s1;
gridFree1(x,:) = TUN_GridCenter(x);

% gridCoef(i) * intersection = gridCoef(i) * gridFree(i)
gridCoef1 = repmat( [0 1], size(gridFree1, 2), 1 ); % coeffs perpendicular to ray 
gridAngle1(1: size(gridFree1, 2) ) = pi;


% 2-nd group of gridlines - angular gridlines
gridAngle2 = pi: -stepAng : pi/2;
gridCoef2 = [ sin(gridAngle2)' -cos(gridAngle2)'];
gridFree2 = repmat( TUN_GridCenter',  size(gridAngle2) );


% 3-rd group of gridlines, vertical gridlines

% termination of acoustic tube
s1 = max( [ min( [ VAR_TeethLip(x) FIX_TeethLip(x) ... 
                   0.5*(VAR_TeethLip(x) + FIX_TeethLip(x) - FIX_TeethLip(y) + VAR_TeethLip(y) ) ...
                 ] ) ...
            min( [ VAR_Terminus(x) FIX_Terminus(x) ... 
                   0.5*(VAR_Terminus(x) + FIX_Terminus(x) - FIX_Terminus(y) + VAR_Terminus(y) ) ...
                 ] )
         ] );
         
s0 = TUN_GridCenter(x);

gridFree3(x,:) = TUN_GridCenter(x)+step : step : s1;
gridFree3(y,:)  = TUN_GridCenter(y);
gridAngle3(1: size(gridFree3,2)) = pi/2;
gridCoef3 = repmat( [1 0], size(gridFree3,2), 1 );


% merge the 3 groups of gridlines
gridFree = [ gridFree1 gridFree2 gridFree3 ];
gridCoef = [ gridCoef1; gridCoef2; gridCoef3 ];
gridAngle = [ gridAngle1 gridAngle2 gridAngle3 ];



% outlines for grids 
global gridUpperOutline
global gridBottomOutline


gridUpperOutlineDelta = diff( gridUpperOutline, 1, 2 );
gridBottomOutlineDelta = diff( gridBottomOutline, 1, 2 );

gridUpperOutlineCoef = [ gridUpperOutlineDelta(y,:); -gridUpperOutlineDelta(x,:) ]';
gridBottomOutlineCoef = [ gridBottomOutlineDelta(y,:); -gridBottomOutlineDelta(x,:) ]';


% self-explaining values
Bottom = 1;
Upper  = 2;                 

global gridLines

gridLines = [];

right = dot( gridCoef, gridFree', 2 );

sideValue1 = gridCoef * gridBottomOutline;
sideValue2 = gridCoef * gridUpperOutline;

%m = find( m0 > right )

side01 = 1;
side02 = 1;
for i=1:length(gridFree)
  side1 = find( sideValue1(i,:) > right(i) ); %  higher / to right from gridline i 
  side2 = find( sideValue2(i,:) > right(i) );
  
  side1 = side1( side1 > side01 );
  side2 = side2( side2 > side02 );
       
  if isempty( side1 )  
    gridErr = [ 1 side01 ]
    break
  elseif isempty( side2 ) 
    gridErr = [ 2 side02 ]
    break
  else
    side01 = side1(1)-1;
    side02 = side2(1)-1;
  
    gridLines(i,:,Bottom) = [ gridCoef(i,:); gridBottomOutlineCoef(side01,:) ] \ ...
      [ right(i); gridBottomOutlineCoef(side01,:)*gridBottomOutline(:,side01 ) ];
	
    gridLines(i,:,Upper ) = [ gridCoef(i,:); gridUpperOutlineCoef(side02,:) ] \ ...
      [ right(i); gridUpperOutlineCoef(side02,:)*gridUpperOutline(:,side02 ) ]; 
  end

end

% the both outlines must be to left and above of  TUN_GridCenter
if isempty( gridErr )
 angIndex = gridFree(x,:) == TUN_GridCenter(x) & ...
            gridFree(y,:) == TUN_GridCenter(y);% gridline  from center
 vectAng = gridLines( angIndex, :, : );
 vectAng = vectAng - repmat( TUN_GridCenter, [ size( vectAng, 1) 1 2 ] );
 errAngIndex = vectAng( :, 2, : ) - vectAng( :, 1, : ) < eps;
 
 if ~isempty( find( errAngIndex ) ) 
   gridErr = [ 3, find( errAngIndex )' ];  
 end
              
  
end
 
                       
                        
%  cross section / width
global crossSection
global crossArea
global area
global tubeLength
global midPoints
global tubeLengthGeometric
global tubeLengthSmooth;


crossSection = [];
crossArea = [];
area = [];
tubeLength = [];
midPoints = [];
tubeLengthGeometric = [];
tubeLengthSmooth = [];


if ~ isempty( gridErr )
  trsd = [];
  return
end

gridDelta = diff( gridLines, 1, 3 );
  
gridLen = sqrt( gridDelta(:,1).^2 + gridDelta(:,2).^2 ) .* ...
    ( gridDelta(:,2) >= -0.0001 & gridDelta(:,1) <= 0.0001 );

% ( gridDelta(:,2) >= 0 & gridDelta(:,1) <= 0 ); % fixed by Hosung 11/05/06
% because of precision problem

gridOutlineDelta = diff( gridLines, 1, 1 ); 

outlineAngle = squeeze( atan2( gridOutlineDelta( :,y,: ), gridOutlineDelta(:,x,:) ) );


gridToOutlineAngle = repmat( gridAngle(2:end)', 1, 2) - outlineAngle;
sth = sin( gridToOutlineAngle );


s = gridLen(2:end) .* sth( :,Bottom ) ./ sum( sth,2 );
outlineAngleDiff = diff( outlineAngle, 1, 2 );
choad = cos( 0.5 * outlineAngleDiff );

trsd = max( 0, 2.0 * s .* sth( :,Upper ) ./ choad ); % not negative



% above is "classical" trsd; following adjustments are available

thm = mean( outlineAngle, 2);
midPoints = squeeze( mean( cat( 3, ...
                             gridLines(1:end-1,:,Upper), ...
                             gridLines(2:end, :, Upper), ...
                             gridLines(1:end-1,:,Bottom), ...
                             gridLines(2:end,:,Bottom) ...
                    ), 3 ))';


% if outline intersects, i.i. trsd == 0 
% centroid is midpoint of line connecting 	     
% intersections of cur, prev gridlines with posterior outline


% ?????
% if trsd == 0
%   midPoints = squeeze( mean( cat( 3, ...
%                              gridLines(1:end-1,:,Upper), ...
%                              gridLines(2:end, :, Upper) ...
%                     ), 3 ))';
% else
%   cxy = gridLines(2:end, :, Upper) - ...
%            [cos(gridAngle(2:end))'.*s sin(gridAngle(2:end))'.*s];
% 
%   % pq: distance between centroid and midline along revised trsd
%   pq = dot( [ sin( thm ) -cos( thm ) ], cxy  - midPoints', 2 );
% 
%   
% %   % sh: distance along midline between old, new trsds
%   sh = sqrt( sum( ( cxy  - midPoints').^2, 2 ) - pq.^2 );
% 
%   trsd = max( 0, trsd - sh .* tan( 0.5 * outlineAngleDiff ) );
%   % using tan(x+pi/2) = -1/tan(x);
%   % originally equivalent of
%   % trsd - sh /* tan( 0.5 * outlineAngleDiff + pi/2 )
% end


idxZero0 = find( trsd == 0 );
idxZero1 = idxZero0 + 1;

idxNZero0 = find( trsd ); % i.e. trsd != 0
idxNZero1 = idxNZero0 + 1;

midPoints(:,idxZero0) = squeeze( mean( cat( 3, ...
                             gridLines( idxZero0, :, Upper ), ...
                             gridLines( idxZero1, :, Bottom )  ...
                    ), 3 ))';
                
% There used to be a bug (fixed by Hosung Nam, Upper -> Bottom in c_grid.m and cross.m)               
% midPoints(:,idxZero0) = squeeze( mean( cat( 3, ...
%                              gridLines( idxZero0, :, Upper ), ...
%                              gridLines( idxZero1, :, Upper )  ...
%                     ), 3 ))';


cxy = gridLines(idxNZero1, :, Upper) - ...
           [ cos(gridAngle(idxNZero1))'.*s(idxNZero0) ...
             sin(gridAngle(idxNZero1))'.*s(idxNZero0) ];


% pq: distance between centroid and midline along revised trsd
pq = dot( [ sin( thm(idxNZero0) ) -cos( thm(idxNZero0) ) ], ...
                         cxy  - midPoints(:,idxNZero0)', 2 );

  
% sh: distance along midline between old, new trsds
sh = sqrt( sum( ( cxy - midPoints(:,idxNZero0)').^2, 2 ) ...
                      - pq.^2 );
trsd(idxNZero0) = max( 0, trsd(idxNZero0) - ...
                            sh .* tan( 0.5 * outlineAngleDiff(idxNZero0) ) );
  % using tan(x+pi/2) = -1/tan(x);
  % originally equivalent of
  % trsd - sh /* tan( 0.5 * outlineAngleDiff + pi/2 )
%  end


% cross-sections
% index: ( number, x=1/y=2 )


crossSection = [ -sin(thm) .* trsd,   cos(thm) .* trsd ];  % rotation 90 degree



% calculations of cross-section area depends on region of vocal tract

% auxiliary variables
RootHy = 0.75 * VAR_Root(2) + 0.25 * VAR_Hyoid(2);
xt = min( VAR_TeethLip(1), FIX_Terminus(1) );
xt = min( xt, ...
          0.5 * ( VAR_Terminus(1) + FIX_Terminus(1) - ...
                  FIX_Terminus(2) + VAR_Terminus(2) ) );

% reminder: gridLines( number, x=1/y=2, var=1/fix=2 )

regionGLOTTIS = ( gridLines( 2:end, 2, 2 ) < FIX_Periarytenoid(2) );
regionTemp = regionGLOTTIS;
regionPERI    = ~ regionTemp & ( gridLines( 2:end, 2, 1 ) < VAR_Hyoid(2) );
regionTemp = regionTemp | regionPERI;
regionHYOID   = ~ regionTemp & ( gridLines( 2:end, 2, 1 )  < RootHy );
regionTemp = regionTemp | regionHYOID;
regionROOTHY  = ~ regionTemp & ( gridLines( 1:end-1, 2, 2 ) <  FIX_VelMax(2) );
% !!! error - the region includes the last sections, must be lips
regionTemp = regionTemp | regionROOTHY;
regionVELMAX  = ~ regionTemp & ( gridLines( 2:end, 1, 2 )   <   FIX_Maxilla(1) );
regionTemp = regionTemp | regionVELMAX;
regionMAXILLA = ~ regionTemp & ( gridLines( 2:end, 1, 2 )   <   FIX_Alveolus(1) );
regionTemp = regionTemp | regionMAXILLA;
regionALVEOLUS = ~ regionTemp & ( gridLines( 2:end, 1, 2 )  <= xt );
regionTemp = regionTemp | regionALVEOLUS;
regionLIPS = ~ regionTemp; 
% !!! error - regionLIPS is always empty


% !!!! verify the last sections - must be lips, but hyoid?

global TUN_PharAdjGlot
global TUN_PharAdjPeri 
global TUN_PharAdjHyoid
global TUN_PharAdjRoot
global TUN_SoftPalate
global TUN_HardPalate

twiddle( regionGLOTTIS ) = TUN_PharAdjGlot(4); % map pharyngeal adjustment params 
twiddle( regionPERI    ) = TUN_PharAdjPeri(4); %index 4 == TPARAM scale
twiddle( regionHYOID   ) = TUN_PharAdjHyoid(4);
twiddle( regionROOTHY  ) = TUN_PharAdjRoot(4);
twiddle( regionVELMAX  ) = TUN_SoftPalate(4);
twiddle( regionMAXILLA ) = TUN_HardPalate(4);

regionTemp = regionGLOTTIS | regionPERI | regionHYOID | regionROOTHY;

crossArea( regionTemp ) = ...
    pi/4 * twiddle( regionTemp )' .* trsd( regionTemp ) ...
                       .* min( 10, trsd( regionTemp )); %forced not wider than 1 cm


regionTemp = regionVELMAX | regionMAXILLA;

crossArea( regionTemp ) = pi/4 * twiddle( regionTemp )' .* trsd( regionTemp ) .^1.5;

global TUN_AlvNarrow
global TUN_AlvMid
global TUN_AlvWide

% TUN_AlvNarrow, TUN_AlvMid, TUN_AlvWide: TPARAM
% index 1:4 maps respectively
% minx.min, minx.max, osl.offset, osl.scale 


regionAlvNarrow = regionALVEOLUS & trsd <= TUN_AlvNarrow(1);
regionalvMid    = regionALVEOLUS & ~regionAlvNarrow & trsd <= TUN_AlvMid(1); 
regionAlvWide   = regionALVEOLUS & ~( regionAlvNarrow | regionalvMid );

crossArea( regionAlvNarrow) = TUN_AlvNarrow(3) + ...
    TUN_AlvNarrow(4) * trsd( regionAlvNarrow );
crossArea( regionalvMid ) = TUN_AlvMid(3) + ...
    TUN_AlvMid(4) * ( trsd( regionalvMid ) - TUN_AlvNarrow(1) );
crossArea( regionAlvWide ) = TUN_AlvWide(3) + ...
    TUN_AlvWide(4) * ( trsd( regionAlvWide ) - TUN_AlvMid(1) );

% /* ***  plip: lip protrusion beyond maxilla (cm)  *** */
% 
%   plip = ( GRIDC[NGL-1].var.x - VAR_TeethLip.coord.x ) * invMpc;
% 
% /* ***  hlip: vertical lip separation (cm)  *** */
% 
%   hlip = MAX( ( FIX_Terminus.coord.y - VAR_Terminus.coord.y ) * invMpc, 0.01 );
% 
% /* ***  wlip: horizontal width in frontal plane  *** */
% /*	width decreases as lip protrusion increases  */
% 
%   wlip = MAX( TUN_LipWidth.polar.len + 
%                  TUN_LipWidth.polar.ang * ( hlip - plip ), 
%               WLIPMN );

global TUN_LipWidth

plip = gridLines( end, 1, 1 ) - VAR_TeethLip(1);
hlip = FIX_Terminus(2) - VAR_Terminus(2);
hlip = max( hlip, 0.1 ); % 0.1 mm - to avoid zeros
wlip = TUN_LipWidth(3) + TUN_LipWidth(4)*( hlip - plip );
wlip = max( wlip, 10 ); % at least 1 cm enforced 

crossArea( regionLIPS ) = pi/4 * wlip * trsd( regionLIPS );

if ~isreal( crossArea )
  [1:length(trsd); trsd'; crossArea]'
end


% calculations for area, equidistant along vocal tube 
% involve logarithmic interpolation 

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
tubeLengthSmooth = areaStep * [1: tubeLengthGeometric(end) / areaStep + 2];

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

global areaIterpolated
areaIterpolated = exp( logAreaSmooth )*100;

area(end+1) = crossAreaExt(end);
tubeLengthSmooth(end+1) = tubeLengthSmooth(end) + areaStep;

% acoustics
global bandwidths
global formantFreq

tubeLength = tubeLengthSmooth;

% commented by HN... 7/20/2004 to increase speed
%[formantFreq, bandwidths] = tubeResonances( 0.01*area, 0.1*tubeLength(end) ); % mm to cm


%bandwidths = getBandwidths( formantFreq ); % July 03, 2003

%global soundDuration % seconds 
%global sampPerSec % samples per second
%global SRC_F0 % fundamental frequency, in Hz, usually 100 Hz.%

%global waveAmplitude
%global waveTime % sample timing in ms.

%global freq
%global magnitude

% [waveAmplitude, waveTime, freq, magnitude ] = ...
%   syn_buzz( sampPerSec, formantFreq, bandwidths, SRC_F0, soundDuration );
% 
% maxfreq = 5000;
% indexFreq = freq <= maxfreq;
% magnitude = magnitude( indexFreq );
% freq = freq( indexFreq );

