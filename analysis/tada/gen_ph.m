% gen_ph.m
% generate ph_.o from tv_.o
% gen_ph (utt_name, ph_syntax)
% gen_ph (utt_name, ph_syntax, out_path)

function gen_ph (varargin)


if ispc
    d = '\';
else
    d = '/';
end

err_msg			= '  Useage: % gen_ph (utt_name, ph_syntax, (out_path))';
if (nargin >= 2)
    utt_name = varargin{1};
    ph_syntax = varargin{2};
	if (nargin ==2)
		out_path = [cd d];
    else
        out_path = [varargin{2} d];
    end
else
    error(err_msg);
end

fid_w = fopen(strcat(out_path, 'PH', utt_name, '.O'), 'w');
fprintf(fid_w, '%s\n', ['%' '''' 'OSC_ID' ''' ' ...
    'NatFreq m,n escap amp_init phase_init / riseramp plateau fallramp']);
%'OSC_ID' NatFreq m,n escap amp_init phase_init / riseramp plateau fallramp

% read TV.o file
fp = fopen([out_path 'TV' utt_name '.O'], 'rt'); % open data file
if fp == -1
    disp('No TV.o file found')
end
ln = fscanf(fp, '%s', 1); % read first data
while ~isempty(strmatch('%', ln))
    fgetl(fp);
    ln = fscanf(fp, '%s', 1); % read first data of each line
end
fgetl(fp);

wordInit = 1;
nOSC = 0;
while 1 % until fscanf can't read
    str = fscanf(fp, '%s', 1); % read first data of each line
    if isempty(strmatch('%', str))
        if strcmpi(str, '##')
            wordInit = [wordInit str2num(list_osc{end}(end))+1];
        else
            if isempty(str),   break,   end
            oscID = fscanf(fp, '%s', 1);
            nOSC = nOSC +1;
            list_osc{nOSC} = oscID(2:end-1);
            fgetl(fp);
        end
    else
        fgetl(fp);
    end
end
fclose(fp);


osc = struct(...        
        'ID', [], 'PARAMS', []);
    
coupl = struct(...        
        'ID1', [], 'ID2', [], 'PARAMS', [], 'FLG', []);

[fp, msg] = fopen(ph_syntax, 'rt');
if fp == -1
    disp(msg)
end

%% read oscillator parameters from syntax file (PH_syntax.txt)
m = 0;
while 1 % until fscanf can't read
    str = fscanf(fp, '%s', 1); % read first data of each line
    if isempty(strmatch('%', str)) & ~strcmpi(str, '/coupling/') 
        if isempty(str),   break,   end
        m = m+1;
        osc(m).ID = str;
        osc(m).PARAMS = fscanf(fp, '%f', 5);

        
        % added because fscanf('f') can't read NaN   
        % (Matlab 7.1 windows ver. when used in Parallel (in phonetics lab)
        % modified by HN 070125
        if length(osc(m).PARAMS) < 5
            str = fscanf(fp, '%s', 1);
            if strcmpi(str, 'NaN');
                osc(m).PARAMS = [osc(m).PARAMS; str2num(str)];
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        fscanf(fp, '%s', 1);
        osc(m).PARAMS = [osc(m).PARAMS; fscanf(fp, '%f', 3)];
    elseif strcmpi(str, '/coupling/')
       break 
    end
    fgetl(fp);
end


%% read coupling specifications from syntax file
n = 0;
while 1 % until fscanf can't read
    str = fscanf(fp, '%s', 1); % read first data of each line
    if isempty(strmatch('%', str)) & ~strcmpi(str, '/cross-syllable/')
        if isempty(str),   break,   end
        n = n+1;
        coupl(n).ID1 = str;
        coupl(n).ID2 = fscanf(fp, '%s', 1);
        coupl(n).PARAMS = fscanf(fp, '%f', 3);
        coupl(n).FLG = 0;
    elseif strcmpi(str, '/cross-syllable/')
        break
    end
    fgetl(fp);
end


%% read cross-syllable coupling specifications from syntax file
while 1 % until fscanf can't read
    str = fscanf(fp, '%s', 1); % read first data of each line
    if isempty(strmatch('%', str)) & ~strcmpi(str, '/cross-word/')
        if isempty(str),   break,   end
        n = n+1;
        coupl(n).ID1 = str;
        coupl(n).ID2 = fscanf(fp, '%s', 1);
        coupl(n).PARAMS = fscanf(fp, '%f', 3);
        coupl(n).FLG = 1;
    elseif strcmpi(str, '/cross-word/')
        break
    end
    fgetl(fp);
end


%% read word-syllable coupling specifications from syntax file
while 1 % until fscanf can't read
    str = fscanf(fp, '%s', 1); % read first data of each line
    if isempty(strmatch('%', str))
        if isempty(str),   break,   end
        n = n+1;
        coupl(n).ID1 = str;
        coupl(n).ID2 = fscanf(fp, '%s', 1);
        coupl(n).PARAMS = fscanf(fp, '%f', 3);
        coupl(n).FLG = 2;
    end
    fgetl(fp);
end

fclose(fp);



%% sort oscillator identifiers from TV.o by syllble order
list_osc = unique(list_osc);
list_osc = sort(list_osc);
k = [];
for j=1:length(list_osc)
    
    % extract syllable number at the end of oscID
    p = [];
    tmpIdx = regexp(list_osc{j}, ['\d+$']);
    for i = tmpIdx:length(list_osc{j})
        p = [p list_osc{j}(i)];
    end
    
    
    k = [k str2num(p)];
end
[a b]=sort(k);
list_osc=list_osc(b);
nSyll = a(end);




%% specification of oscillator parameters in ph.o file based on ph_syntax
k_all = [];
for j=1:length(osc)
    id = regexpfind(list_osc, osc(j).ID);
    if strmatch (osc(j).ID, 'DFLT')
        iDflt = j;
    end
    if id ~= 0
        for k = id
            fprintf(fid_w, '%s\n', ['''' list_osc{k} ''' ' num2str(osc(j).PARAMS(1:5)', '%d ') '/ ' num2str(osc(j).PARAMS(6:end)', '%d ')]);
            k_all = [k_all k];
        end
    end
end

for i = find(ismember(1:length(list_osc), k_all)== 0) % default specification
    fprintf(fid_w, '%s\n', ['''' list_osc{i} ''' ' num2str(osc(iDflt).PARAMS(1:5)', '%d ') '/ ' num2str(osc(iDflt).PARAMS(6:end)', '%d ')]);
end

fprintf(fid_w, '\n%s\n\n', ['/coupling/']);
fprintf(fid_w, '%s\n', ['%' '''' 'OSC_ID1' '''' ' ' '''' 'OSC_ID2' ''' '...
    'strength1(to OSC1) strength2(to OSC2) TargetRelPhase']);



%% specification of couplings in ph.o file based on ph_syntax
flgVELGLO = zeros(4,nSyll); % VELOnset, VELCoda, GLOOnset, GLOCoda
for i = 1:length(coupl)
    [subID1 subLen1] = getSubID(coupl(i).ID1); % extract 'ONS' 'CNS' from ONS_CNS
    fndosc1 = findosc (list_osc, subID1);      % find any string including 'ONS*_CNS*'
    [subID2 subLen2] = getSubID(coupl(i).ID2);
    fndosc2 = findosc (list_osc, subID2);
    if ~isempty(fndosc1) & ~isempty(fndosc2)
        [couplOsc, flgVELGLO] = findcoupl (fndosc1, fndosc2,  subLen1, subLen2, coupl(i), list_osc, nSyll, flgVELGLO);

        for j = 1:length(couplOsc)
            x = strfind(couplOsc{j}, ' ');
            fprintf(fid_w, '%s\n', ['''' couplOsc{j}(1:x-1) ''' ''' couplOsc{j}(x+1:end) ''' ' num2str(coupl(i).PARAMS', '%d ')]);
        end
    end
    couplOsc = [];
end

%% specification of cross-syllable couplings (within/across words) in ph.o file based on ph_syntax
couplOsc = [];
for i = 2:nSyll
    
    % within a word
    if ~ismember(i, wordInit)  
        xSyllID = [coupl.FLG] == 1;
        xSyllcoupl=coupl(xSyllID);
        
        % C$C
        cod_CC = findosc (list_osc, getSubID(xSyllcoupl(1).ID1));
        ons_CC = findosc (list_osc, getSubID(xSyllcoupl(1).ID2));
        
        cod_1_CC = regexpfind(cod_CC, ['\D' num2str(i-1, '%d') '$']);
        ons_2_CC = regexpfind(ons_CC, ['\D' num2str(i, '%d') '$']);
        
        if cod_1_CC(1) & ons_2_CC(1)
            couplOsc = [cod_CC{cod_1_CC(end)} ' ' ons_CC{ons_2_CC(1)}]; x = strfind(couplOsc, ' ');
            fprintf(fid_w, '%s\n', ['''' couplOsc(1:x-1) ''' ''' couplOsc(x+1:end) ''' ' num2str(xSyllcoupl(1).PARAMS', '%d ')]);
        else
            if ~cod_1_CC(1) & ons_2_CC(1) % V$C
                V_VC = findosc (list_osc, getSubID(xSyllcoupl(2).ID1));
                ons_VC = findosc (list_osc, getSubID(xSyllcoupl(2).ID2));
                
                V_1_VC = regexpfind(V_VC, ['\D' num2str(i-1, '%d') '$']);
                ons_2_VC = regexpfind(ons_VC, ['\D' num2str(i, '%d') '$']);
                couplOsc = [V_VC{V_1_VC(end)} ' ' ons_VC{ons_2_VC(1)}];  x = strfind(couplOsc, ' ');
                fprintf(fid_w, '%s\n', ['''' couplOsc(1:x-1) ''' ''' couplOsc(x+1:end) ''' ' num2str(xSyllcoupl(2).PARAMS', '%d ')]);
            elseif cod_1_CC(1) & ~ons_2_CC(1) % C$V
                cod_CV = findosc (list_osc, getSubID(xSyllcoupl(3).ID1));
                V_CV = findosc (list_osc, getSubID(xSyllcoupl(3).ID2));
                
                cod_1_CV = regexpfind(cod_CV, ['\D' num2str(i-1, '%d') '$']);
                V_2_CV = regexpfind(V_CV, ['\D' num2str(i, '%d') '$']);
                
                couplOsc = [cod_CV{cod_1_CV(end)} ' ' V_CV{V_2_CV(1)}];  x = strfind(couplOsc, ' ');
                fprintf(fid_w, '%s\n', ['''' couplOsc(1:x-1) ''' ''' couplOsc(x+1:end) ''' ' num2str(xSyllcoupl(3).PARAMS', '%d ')]);
            elseif ~cod_1_CC(1) & ~ons_2_CC(1) % V$V
                V_VV = findosc (list_osc, getSubID(xSyllcoupl(4).ID1));
                
                V_2_VV = regexpfind(V_VV, ['\D' num2str(i, '%d') '$']);
                V_1_VV = regexpfind(V_VV, ['\D' num2str(i-1, '%d') '$']);
                
                couplOsc = [V_VV{V_1_VV(end)} ' ' V_VV{V_2_VV(1)}];  x = strfind(couplOsc, ' ');
                fprintf(fid_w, '%s\n', ['''' couplOsc(1:x-1) ''' ''' couplOsc(x+1:end) ''' ' num2str(xSyllcoupl(4).PARAMS', '%d ')]);
            end
        end
        
        
        
        
    % across words
    else                       
        xSyllID = [coupl.FLG] == 2;
        xSyllcoupl=coupl(xSyllID);
        
        % C#C (C w/ REL # C)
        cod_CC = findosc (list_osc, getSubID(xSyllcoupl(5).ID1));
        ons_CC = findosc (list_osc, getSubID(xSyllcoupl(5).ID2));
        
        cod_1_CC = regexpfind(cod_CC, ['\D' num2str(i-1, '%d') '$']);
        ons_2_CC = regexpfind(ons_CC, ['\D' num2str(i, '%d') '$']);
        
        if cod_1_CC(1) & ons_2_CC(1)
            couplOsc = [cod_CC{cod_1_CC(end)} ' ' ons_CC{ons_2_CC(1)}]; x = strfind(couplOsc, ' ');
            fprintf(fid_w, '%s\n', ['''' couplOsc(1:x-1) ''' ''' couplOsc(x+1:end) ''' ' num2str(xSyllcoupl(5).PARAMS', '%d ')]);
        else
            if ~cod_1_CC(1) & ons_2_CC(1) % V$C  (or y,w w/o REL # C)

                % y,w w/o REL # C
                V_VC = findosc (list_osc, getSubID(xSyllcoupl(1).ID1));
                ons_VC = findosc (list_osc, getSubID(xSyllcoupl(1).ID2));
                
                V_1_VC = regexpfind(V_VC, ['\D' num2str(i-1, '%d') '$']);
                ons_2_VC = regexpfind(ons_VC, ['\D' num2str(i, '%d') '$']);
                if V_1_VC(1) & V_1_VC(1)
                    couplOsc = [V_VC{V_1_VC(end)} ' ' ons_VC{ons_2_VC(1)}];  x = strfind(couplOsc, ' ');
                    fprintf(fid_w, '%s\n', ['''' couplOsc(1:x-1) ''' ''' couplOsc(x+1:end) ''' ' num2str(xSyllcoupl(1).PARAMS', '%d ')]);
                end
                
                if ~V_1_VC % V#C or V$C
                    V_VC = findosc (list_osc, getSubID(xSyllcoupl(2).ID1));
                    ons_VC = findosc (list_osc, getSubID(xSyllcoupl(2).ID2));
                    
                    V_1_VC = regexpfind(V_VC, ['\D' num2str(i-1, '%d') '$']);
                    ons_2_VC = regexpfind(ons_VC, ['\D' num2str(i, '%d') '$']);
                    couplOsc = [V_VC{V_1_VC(end)} ' ' ons_VC{ons_2_VC(1)}];  x = strfind(couplOsc, ' ');
                    fprintf(fid_w, '%s\n', ['''' couplOsc(1:x-1) ''' ''' couplOsc(x+1:end) ''' ' num2str(xSyllcoupl(2).PARAMS', '%d ')]);
                end
                
            elseif cod_1_CC(1) & ~ons_2_CC(1) % C#V
                cod_CV = findosc (list_osc, getSubID(xSyllcoupl(3).ID1));
                V_CV = findosc (list_osc, getSubID(xSyllcoupl(3).ID2));
                
                cod_1_CV = regexpfind(cod_CV, ['\D' num2str(i-1, '%d') '$']);
                V_2_CV = regexpfind(V_CV, ['\D' num2str(i, '%d') '$']);
                
                couplOsc = [cod_CV{cod_1_CV(end)} ' ' V_CV{V_2_CV(1)}];  x = strfind(couplOsc, ' ');
                fprintf(fid_w, '%s\n', ['''' couplOsc(1:x-1) ''' ''' couplOsc(x+1:end) ''' ' num2str(xSyllcoupl(3).PARAMS', '%d ')]);
            elseif ~cod_1_CC(1) & ~ons_2_CC(1) % V#V
                V_VV = findosc (list_osc, getSubID(xSyllcoupl(4).ID1));
                
                V_2_VV = regexpfind(V_VV, ['\D' num2str(i, '%d') '$']);
                V_1_VV = regexpfind(V_VV, ['\D' num2str(i-1, '%d') '$']);
                
                couplOsc = [V_VV{V_1_VV(end)} ' ' V_VV{V_2_VV(1)}];  x = strfind(couplOsc, ' ');
                fprintf(fid_w, '%s\n', ['''' couplOsc(1:x-1) ''' ''' couplOsc(x+1:end) ''' ' num2str(xSyllcoupl(4).PARAMS', '%d ')]);
            end
        end
        
        
    end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
end

fclose(fid_w);




function [fndosc fndoscID]= findosc (list_osc, subID)
if length(subID) == 1 % for Vs
    strID = ['^' subID{1} '\d+$'];
elseif length(subID) ==2 % for Cs or lip rounding for vowels
    if strmatch('C', subID{2}, 'exact')
        subID2 = '(clo|crt|nar|voc)';
    elseif strmatch('CNS', subID{2})
        subID2 = '(clo|crt|nar)';
    elseif strmatch('OBS', subID{2})
        subID2 = '(clo|crt)';
    else
        subID2 = subID{2};
    end
    strID = ['^' subID{1} '\d*_' subID2 '\d+$'];
end

x = regexpfind(list_osc, strID); if x == 0, x = []; end

fndosc = list_osc(x);
fndoscID = regexpfind(list_osc, strID);




function [couplOsc flgVELGLO] = findcoupl (fndosc1, fndosc2, subLen1, subLen2, coupl, list_osc, nSyll, flgVELGLO)
couplOsc = [];

if coupl.FLG == 0 % within-syll
    for n = 1:nSyll
        % syllable number scan
        idx1= regexpfind(fndosc1, ['\D' num2str(n) '$']); if idx1 == 0, idx1 = []; end
        idx2= regexpfind(fndosc2, ['\D' num2str(n) '$']); if idx2 == 0, idx2 = []; end

        if ~isempty(idx1) & ~isempty(idx2)
            % multiple/single choice for ID1
            if ~isempty(strmatch(coupl.ID1(end), '*', 'exact')) | subLen1 == subLen2 | subLen1 ==1
                osc1 = fndosc1(idx1);
            else
                osc1 = fndosc1(idx1);
                osc1 = osc1(end);% if no * in ONS_CNS, V is coupled to the last C in onset cluster
            end

            % multiple/single choice for ID2
            if ~isempty(strmatch(coupl.ID2(end), '*', 'exact')) | subLen1 == subLen2 | subLen2 ==1
                osc2 = fndosc2(idx2);
            else
                osc2 = fndosc2(idx2);
                osc2 = osc2(1);% if no * in COD_CNS, V is coupled to the first C in coda cluster
            end

            if (~isempty(osc1)& ~isempty(osc2))     
                for i = 1: length(osc1)
                    for j = 1: length(osc2)

                        if isempty(strmatch(osc1{i}, osc2{j}, 'exact')) % modified by HN to suppress self-coupling of a single oscillator 11/2008

                            % specification of segNo obtained from ID (e.g. 1 is SegNo in 'ons1_clo2')
                            % segNo ==0 for 'v',  segNo ==-1 for 'h' or 'rnd'
                            % when they don't have segment number (e.g. ons_h1)
                            subID1 = getSubID (osc1{i});
                            if subLen1 == 2
                                segNo1 = str2num(subID1{1}(end));
                                if isempty(segNo1),segNo1 = -1;end
                            else
                                segNo1 = 0;
                            end

                            subID2 = getSubID (osc2{j});
                            if subLen2 == 2
                                segNo2 = str2num(subID2{1}(end));
                                if isempty(segNo2),segNo2 = -1;end
                            else
                                segNo2 = 0;
                            end

                            gclass1 = CNSmember(subID1{end}(1:end-1));
                            gclass2 = CNSmember(subID2{end}(1:end-1));

                            % C-C sequential when belong to the same    (e.g. CLO/CRT/NAR/VOC)
                            if ~isempty(gclass1) & ~isempty(gclass2) & strmatch(gclass1, gclass2, 'exact') & (segNo1 ~= segNo2)

                                x = getSubID(osc1{i});
                                y = getSubID(osc2{j});
                                %
                                if str2num(x{1}(end)) == str2num(y{1}(end))-1
                                    couplOsc{length(couplOsc)+1} = [osc1{i} ' ' osc2{j}];
                                end
                            else
                                % CNS-N/H, NAR-VOC, or C-V      cf. VOC NAR 0 is here

                                if segNo1 == segNo2 | segNo1 == 0 | segNo2 == 0
                                    % C-N C-H(coda), CV, VV, rndV, hV
                                    if regexpfind(osc1, ['ons\d+_h\d+']) & strmatch('v', osc2)& flgVELGLO(3, n) == 1   % only for hV (e.g. 'he')
                                        break
                                    end

                                    couplOsc{length(couplOsc)+1} = [osc1{i} ' ' osc2{j}];
                                    if ~isempty(regexpfind(osc1, ['\D\d+_h\d+'])) |... % if either subID1 or 2 is 'ons1_h'
                                            ~isempty(regexpfind(osc2, ['\D\d+_h\d+']))
                                        if strmatch('ons', subID1{1})  &  flgVELGLO(3, n) == 0        % onset consonant and GLO
                                            flgVELGLO(3, n) = 1;
                                        elseif strmatch('cod', subID1{1})  &  flgVELGLO(4, n) == 0    % coda consonant and GLO
                                            flgVELGLO(4, n) = 1;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end



function gclass = CNSmember (subID)
if regexpi (subID, '(clo|crt|nar|voc)')
    gclass = 'C'; 
else
    gclass = [];
end