% gridlines for vocal tract

function grid
 
% Copyright Haskins Laboratories, Inc., 2001-2003
% 270 Crown Street, New Haven, CT 06514, USA
% programmer Yuriy Koblents-Mishke
% e-mail koblents@haskins.yale.edu

pts % include pts.m - list of global for data 
    % few of them are used in this function

x=1; % self-explaining constants for x, y coordinates
y=2;

% outlines  
global gridUpperOutline
global gridBottomOutline

% the return values
global gridLines
gridLines = [];



% Is it possible to build sensible gridlines?
% Does the grid center lie below and to the right from vocal tract? 
% If not, return with empty gridline array


step = 2.5; % step between horisontal or/and vertical gridlines, mm
stepAng = pi / 36;  % step between angular gridlines, 5 degrees, in radians
                    % 19 angular gridlines, counting borders

persistent gridAngle2
persistent gridCoef2
if isempty( gridAngle2 )
  gridAngle2 = pi: -stepAng : pi/2;
  gridCoef2 = [ sin(gridAngle2)' -cos(gridAngle2)'];
end



s0 = TUN_GridCenter(y);

% the first horisonal gridlines - than up in vertical direction
s1 = max( VAR_Larynx(y), FIX_Larynx(y) );


% 1-st group of gridlines - horisontal ones 
gridFree1(y,:) = s1 : step : s0;
gridFree1(x,:) = TUN_GridCenter(x);

% gridCoef(i) * intersection = gridCoef(i) * gridFree(i)
gridCoef1 = repmat( [0 1], size(gridFree1, 2), 1 ); % coeffs perpendicular to ray 
gridAngle1(1: size(gridFree1, 2) ) = pi;


% 3-rd group of gridlines, vertical gridlines

s0 = TUN_GridCenter(x);

% termination of acoustic tube
s1 = termination( FIX_TeethLip, VAR_TeethLip, FIX_Terminus, VAR_Terminus );
 
% s1 = max( [ min( [ VAR_TeethLip(x) FIX_TeethLip(x) ... 
%                   0.5*(VAR_TeethLip(x) + FIX_TeethLip(x) - FIX_TeethLip(y) + VAR_TeethLip(y) ) ...
%                 ] ) ...
%            min( [ VAR_Terminus(x) FIX_Terminus(x) ... 
%                   0.5*(VAR_Terminus(x) + FIX_Terminus(x) - FIX_Terminus(y) + VAR_Terminus(y) ) ...
%                 ] )
%         ] );
         


if s1 < s0  % center to right from acoustical tube
  return
end

gridFree3(x,:) = TUN_GridCenter(x)+step : step : s1;
gridFree3(y,:)  = TUN_GridCenter(y);
gridAngle3(1: size(gridFree3,2)) = pi/2;
gridCoef3 = repmat( [1 0], size(gridFree3,2), 1 );


% 2-nd group of gridlines - angular gridlines
 
	
gridFree2 = repmat( TUN_GridCenter',  size(gridAngle2) );


global gridAngle  % is it really needed?

% merge the 3 groups of gridlines
gridFree = [ gridFree1 gridFree2 gridFree3 ];
gridCoef = [ gridCoef1; gridCoef2; gridCoef3 ];
gridAngle = [ gridAngle1 gridAngle2 gridAngle3 ];





gridUpperOutlineDelta = diff( gridUpperOutline, 1, 2 );
gridBottomOutlineDelta = diff( gridBottomOutline, 1, 2 );

gridUpperOutlineCoef = [ gridUpperOutlineDelta(y,:); -gridUpperOutlineDelta(x,:) ]';
gridBottomOutlineCoef = [ gridBottomOutlineDelta(y,:); -gridBottomOutlineDelta(x,:) ]';


% self-explaining values
Bottom = 1;
Upper  = 2;                 

right = dot( gridCoef, gridFree', 2 );

sideValue1 = gridCoef * gridBottomOutline;
sideValue2 = gridCoef * gridUpperOutline;

side01 = 1;
side02 = 1;
for i=1:length(gridFree)
  side1 = find( sideValue1(i,:) > right(i) ); %  higher / to right from gridline i 
  side2 = find( sideValue2(i,:) > right(i) );
  
  side1 = side1( side1 > side01 );
  side2 = side2( side2 > side02 );
       
  side01 = side1(1)-1;
  side02 = side2(1)-1;
  
  gridLines(i,:,Bottom) = [ gridCoef(i,:); gridBottomOutlineCoef(side01,:) ] \ ...
      [ right(i); gridBottomOutlineCoef(side01,:)*gridBottomOutline(:,side01 ) ];
	
  gridLines(i,:,Upper ) = [ gridCoef(i,:); gridUpperOutlineCoef(side02,:) ] \ ...
      [ right(i); gridUpperOutlineCoef(side02,:)*gridUpperOutline(:,side02 ) ]; 

end


function value =  termination1( u, b )
  value = 0.5*(u(1) + b(1) - u(2) + b(2) );


function val = termination0( u, b )
  val = min( [ u(1) b(1) termination1( u, b ) ] ); 


function ret = termination( u1, b1, u2, b2 )
  ret = max( [ termination0( u1, b1 )  termination0( u2, b2 ) ] );
