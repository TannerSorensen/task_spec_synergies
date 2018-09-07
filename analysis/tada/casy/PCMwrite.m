function PCMwrite(signal, sRate, fileName, noisy)
%PCMWRITE  - write signal data as a Haskins format PCM file
%
%	 usage:  PCMwrite(signal, sRate, fileName, noisy)
%
% SIGNAL is a vector of signal data with SRATE sampling rate (Hz)
%
% if FILENAME is [] output file name is selected interactively by dialog box
% if FILENAME is specified and file exists it is overwritten
%
% if optional NOISY flag is zero completion message is suppressed
%
% if SIGNAL is integral data in the range 0-4095 it is stored without scaling
% otherwise data are scaled to fit the unipolar 12 bit range, and the header
%  CALM (scaling) and CALB (offset) fields are set to the appropriate values
%
% see also PCMread

% mkt 10/97

%	constants

byteOrder = 'vaxd';			% file byte order
atrib = 0;					% data attributes (no pre-emp, no filtering)
revlvl = 5;					% PCM header revision level


%	parse arguments

if nargin < 2,
	eval('help PCMwrite');
	return;
end;
n = sort(size(signal));
if ndims(signal)>2 | n(1)>1,
	error('expecting column or row vector for signal argument');
end;
if prod(size(sRate)) ~= 1 | sRate <= 0,
	error('expecting positive scalar sampling rate argument');
end;
period = round(1e6/sRate);			% period in microsecs
if sRate ~= floor(sRate),
	disp('Warning:  non-integral sampling rates may not be stored accurately;');
	disp([' approximating using ', int2str(period), ' period (microsecs)']);
	sRate = floor(sRate);
end;
if nargin < 3, fileName = []; end;
if nargin < 4, noisy = 1; end;


%	get filename if necessary

if isempty(fileName),
	[file, pathName] = uiputfile([inputname(1),'.pcm'], 'Save data to Haskins PCM file');
	if file == 0, return; end;
	fileName = [pathName file];
else,
	file = fileName;
end;


%	determine data scaling

if any(signal<0) | any(signal>4095) | any(signal~=floor(signal)),
	minV = min(signal);						
	calm = (max(signal) - minV) / 4095;		% scale factor	
	signal = round((signal - minV) / calm);	% 0-4095 range
	calb = minV + 2048*calm;				% offset
else,								% no scaling necessary
	calm = 1;
	calb = 0;
end;


%	open the file

[fid, msg] = fopen(fileName, 'wb', byteOrder);
if fid == -1							
	error([msg, ' (', fileName, ')']);
end;


%	write PCM header

fwrite(fid, 1, 'int16');						% type
fwrite(fid, length(signal), 'uint32');			% tfrms
fwrite(fid, sRate, 'uint16');					% frate
fwrite(fid, atrib, 'uint16');					% atrib
fwrite(fid, [0 0], 'int16');					% nahdrblk, nlabels
fwrite(fid, revlvl, 'int16');					% revlvl
fwrite(fid, 0, 'int32');						% vbntrlr
fwrite(fid, [0 0], 'int16');					% ntrlrblk, source
fwrite(fid, 12, 'int16');						% resolution
fwrite(fid, 0, 'int16'); 						% srcpure
fwrite(fid, period, 'uint16');					% period
fwrite(fid, zeros(1, 59), 'int16');				% (filler)
fwrite(fid, calm, 'float32');					% calm
fwrite(fid, calb, 'float32');					% calb
fwrite(fid, zeros(1, 178), 'int16');			% (filler)


%	write data

fwrite(fid, signal, 'int16');

% Yura Koblents
% write tail filler to 512 bytes

tailLen = mod( length( signal ), 256 ); % 256, not 512, because 2-byte integers
if tailLen ~= 0
  fwrite( fid, zeros( 1, 256 - tailLen ),  'int16' );
end




%	clean up

fclose(fid);
if noisy,
	fprintf('%s written successfully.\n', file);
end;
