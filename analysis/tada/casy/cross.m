% cross-sections of vocal tract

function cross

% Copyright Haskins Laboratories, Inc., 2001-2003
% 270 Crown Street, New Haven, CT 06514, USA
% programmer Yuriy Koblents-Mishke
% e-mail koblents@haskins.yale.edu

global  gridLines
global gridAngle % is it really needed?

global crossSection
global tubeLength
global midPoints
global trsd


x=1; % self-explaining constants for x, y coordinates
y=2;

% self-explaining values for outlines
Bottom = 1;
Upper  = 2;                 


crossSection = [];
tubeLength = [];
midPoints = [];
trsd = [];

if isempty( gridLines )
  return
end

% debugging
% if ~ isempty( gridErr )
%   trsd = [];
%  return
% end

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

% fix midPoints ASAP!!!!!!!!!!!!!!!!!!!

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

% There used to be a bug (fixed by Hosung Nam, Upper -> Bottom)               
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

