function t_saveMview (fname, state)
% hObject    handle to pb_savemavis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

load t_params

% % temporarily%%%%%%%%%%%
% while isreserved(fname) | iskeyword(fname) | ~isempty(strmatch(fname, 'com', 'exact')) | ~isempty(strmatch(fname, 'com1', 'exact'))
%     fname = [fname '1'];
% end
% %%%%%%%%%%%%%%%%%%%%%%%%

id_ext = strfind(fname,'.mat');
if id_ext
    sav_struct = fname(1:id_ext(end)-1);
else
    sav_struct = fname;
end

% call pb_asypel_Callback to calculate ASYPEL
A = state.A;
TV = state.TV;
srate_trj = 1000/wag_frm;
audio = state.sig;

srate_aud = state.srate;
ASYPEL = state.ASYPEL;

nSig = size(ASYPEL,2)+size(TV,1);
utt_struct(1:nSig) = struct(...
    'NAME', [],...
    'CHANNEL', [],...
    'COLLECTED', [],...
    'SRATE', [],...
    'SIGNAL', [],...
    'CALINFO', [],...
    'SCALING', struct(...
    'TYPE', [],...
    'RANGE', []),...
    'LABELS', []);

for i = 1:nSig
    n = i;
    srate = srate_trj;
    switch i
        case 1, name = 'audio'; n = 0; signal = audio'; srate = srate_aud;
        case 2, name = 'UL'; signal = [ASYPEL(1).SIGNAL(1,:)' ASYPEL(1).SIGNAL(2,:)'];
        case 3, name = 'LL'; signal = [ASYPEL(2).SIGNAL(1,:)' ASYPEL(2).SIGNAL(2,:)'];
        case 4, name = 'JAW'; signal = [ASYPEL(3).SIGNAL(1,:)' ASYPEL(3).SIGNAL(2,:)'];
        case 5, name = 'TT'; signal = [ASYPEL(4).SIGNAL(1,:)' ASYPEL(4).SIGNAL(2,:)'];
        case 6, name = 'TB'; signal = [ASYPEL(5).SIGNAL(1,:)' ASYPEL(5).SIGNAL(2,:)'];    
        case 7, name = 'TF'; signal = [ASYPEL(8).SIGNAL(1,:)' ASYPEL(8).SIGNAL(2,:)'];
        case 8, name = 'TD'; signal = [ASYPEL(6).SIGNAL(1,:)' ASYPEL(6).SIGNAL(2,:)'];
        case 9, name = 'TR'; signal = [ASYPEL(7).SIGNAL(1,:)' ASYPEL(7).SIGNAL(2,:)'];
        case 10, name = 'LA'; signal = TV(i_LA,:)';
        case 11, name = 'PRO'; signal = TV(i_PRO,:)';
        case 12, name = 'TTCD'; signal = TV(i_TTCD,:)';
        case 13, name = 'TTCL'; signal = TV(i_TTCL,:)';
        case 14, name = 'TTCR'; signal = TV(i_TTCR,:)';
        case 15, name = 'TBCD'; signal = TV(i_TBCD,:)';
        case 16, name = 'TBCL'; signal = TV(i_TBCL,:)';
        case 17, name = 'NA'; signal = TV(i_NA,:)';
        case 18, name = 'GLO'; signal = TV(i_GLO,:)';
        case 19, name = 'F0'; signal = TV(i_F0,:)';
        case 20, name = 'PI'; signal = TV(i_PI,:)';
        case 21, name = 'SPI'; signal = TV(i_SPI,:)';
        case 22, name = 'TR'; signal = TV(i_TR,:)';
    end

    utt_struct(i).NAME = name;
    utt_struct(i).CHANNEL = n;
    utt_struct(i).SRATE = srate;
    utt_struct(i).SIGNAL = signal;
    
    sz_signal = size(signal, 2);
    if sz_signal > 1
        utt_struct(i).SCALING.TYPE = 'COMMON';
    else
        utt_struct(i).SCALING.TYPE = 'UNIQUE';
    end
    range = [];
    for j = 1:sz_signal
        min_t = min(signal(:,j));
        max_t = max(signal(:,j));
        % to make room beyond limits
        rng = max_t - min_t;
        if rng == 0
            rng = 1;
        end
        max_t = max_t + rng/5;
        min_t = min_t - rng/5;
        
        range = [range; [min_t max_t]];
    end

    if sz_signal == 1 & range == [0 0]
        range = [0 1];
    end
    utt_struct(i).SCALING.RANGE = range;
end

sav_struct(find(sav_struct == '#')) = '_';

% added by HN 02/08
if iskeyword(sav_struct)
    sav_struct = [sav_struct '_'];
end

ren_str = [sav_struct,' = utt_struct;'];
eval(ren_str)

sav_str = ['save ' sav_struct ' ' sav_struct ' -v6'];
% eval(sav_str)

% temporarily for creating mview data structure 03/05
utt_struct = rmfield(utt_struct, {'SCALING', 'LABELS'});
utt_struct = utt_struct([1:5 7:9]);

name_art = {'LX' 'JA' 'UY' 'LY' 'CL' 'CA' 'NA' 'GW' 'TL' 'TA' 'F0a' 'PIa' 'SPIa' 'HX'};
for i=1:nARTIC
    utt_struct(end+1).NAME = name_art{i};
    utt_struct(end).CHANNEL = utt_struct(end-1).CHANNEL+1;
    utt_struct(end).SRATE = srate;
    utt_struct(end).SIGNAL = A(i,:)';
end

ADOT=state.ADOT;
name_artdot = {'LX_vl' 'JA_vl' 'UY_vl' 'LY_vl' 'CL_vl' 'CA_vl' 'NA_vl' 'GW_vl' 'TL_vl' 'TA_vl' 'F0a_vl' 'PIa_vl' 'SPIa_vl' 'HX_vl'};
for i=1:nARTIC
    utt_struct(end+1).NAME = name_artdot{i};
    utt_struct(end).CHANNEL = utt_struct(end-1).CHANNEL+1;
    utt_struct(end).SRATE = srate;
    utt_struct(end).SIGNAL = ADOT(i,:)';
end

TV = state.TV;
name_tv = {'PRO' 'LA' 'TBCL' 'TBCD' 'JAW' 'VEL' 'GLO' 'TTCL' 'TTCD' 'TTCR' 'F0' 'PI' 'SPI' 'TRt'};
for i=[1:4 6:nTV]
    utt_struct(end+1).NAME = name_tv{i};
    utt_struct(end).CHANNEL = utt_struct(end-1).CHANNEL+1;
    utt_struct(end).SRATE = srate;
    utt_struct(end).SIGNAL = TV(i,:)';
end

TV_SCORE = state.TV_SCORE;
name_tv = {'gPRO' 'gLA' 'gTBCL' 'gTBCD' 'gJAW' 'gVEL' 'gGLO' 'gTTCL' 'gTTCD' 'gTTCR' 'gF0' 'gPI' 'gSPI' 'gTR'};
for i=[1:4 6:nTV]
    utt_struct(end+1).NAME = name_tv{i};
    utt_struct(end).CHANNEL = utt_struct(end-1).CHANNEL+1;
    utt_struct(end).SRATE = srate;
    utt_struct(end).SIGNAL = TV_SCORE(i).TV.PROMSUM';
end


if strcmpi(sav_struct(end), '_')
    sav_struct = sav_struct(1:end-1);
end

ren_str = [sav_struct, '_mv',' = utt_struct;'];
eval(ren_str)

sav_str = ['save ' sav_struct '_mv ' sav_struct '_mv -v6;'];
eval(sav_str)