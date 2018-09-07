% the head program is calling other m-files

% Copyright Haskins Laboratories, Inc., 2001-2004
% 270 Crown Street, New Haven, CT 06514, USA
% programmer Yuriy Koblents-Mishke
% e-mail koblents@haskins.yale.edu

function casy( script_name )

init

if nargin < 1 
  script_name = 'default.par';
end


dr = dir( fullfile( pwd, script_name ) ); % search in working directory
if ~isempty( dr ) && dr.isdir == 0
  readpar( script_name ) 
else  % search in the program directory, where 'casy.m' is stored  
  script_name = fullfile( fileparts( mfilename( 'fullpath' ) ), script_name );
  dr = dir( script_name );
  if ~isempty( dr ) && dr.isdir == 0
    readpar( script_name ) 
  else 
    if nargin >= 1
       msgbox( ['Cannot find script file ' script_name], 'Error in Startup Parameters', 'warn' );
    end
  end
end

refresh_HL
buttonUp

