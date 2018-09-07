%
% testgest.m
%
% Author:
%   Michael Proctor	16-Feb-07
%
% Synopsis:
%   Test script for <gest.pl>
%   Passes each string in test corpus to <gest.pl> in turn; directs output files to results directory.
%
% Useage:
%   testgest(outdir, test_corpus, (language), (prefix))
%   <outdir>    directory in which to write outputs (tada TV*.O files)
%   <corpus>	text file containing test words, one to a line
%   <language>	directory containing gestural specification files
%
% Notes:
%   For each 'word' in <test_corpus>, calls "gest( word, word, (language), (prefix) )"
%   assumes existance of a dir <language/> (default 'english') containing the following files:
%   <pdict.txt>     orthography -> ARPAbet
%   <onsets.txt>    list of onset clusters
%   <seg2gest.txt>  dictionary listing segments > gestures
%   <cod2gest.txt>  dictionary listing coda segments > gestures
%   <gparams.txt>   gestural parameters

%function testgest(outdir, test_corpus, language)
function testgest(varargin)

% parse input arguments
err_msg	= '  Useage: testgest(outdir, test_corpus, (language), (prefix))';
prefix	= '';
altfile	= 0;
if (nargin >= 2)
    outdir          = varargin{1};
    test_corpus     = varargin{2};
	language        = 'english';
	if (nargin >= 3)
		language    = varargin{3};
		if (nargin == 4)
            altfile	= 1;
			prefix	= varargin{4};
		end
	end
else
    error(err_msg);
end

% locate files and directories
thispath    = cd;
outfiles	= [thispath '\' outdir];
corpus      = [thispath '\' test_corpus];

% create directory for output files:
disp(' ');
disp(['  Creating output directory <' outfiles '>']);
[stat, mess] = mkdir(outfiles); disp(mess);
if (stat == 0)
	error(['  Cannot create output directory <' outfiles '>']);
end
cd(outfiles);

% open test corpus file:
disp(['  Opening test corpus file <' corpus '>']);
fid = fopen(corpus);
if (fid == -1)
	error(['  Cannot open file <' corpus '>']);
end

% read each word in the test corpus file and generate output files
wd_cnt	 = 0;
more_wds = 1;
while (more_wds == 1)
    
    wd = fgetl(fid);
    if (wd == -1)
        more_wds = 0;
    else
        if ( numel(wd) > 0  )
            if ( ~strcmp( wd(1),'#' ) )	% ignore comment lines (#)
                if (altfile == 1)
                    gest(wd, wd, language, prefix)
                else
                    gest(wd, wd, language)
                end
                wd_cnt = wd_cnt+1;
            end
        end
    end

end

fclose('all');
cd(thispath);

disp(' ');
disp(['  ' num2str(wd_cnt) ' test files generated and written to  <' outfiles '>' ]);
disp(' ');
