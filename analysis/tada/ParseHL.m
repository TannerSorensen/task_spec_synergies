function params = ParseHL(fName)
%PARSEHL  - parse the HLsyn HL file type
%
%	usage:  params = ParseHL(fName)
%
% use this procedure to parse HL format files exported by 
% the interactive HLsyn program (HL parameter data)
%
% returns a PARAMS array-of-structs variable suitable for driving
% the MEX interface to HLsyn

% mkt 01/09

if nargin < 1,
	eval('help ParseHL');
	return;
end;

% add default extension if necessary
[p,f,e] = fileparts(fName);
if isempty(e), fName = fullfile(p,[f,'.HL']); end;

% vacuum file
try,
	fid = fopen(fName);
	lines = {};
	while 1,
		lx = fgetl(fid);
		if ~ischar(lx), break; end;
		lines{end+1} = lx;
	end;
	fclose(fid);
catch,
	error('error attempting to read %s', fName);
end;

% strip blank, comment lines
lc = char(lines);
lines(find(lc(:,1)==' ' | lc(:,1)==';')) = [];

% parse:  expecting parameter, time, value
curP = 0;
curT = -1;
for li = 1 : length(lines),
	try,
% 		q = regexp(lines{li},'(\w\w)\s+(\d+\.\d+)\s+(-?\d+\.\d+)','tokens');  
        % modified by HN 200901 to allow tada HL output format
        q = regexp(lines{li},'(\w\w)\s+([\d\.]+)\s+(-?[\d\.]+)','tokens');
 		q = q{1};
		par = upper(q{1});
		time = str2num(q{2});
		val = str2num(q{3});
	catch,
		error('parsing error in line %d (%s)', li, lines{li});
	end;

% advance current parameter on new time value
	if time < curT,
		error('time values must increase monotonically');
	elseif time > curT,
		curP = curP + 1;
		curT = time;
		params(curP).TIME = time;
	end;
	
% add parameter
	params(curP).(par) = val;
end;
