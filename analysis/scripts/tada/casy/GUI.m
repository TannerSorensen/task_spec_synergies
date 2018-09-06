% managing graphic user interface

% Copyright Haskins Laboratories, Inc., 2001-2004
% 270 Crown Street, New Haven, CT 06514, USA
% programmer Yuriy Koblents-Mishke
% e-mail koblents@haskins.yale.edu

function GUI( numOfWnd )

dfltNumOfWnd = 1; % const

if nargin < 1
  numOfWnd = dfltNumOfWnd;
end

numOfWnd1 = numOfWnd;
if ischar( numOfWnd )
  numOfWnd = str2num( numOfWnd );
end
if isempty( numOfWnd ) || ...
    numOfWnd ~= 1 && numOfWnd ~= 2 && numOfWnd ~= 4
  msgbox( ['Number of Windows must be 1, 2, or 4; ' ...
            '''' numOfWnd1 '''' ...
            ' replaced by ' num2str(dfltNumOfWnd) ], ...
            'Error in GUI argument', 'warn' ); 
  numOfWnd = dfltNumOfWnd;
end


global allAxes

% for 4 windows interface
persistent VTWindow % Vocal Tract
persistent areaWindow % area function
persistent freqWindow % Spectrum
persistent waveWindow % waveform

% for 1 window interface
persistent singleWindow

% for 2 windows interface - vocal tract, and all other
persistent auxiliaryWindow % area, spectrum, and waveform; 

persistent clrMap  % colormap for backgrond IMR image / X-Ray
clrMap = bone(256);

% set contrast and brigtness 
global minBrightness
global maxBrightness
clrMap = clrMap( minBrightness : maxBrightness, : );


% Positions and sizes of windows and axis in windows

if ~isstruct(allAxes) || ~isfield( allAxes, 'singleWindowPos' ) || ...
    isempty( allAxes.singleWindowPos ) 
  allAxes.singleWindowPos =  1/8 * [1 1 -2 -2] + [0 0 1 1];
       % 1/8 from sides of screen
end
 
if ~isstruct(allAxes) || ~isfield( allAxes, 'auxiliaryWindowPos' ) || ...
    isempty( allAxes.auxiliaryWindowPos ) 
  allAxes.auxiliaryWindowPos = [2/3 1/2 1/3-0.05 1/3-0.05];
end
 
if ~isstruct(allAxes) || ~isfield( allAxes, 'waveWindowPos' ) || ...
    isempty( allAxes.waveWindowPos ) 
  allAxes.waveWindowPos = [0.05 3/4+0.05 0.9 1/4-0.1 ];
end

if ~isstruct(allAxes) || ~isfield( allAxes, 'freqWindowPos' ) || ...
    isempty( allAxes.freqWindowPos ) 
  allAxes.freqWindowPos = [2/3+0.05 3/8+0.05 1/3-0.1 3/8-0.1];
end

if ~isstruct(allAxes) || ~isfield( allAxes, 'areaWindowPos' ) || ...
    isempty( allAxes.areaWindowPos ) 
  allAxes.areaWindowPos = [2/3+0.05 0.05 1/3-0.1 3/8-0.1];
end

if ~isstruct(allAxes) || ~isfield( allAxes, 'VTWindowPos' ) || ...
    isempty( allAxes.VTWindowPos ) 
  allAxes.VTWindowPos = [0.05 0.05 2/3-0.1 3/4-0.1];
end

% Positions and sizes of subplots


% for GUI 4; Vocal Tract for GUI 2 too
if ~isstruct(allAxes) || ~isfield( allAxes, 'VTAxesPos4' ) || ...
    isempty( allAxes.VTAxesPos4 ) 
  allAxes.VTAxesPos4 = [0.1 0.1 0.85 0.85 ];
end

if ~isstruct(allAxes) || ~isfield( allAxes, 'areaAxesPos4' ) || ...
    isempty( allAxes.areaAxesPos4 ) 
  allAxes.areaAxesPos4 = [0.1 0.1 0.85 0.85 ];
end

if ~isstruct(allAxes) || ~isfield( allAxes, 'freqAxesPos4' ) || ...
    isempty( allAxes.freqAxesPos4 ) 
  allAxes.freqAxesPos4 = [0.1 0.1 0.85 0.85 ];
end

if ~isstruct(allAxes) || ~isfield( allAxes, 'waveAxesPos4' ) || ...
    isempty( allAxes.waveAxesPos4 ) 
  allAxes.waveAxesPos4 = [0.1 0.2 0.85 0.75 ];
end


% for GUI 2, except Vocal Tract, the same as for GUI 4
if ~isstruct(allAxes) || ~isfield( allAxes, 'areaAxesPos2' ) || ...
    isempty( allAxes.areaAxesPos2 ) 
  allAxes.areaAxesPos2 = [0.1 0.1 1/2-0.1 2/3-0.1 ];
end

if ~isstruct(allAxes) || ~isfield( allAxes, 'freqAxesPos2' ) || ...
    isempty( allAxes.freqAxesPos2 ) 
  allAxes.freqAxesPos2 = [1/2+0.1 0.1 1/2-0.15 2/3-0.1 ];
end

if ~isstruct(allAxes) || ~isfield( allAxes, 'waveAxesPos2' ) || ...
    isempty( allAxes.waveAxesPos2 ) 
  allAxes.waveAxesPos2 = [0.1 2/3+0.1 1-0.15 1/3-0.15 ];
end


% for GUI 1
if ~isstruct(allAxes) || ~isfield( allAxes, 'VTAxesPos1' ) || ...
    isempty( allAxes.VTAxesPos1 ) 
  allAxes.VTAxesPos1 = [0.05 0.05 2/3-0.1 3/4-0.1];
end

if ~isstruct(allAxes) || ~isfield( allAxes, 'areaAxesPos1' ) || ...
    isempty( allAxes.areaAxesPos1 ) 
  allAxes.areaAxesPos1 = [2/3+0.05 0.05 1/3-0.1 3/8-0.1];
end

if ~isstruct(allAxes) || ~isfield( allAxes, 'freqAxesPos1' ) || ...
    isempty( allAxes.freqAxesPos1 ) 
  allAxes.freqAxesPos1 = [2/3+0.05 3/8+0.05 1/3-0.1 3/8-0.1];
end

if ~isstruct(allAxes) || ~isfield( allAxes, 'waveAxesPos1' ) || ...
    isempty( allAxes.waveAxesPos1 ) 
  allAxes.waveAxesPos1 = [0.05 3/4+0.05 0.9 1/4-0.1 ];
end



% order of windows creation is important, if they overlap on screen:
% the older window is covered by the newer one

% Single window
if ~isstruct(allAxes) || ~isfield( allAxes, 'singleWindow' ) || ...
   isempty( allAxes.singleWindow ) || ~ishandle( allAxes.singleWindow )
  allAxes.singleWindow = figure( 'Name', 'CASY', ...
                         'Visible', 'off', ...
                         'NumberTitle', 'off', ...
                         'IntegerHandle', 'off', ...
                         'Units', 'normalized', ...
                         'Position', allAxes.singleWindowPos, ...
                         'DoubleBuffer', 'on', ... %smooth animation
		         'Colormap', clrMap, ...
                         'HandleVisibility', 'callback' );
end

% auxiliary window for area, spectrum, and waveform, 2-window interface
if ~isstruct(allAxes) || ~isfield( allAxes, 'auxiliaryWindow' ) || ...
   isempty( allAxes.auxiliaryWindow ) || ~ishandle( allAxes.auxiliaryWindow )
  allAxes.auxiliaryWindow = figure( 'Name', 'Area, Spectrum, and Wave', ...
                         'Visible', 'off', ...
                         'NumberTitle', 'off', ...
                         'IntegerHandle', 'off', ...
                         'Units', 'normalized', ...
                         'Position', allAxes.auxiliaryWindowPos, ...
                         'HandleVisibility', 'off' );
end

% the Wave window
if ~isstruct(allAxes) || ~isfield( allAxes, 'waveWindow' ) || ...
   isempty( allAxes.waveWindow ) || ~ishandle( allAxes.waveWindow )
  allAxes.waveWindow = figure( 'Name', 'Wave', ...
                       'Visible', 'off', ...
                       'Units', 'normalized', ...
		       'Position', allAxes.waveWindowPos, ...
                       'NumberTitle', 'off', ...
                       'HandleVisibility', 'off', ...
                       'IntegerHandle', 'off' );
end

% the Spectrum window
if ~isstruct(allAxes) || ~isfield( allAxes, 'freqWindow' ) || ...
   isempty( allAxes.freqWindow ) || ~ishandle( allAxes.freqWindow )
  allAxes.freqWindow = figure( 'Name', 'Spectrum', ...
                       'Visible', 'off', ...
                       'NumberTitle', 'off', ...
                       'Units', 'normalized', ...
		       'Position', allAxes.freqWindowPos, ...
                       'HandleVisibility', 'off', ...
                       'IntegerHandle', 'off' );
end

% the Area Function window
if ~isstruct(allAxes) || ~isfield( allAxes, 'areaWindow' ) || ...
   isempty( allAxes.areaWindow )  || ~ishandle( allAxes.areaWindow )      
  allAxes.areaWindow = figure( 'Name', 'Area', ...
                       'Visible', 'off', ...
                       'NumberTitle', 'off', ...
                       'Units', 'normalized', ...
                       'Position', allAxes.areaWindowPos, ...
                       'HandleVisibility', 'off', ...
                       'IntegerHandle', 'off' );
end


% the Vocal Tract window

if ~isstruct(allAxes) || ~isfield( allAxes, 'VTWindow' ) || ...
   isempty( allAxes.VTWindow ) || ~ishandle( allAxes.VTWindow )
  allAxes.VTWindow = figure( 'Name', 'Vocal Tract', ...
                     'Visible', 'off', ...
                     'NumberTitle', 'off', ...
                     'IntegerHandle', 'off', ...
                     'Units', 'normalized', ...
		     'Position', allAxes.VTWindowPos, ...
                     'DoubleBuffer', 'on', ... %smooth animation
		     'Colormap', clrMap, ...
                     'HandleVisibility', 'callback' );
end


% Vocal Tract axes
global minXPict
global maxXPict
global minYPict
global maxYPict

% for MRI background; 
% order before VTAxes important to put image on background, and vocal tract plot on top
% (alternatively, could change order in the 'Children' property of figure)
if ~isstruct(allAxes) || ~isfield( allAxes, 'imgAxes' ) || ...
   isempty( allAxes.imgAxes ) || ~ishandle( allAxes.imgAxes )
  allAxes.imgAxes = axes( 'Parent', allAxes.VTWindow, ... % otherwise default Fig 1
                          'TickDir', 'out', ...
                          'XLimMode', 'manual', 'YLimMode', 'manual', ...
                          'XLim', [minXPict maxXPict], ...
                          'YLim', [minYPict maxYPict] );
  set(get( allAxes.imgAxes,'XLabel'),'String','mm')
  set(get( allAxes.imgAxes,'YLabel'),'String','mm')
end

% contour outlines layer
if ~isstruct(allAxes) || ~isfield( allAxes, 'contourAxes' ) || isempty( allAxes.contourAxes ) ...
    || ~ishandle( allAxes.contourAxes )
  allAxes.contourAxes = axes(  'Parent', allAxes.VTWindow, ... % otherwise default Fig.1
                          'XLimMode', 'manual', 'YLimMode', 'manual', ...
                          'XLim', [minXPict maxXPict], ...
                          'YLim', [minYPict maxYPict], ...
                          'Visible', 'off' ... % to let see background 
                        );
end


% the vocal tract proper axes
if ~isstruct(allAxes) || ~isfield( allAxes, 'VTAxes' ) || isempty( allAxes.VTAxes ) || ~ishandle( allAxes.VTAxes )
  allAxes.VTAxes = axes(  'Parent', allAxes.VTWindow, ... % otherwise default Fig.1
                          'TickDir', 'out', ...
                          'XLimMode', 'manual', 'YLimMode', 'manual', ...
                          'XLim', [minXPict maxXPict], ...
                          'YLim', [minYPict maxYPict], ...
                          'Visible', 'off' ... % to let see background 
                        );

 allAxes.VTColor = get( allAxes.VTAxes, 'Color' );
end



% area function axes
if ~isstruct(allAxes) || ~isfield( allAxes, 'areaAxes' ) || isempty( allAxes.areaAxes )  || ~ishandle( allAxes.areaAxes )
  allAxes.areaAxes = axes(  'Parent', allAxes.areaWindow, ...% otherwise default Fig.1
                            'XGrid','on', 'YGrid','on' );
  set(get( allAxes.areaAxes,'XLabel'),'String','Distance from glottis, mm')
  set(get( allAxes.areaAxes,'YLabel'),'String','Area, square mm')
end



% spectrum axes
if ~isstruct(allAxes) || ~isfield( allAxes, 'freqAxes' ) || isempty( allAxes.freqAxes )  || ~ishandle( allAxes.freqAxes )
  allAxes.freqAxes = axes( 'Parent', allAxes.freqWindow, ... % otherwise default Fig.1
                           'NextPlot', 'replacechildren' );
  set(get( allAxes.freqAxes,'XLabel'),'String','Frequency, Hz')
  set(get( allAxes.freqAxes,'YLabel'),'String','Magnitude, dB')
end


% waveform axes  
if ~isstruct(allAxes) || ~isfield( allAxes, 'waveAxes' ) || isempty( allAxes.waveAxes )  || ~ishandle( allAxes.waveAxes )
  allAxes.waveAxes = axes( 'Parent', allAxes.waveWindow, ... % otherwise default Fig.1
                           'NextPlot', 'replacechildren' );
  set(get( allAxes.waveAxes,'YLabel'),'String','Amplitude')
  set(get( allAxes.waveAxes,'XLabel'),'String','Time, ms.')
end
  

switch numOfWnd 
case 4
  set( allAxes.imgAxes,  'Parent', allAxes.VTWindow, ...
                         'Position', allAxes.VTAxesPos4 )
  set( allAxes.contourAxes,  'Parent', allAxes.VTWindow, ...
                         'Position', allAxes.VTAxesPos4 )
  set( allAxes.VTAxes,   'Parent', allAxes.VTWindow, ...
                         'Position', allAxes.VTAxesPos4 )
  set( allAxes.areaAxes, 'Parent', allAxes.areaWindow, ...
                         'Position', allAxes.areaAxesPos4 )
  set( allAxes.freqAxes, 'Parent', allAxes.freqWindow, ...
                         'Position', allAxes.freqAxesPos4 )
  set( allAxes.waveAxes, 'Parent', allAxes.waveWindow, ...
                         'Position', allAxes.waveAxesPos4 )

  % order important for 'on' windows: the later will be on top.
  set( allAxes.auxiliaryWindow, 'Visible', 'off' )
  set( allAxes.singleWindow,    'Visible', 'off' )
  set( allAxes.VTWindow,        'Visible', 'off'  )
  set( allAxes.waveWindow,      'Visible', 'on'  )
  set( allAxes.freqWindow,      'Visible', 'on'  )
  set( allAxes.areaWindow,      'Visible', 'on'  )
  set( allAxes.VTWindow,        'Visible', 'on'  )
case 2
  set( allAxes.imgAxes,  'Parent', allAxes.VTWindow, ...
                         'Position', allAxes.VTAxesPos4 )
  set( allAxes.contourAxes,  'Parent', allAxes.VTWindow, ...
                         'Position', allAxes.VTAxesPos4 )
  set( allAxes.VTAxes,   'Parent', allAxes.VTWindow, ...
                         'Position', allAxes.VTAxesPos4 )
  set( allAxes.areaAxes, 'Parent', allAxes.auxiliaryWindow, ...
                         'Position', allAxes.areaAxesPos2 )
  set( allAxes.freqAxes, 'Parent', allAxes.auxiliaryWindow, ...
                         'Position', allAxes.freqAxesPos2 )
  set( allAxes.waveAxes, 'Parent', allAxes.auxiliaryWindow, ...
                         'Position', allAxes.waveAxesPos2 )

  % order important for 'on' windows: the later will be on top.
  set( allAxes.singleWindow,    'Visible', 'off' )
  set( allAxes.areaWindow,      'Visible', 'off' )
  set( allAxes.freqWindow,      'Visible', 'off' )
  set( allAxes.waveWindow,      'Visible', 'off' )
  set( allAxes.VTWindow,        'Visible', 'off'  )
  set( allAxes.auxiliaryWindow, 'Visible', 'on'  )
  set( allAxes.VTWindow,        'Visible', 'on'  )
case 1
  set( allAxes.imgAxes,  'Parent',  allAxes.singleWindow, ...
                         'Position', allAxes.VTAxesPos1 )
  set( allAxes.contourAxes,  'Parent', allAxes.singleWindow, ...
                         'Position', allAxes.VTAxesPos1 )
  set( allAxes.VTAxes,   'Parent',  allAxes.singleWindow, ...
                         'Position', allAxes.VTAxesPos1 )
  set( allAxes.areaAxes, 'Parent',  allAxes.singleWindow, ...
                         'Position', allAxes.areaAxesPos1 )
  set( allAxes.freqAxes, 'Parent',  allAxes.singleWindow, ...
                         'Position', allAxes.freqAxesPos1 )
  set( allAxes.waveAxes, 'Parent',  allAxes.singleWindow, ...
                         'Position', allAxes.waveAxesPos1 )

  set( allAxes.VTWindow,        'Visible', 'off' )
  set( allAxes.areaWindow,      'Visible', 'off' )
  set( allAxes.freqWindow,      'Visible', 'off' )
  set( allAxes.waveWindow,      'Visible', 'off' )
  set( allAxes.auxiliaryWindow, 'Visible', 'off' )
  set( allAxes.singleWindow,    'Visible', 'on' )
end

