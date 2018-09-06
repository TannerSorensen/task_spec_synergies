% area of cross-sections of vocal tract 

function area

% Copyright Haskins Laboratories, Inc., 2001-2003
% 270 Crown Street, New Haven, CT 06514, USA
% programmer Yuriy Koblents-Mishke
% e-mail koblents@haskins.yale.edu

pts % include pts.m - list of global for data 


global gridLines % are they really needed here?
global trsd

if isempty( gridLines ) || isempty( trsd )
  return
end

global crossArea
crossArea = [];


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

% debug
% if ~isreal( crossArea )
%   [1:length(trsd); trsd'; crossArea]'
% end
