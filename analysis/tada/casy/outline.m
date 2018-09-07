% Prepare upper and lower vocal tract outlines, etc.

% Copyright Haskins Laboratories, Inc., 2001-2003
% 270 Crown Street, New Haven, CT 06514, USA
% programmer Yuriy Koblents-Mishke
% e-mail koblents@haskins.yale.edu

function outline

pts % include pts.m - list of global for data 


Fix = [ 
 FIX_Larynx
 FIX_Periarytenoid
 FIX_PharynxLo
 FIX_PharynxHi
 FIX_Velum
 FIX_VelMax
 FIX_Maxilla
 FIX_Alveolus
 FIX_Teeth
 FIX_TeethLip
 FIX_Lip
 FIX_Terminus 
];

Var = [
 VAR_Larynx
 VAR_LarEpi
 VAR_Epiglottis
 VAR_Hyoid
 VAR_Root
 VAR_RootTong
 VAR_TongBlade
 VAR_BladeTip
 VAR_TipFloor
 VAR_Floor
 VAR_FloorTeeth
 VAR_Teeth
 VAR_TeethLip
 VAR_Lip
 VAR_Terminus 
];


global KeyPts
global GeoPts

KeyPts = struct( ...
  'coords', { FIX_Lip( 1:2 ), ...          % KEY_FixLip
              VAR_Lip( 1:2 ), ...          % KEY_VarLip 
              CMP_TongueCircle( 1:2 ), ... % KEY_TongueCircle 
              VAR_RootTong( 1:2 ), ...     % KEY_TongueCircleRad 
              VAR_Teeth( 1:2 ), ...        % KEY_Jaw 
              CMP_TipCircle( 1:2 ), ...    % KEY_TipCircle 
              VAR_TongBlade( 1:2 ), ...    % KEY_BladeOriginOffset 
              VAR_Root( 1:2 ), ...         % KEY_RootOffset 
              VAR_Hyoid( 1:2 ), ...        % KEY_Hyoid 
              CMP_Velum( 1:2 ) ...         % KEY_Nasal  
            }, ...         
'Tags', { 'FixLip           ', 'VarLip           ', 'TongueCircle     ', ...
          'TongueCircleRad  ', 'Jaw              ', 'TipCircle        ', ...
          'BladeOriginOffset', 'RootOffset       ', 'Hyoid            ', ... 
          'Nasal            ' } );
  

GeoPts = struct( ...
   'coords', { FIX_Terminus( 1:2 ), ...		% GEO_FixTerminus 
               VAR_Terminus( 1:2 ), ...		% GEO_VarTerminus 
               GEO_Velum( 1:2 ), ...		% GEO_Velum 
               VAR_Epiglottis( 1:2 ), ...   % GEO_Hyoid2Epi 
               VAR_LarEpi( 1:2 ), ...       % GEO_Hyoid2LarEpiY 
               VAR_Larynx( 1:2 ), ...       % GEO_Hyoid2LarynxY 
               VAR_FloorTeeth( 1:2 ), ...   % GEO_Teeth2FloorTeeth 
               FIX_TeethLip( 1:2 ), ...     % GEO_FixTeeth2TeethLip 
               VAR_TeethLip( 1:2 ), ...     % GEO_VarTeeth2TeethLip 
               VAR_Floor( 1:2 ), ...        % GEO_Teeth2FloorX 
               VAR_BladeTip( 1:2 ) ...      % GEO_TipCircleRad 
            }, ...         
'Tags', { 'FixTerminus', 'VarTerminus', 'Velum', 'Hyoid2Epi', ...
          'Hyoid2LarEpiY', 'Hyoid2LarynxY', 'Teeth2FloorTeeth', ...
          'FixTeeth2TeethLip', 'VarTeeth2TeethLip', 'Teeth2FloorX', ...
          'TipCircleRad' } );               


% outlines for plotting
global UpperOutline
global BottomOutline 

% outlines for grids 
global gridUpperOutline
global gridBottomOutline



global SEG_Bezier_fix_Velum_VelMax
global SEG_Bezier_fix_VelMax_Maxilla
global SEG_Bezier_fix_Maxilla_Alveolus


UpperOutline =  [ 
 FIX_Larynx
 FIX_Periarytenoid
 FIX_PharynxLo
 FIX_PharynxHi
 FIX_Velum
 BezierSegment( [ FIX_Velum(1:2); FIX_VelMax(1:2) ], ...
                 SEG_Bezier_fix_Velum_VelMax, 16 )
 FIX_VelMax
 BezierSegment( [ FIX_VelMax(1:2); FIX_Maxilla(1:2) ], ...
                 SEG_Bezier_fix_VelMax_Maxilla, 16 )
 FIX_Maxilla
 BezierSegment( [ FIX_Maxilla(1:2); FIX_Alveolus(1:2) ], ...
                 SEG_Bezier_fix_Maxilla_Alveolus, 16 )
 FIX_Alveolus
 FIX_Teeth
 FIX_TeethLip
 FIX_Lip
 FIX_Terminus 
];


gridUpperOutline = UpperOutline';


% in (original) MCASY:

% /* ***  special case: make straight line between Velum:VelMax  *** */
% /*	(i.e. ignore pendulus uvula)				   */
%    straight_seg( & SEG_FIX_Velum_VelMax );
%    compute_segs( & SEG_FIX_Velum_VelMax );

% very questionable: possible straight line over Velum, 
% from FIX_PharynxHi to FIX_VelMax ????





% skip point in outline?
if VAR_TipFloor(2) > VAR_BladeTip(2) && VAR_BladeTip(1) > CMP_TipCircle(1)
  seg1 = [];
else
  seg1 = [ VAR_TipFloor ]; 
end

if VAR_Floor(1) >= VAR_Teeth(1) || VAR_Floor(1) > VAR_FloorTeeth(1)
  seg2 = [];          
else
  seg2 = [ VAR_FloorTeeth ];
end



% including curved segments
if isempty( seg1 )
     seg1a = [];
else
  seg1a =  circularSegment( CMP_TipCircle(1:2), ...
                       [ VAR_BladeTip(1:2); VAR_TipFloor(1:2) ], ... 
		       GEO_TipCircleRad(3), 16 );
end

% /* ***  special case: clip VAR_Epiglottis.coord.y to VAR_Hyoid.coord.y  *** */
%   if( VAR_Epiglottis.coord.y > VAR_Hyoid.coord.y ) 
%   {
%     VAR_Epiglottis.coord.y = VAR_Hyoid.coord.y;
%     straight_seg( & SEG_VAR_LarEpi_Epiglottis );
%     straight_seg( & SEG_VAR_Epiglottis_Hyoid  );
%     compute_segs( & SEG_VAR_LarEpi_Epiglottis );
%     compute_segs( & SEG_VAR_Epiglottis_Hyoid  );


% instead of VAR_Epiglottis in BottomOutline
point = VAR_Epiglottis;
if( point(2) > VAR_Hyoid(2) )
  point(2) = VAR_Hyoid(2);
end



BottomOutline =  [
  VAR_Larynx
  VAR_LarEpi
  VAR_Epiglottis
  VAR_Hyoid
  VAR_Root
  VAR_RootTong
%    circPoints( 
  circularSegment( CMP_TongueCircle(1:2), ...
                [ VAR_RootTong(1:2); VAR_TongBlade(1:2) ], ... 
	        KEY_TongueCircleRad(3), 16 )

  VAR_TongBlade
  circularSegment( CMP_BladeCircle(1:2), ...
             [ VAR_TongBlade(1:2); VAR_BladeTip(1:2) ], ... 
	      abs( CMP_BladeCircleRad(3)), 16 ) 
  VAR_BladeTip
  seg1a
  seg1
  VAR_Floor
  seg2
  VAR_Teeth
  VAR_TeethLip
  VAR_Lip
  VAR_Terminus 
];


gridBottomOutline = BottomOutline';


function intermedPts = circPoints( center, arc, radius, number )

     number = number+1;

     relCoord = arc - repmat( center, 2, 1 );
     angle = atan2( relCoord(:,2), relCoord(:,1) );

     % the outline direction is clockwise 
     % if( angle(1) < angle(2) )
     %   angle(1) = angle(1) + 2*pi;
     % end


     % the outline arc is less than 180 degrees
     while angle(2) > angle(1) + pi 
       angle(2) = angle(2) - 2*pi;
     end 
     while angle(2) < angle(1) - pi
       angle(2) = angle(2) + 2*pi;
     end 

     
     step = ( ( angle(2) - angle(1) ) ) / number;


     intermedAng = angle(1) : step : angle(2);
     intermedAng = intermedAng( 2 : number );

  
     intermedPts = repmat( center, length( intermedAng ), 1 ) + ...
                    [ cos( intermedAng' ) sin( intermedAng' ) ] * radius;
  



function pts_out = circularSegment( center, arc, radius, number ) 

  pts_in = circPoints( center(1:2), arc, radius, 2 );
  pts_out = cubicFit( [ arc(1,:); pts_in; arc(2,:) ], number );

function pts_out = BezierSegment( arc, controls, number )

  poly = BezierToCubic( [arc(1,:); controls; arc(2,:) ] );
  interval = [1:number-1]'/number;
  pts_out = [ polyval( poly(1,:), interval ), polyval( poly(2,:), interval )];


function pts_out = cubicFit( in, number ) 

  interval = [0:3]'/3;
  poly = [ polyfit( interval, in(:,1), 3 ); polyfit( interval, in(:,2), 3 )];

  interval = [1:number-1]'/number;
  pts_out = [ polyval( poly(1,:), interval ), polyval( poly(2,:), interval )];



function points = cubicToBezier( polyCoef )

% #1,4 - endpoints, #2,3 - control points.

  points(1) = polyCoef(4);
  points(2) = points(1) + polyCoef(3) / 3;
  points(3) = points(2) + ( polyCoef(3) + polyCoef(2) ) / 3;
  points(4) = points(2) + polyCoef(3) + polyCoef(2 )+ polyCoef(1);


function polyCoef = BezierToCubic( points )

% #1,4 - endpoints, #2,3 - control points.

  polyCoef(:,4) = points(1,:)';
  polyCoef(:,3) = 3 * ( points(2,:) - points(1,:) )';
  polyCoef(:,2) = 3 * ( points(3,:) - points(2,:) )' - polyCoef(:,3);
  polyCoef(:,1) = (points(4,:) - points(1,:))' - polyCoef(:,3) - polyCoef(:,2);
