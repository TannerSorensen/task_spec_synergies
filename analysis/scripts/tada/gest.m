function gest(varargin)
%
% GEST.M
%
% Author:
%   Louis Goldstein   30-Nov-06
%   Michael Proctor   23-Sep-08
%
% Synopsis:
%   Call Perl scripts to generate TV_.O and PH_.O files from orthographic input
%
% Useage:
%	gest(outfile, input_string, (language), (prefix))
%	outfile:         identfier for TV_.O, PH_.O files
%	input_string:    orthographic string (English word)
%	(language):      name of directory containing language-specific files (default: <english>)
%	(prefix):        prefix of alternate data files to search for in current directory
%
% Notes:
%   <language/> directory must contain the following files
%               <pdict.txt>		orthography > ARPAbet
%               <seg2gest.txt>  dictionary listing segments > gestures
%               <gparams.txt>   gestural parameters
%               <onsets.txt>    list of gestures to be deleted from onset clusters
%               <codas.txt>     list of gestures to be deleted from coda clusters
%               <finals_wd.txt>	list of gestures to be deleted from word-final coda clusters
%               <finals_ph.txt>	list of gestures to be deleted from phrase-final coda clusters
%               <coupling.ph>	phasing syntax file 
%

% locate directories
[tadapath, nm]	= fileparts(which('gest.m'));
if ispc
    gestpath        = [tadapath '\gest\'];
else
    gestpath        = [tadapath '/gest/'];
end
thispath        = cd;

% initialise alternative input filenames
pdict_alt		= '';
seg2gest_alt	= '';
gparams_alt		= '';
onsets_alt		= '';
codas_alt		= '';
finals_wd_alt	= '';
finals_ph_alt	= '';
coupling_alt	= '';

if ispc
    d = '\';
else
    d = '/';
end

% parse input arguments
err_msg			= '  Useage: gest(outfile, input_string, (language), (prefix))';
if (nargin >= 2)
    outfile         = varargin{1};
    input_string	= varargin{2};
	language        = 'english';
    langpath        = [gestpath language d];
	if (nargin >= 3)
		language    = varargin{3};
        langpath	= [gestpath language d];       
		if (nargin == 5)
			prefix          = varargin{4};
			thispath        = cd;
			pdict_alt		= [thispath d prefix '_pdict.txt'];
			seg2gest_alt	= [thispath d prefix '_seg2gest.txt'];
			gparams_alt		= [thispath d prefix '_gparams.txt'];
			onsets_alt		= [thispath d prefix '_onsets.txt'];
			codas_alt		= [thispath d prefix '_codas.txt'];
			finals_wd_alt	= [thispath d prefix '_finals_wd.txt'];
			finals_ph_alt	= [thispath d prefix '_finals_ph.txt'];
			coupling_alt	= [thispath d prefix '_coupling.ph'];
		end
	end
else
    error(err_msg);
end

% look for alternative parameter files in local directory,
% otherwise use defaults in language directory
if (which(pdict_alt))
    pdict	= pdict_alt;
else
	pdict	= [langpath 'pdict.txt'];
end;    

if (which(seg2gest_alt))
    seg2gest	= seg2gest_alt;
else
	seg2gest	= [langpath 'seg2gest.txt'];
end;    

if (which(gparams_alt))
    gparams		= gparams_alt;
else
	gparams     = [langpath 'gparams.txt'];
end;    

if (which(onsets_alt))
    onsets	= onsets_alt;
else
	onsets	= [langpath 'onsets.txt'];
end;    

if (which(codas_alt))
    codas	= codas_alt;
else
	codas	= [langpath 'codas.txt'];
end;    

if (which(finals_wd_alt))
    finals_wd	= finals_wd_alt;
else
	finals_wd	= [langpath 'finals_wd.txt'];
end;    

if (which(finals_ph_alt))
    finals_ph	= finals_ph_alt;
else
	finals_ph	= [langpath 'finals_ph.txt'];
end;    

if (which(coupling_alt))
    coupling	= coupling_alt;
else
    coupling	= [langpath 'coupling.ph'];
end;    

% call perl script to generate <TVoutfile.O>
script	= [gestpath 'gest.pl'];

if isunix
    input_string = ['''' input_string ''''];
end

outfile = lower(outfile);
if ispc
    outpathfile = [pwd '\TV' outfile];
else
    outpathfile = [pwd '/TV' outfile];
end
    
    
perl(script, pdict, seg2gest, gparams, onsets, codas, finals_wd, finals_ph, outpathfile, input_string)
%system(['perl ', script,' ', pdict,' ', seg2gest, ' ',gparams, ' ', onsets, ' ', codas, ' ', finals_wd, ' ', finals_ph, ' ',outfile, ' ',input_string]);
% call m-file to generate <PHoutfile.O>
disp(['  Generating output file:     <PH' outfile '.O>']);
disp(['  Using coupling syntax file: <' coupling '>']);
gen_ph(outfile, coupling);
disp(' ');
disp(' ');

