function varargout = tada(varargin)
% TAsk-Dynamic speech production model
%
% Copyright Haskins Laboratories, Inc., 2000-2007
% 300 George Street, New Haven, CT 06514, USA
% written by Hosung Nam (hosung.nam@yale.edu)
%
% usage: tada                % launch GUI
%        tada args           %(generate and)evaluate tv_.o ph_.o generating tv_.G, .wav, .hl, .mat (mavis & mview)
%             tada filename  % evaluate pre-generated <tv_.o ph_.o> or <tv_.g>
%                  e.g. tada 'test'   % evaluate pre-generated <tvtest.o & phtest.o> or <tvtest.g>
%             tada filename GestInput % generate <tv_.o & ph_.o> for input utterance in gest and evaluate them
%                  e.g. tada 'test' '(PIYN)(PIHT)' or tada 'test' 'bad'
%                           This generates <tvtest.o & phtest.o>, <tvtest.g>, <test.wav>, <test.hl>, <test.mat>, <test_mv.mat>
%             tada 'all'     % evaluate all the .o files in the current directory
%
% The latest version is available in http://www.haskins.yale.edu/tada_download/index.html

% Last Modified by GUIDE v2.5 17-Jan-2008 16:43:28

err_msg = 'Type ''help tada'' for usage';
if nargin == 0  % LAUNCH GUI
    
    fig = openfig(mfilename,'new');    
    
    % Generate a structure of handles to pass to callbacks, and store it. 
    handles = guihandles(fig);
    
    
    if nargout > 0
        varargout{1} = fig;
    end
    
    hyoid = [7.142857142857143e+001 7.410714285714286e+001];
    pal = [6.678571428571429e+001    4.732142857142858e+001;...
    6.607142857142857e+001    5.116071428571429e+001;...
    6.517857142857143e+001    5.616071428571429e+001;...
    6.437500000000000e+001    6.116071428571429e+001;...
    5.517857142857143e+001    6.616071428571429e+001;...
    5.517857142857143e+001    7.116071428571429e+001;...
    5.517857142857143e+001    7.616071428571429e+001;...
    5.517857142857143e+001    8.116071428571429e+001;...
    5.517857142857143e+001    8.616071428571429e+001;...
    5.517857142857143e+001    9.116071428571429e+001;...
    5.517857142857143e+001    9.616071428571429e+001;...
    5.517857142857143e+001    1.011607142857143e+002;...
    5.517857142857143e+001    1.061607142857143e+002;...
    5.517857142857143e+001    1.119642857142857e+002;...
    5.517857142857143e+001    1.182142857142857e+002;...
    5.696428571428572e+001    1.242857142857143e+002;...
    6.017857142857143e+001    1.297321428571429e+002;...
    6.428571428571429e+001    1.347321428571429e+002;...
    6.928571428571429e+001    1.391071428571429e+002;...
    7.508928571428572e+001    1.425000000000000e+002;...
    8.151785714285715e+001    1.449107142857143e+002;...
    8.830357142857143e+001    1.461607142857143e+002;...
    9.339285714285715e+001    1.458035714285714e+002;...
    9.839285714285715e+001    1.450000000000000e+002;...
    1.033928571428572e+002    1.435714285714286e+002;...
    1.083928571428572e+002    1.415178571428571e+002;...
    1.133928571428572e+002    1.387500000000000e+002;...
    1.183928571428572e+002    1.350000000000000e+002;...
    1.233928571428572e+002    1.331250000000000e+002;...
    1.283928571428571e+002    1.312500000000000e+002;...
    1.320535714285714e+002    1.302678571428571e+002];


state = struct('BTNDOWN', [],...
    'SELBTNDN', [],...
    'PREVPNT', [],...
    'PAL', pal,...
    'HYOID', hyoid,...
    'srate', [],...
    'A', [],...
    'ADOT', [],...
    'CPLAY', 50,...
    'AREA', [],...
    'TUBELENGTHSMOOTH', [],...
    'UPPEROUTLINE', [],...
    'BOTTOMOUTLINE', [],...
    'TV_SCORE', [],...
    'TV', [],...
    'ART', [],...
    'ASYPEL', [],...
    'ms_frm', [],...
    'last_frm', [],...
    'n_frm', [],...
    'sig', [],...
    'curfrm', [],...
    'cur_x', [],...
    'OSC_flg', [],...
    'OSC', [],...
    'ngest', [],...
    'i_TV', [],...         % which TV panel clicked (only gestural boxes)
    'str_TV', [],...
    'uttname', [],...
    'fname', [],...
    'pname', [],...
    't_scaled', [],...
    'path', [],...
    'oscSimParams', [150 100 1 .05 NaN 1],...    % Sim Time, settle Time, RelTol, MaxStep, InitialStep, refine
    'oscSimNoise', [0 0 0 2],... %nz_task, nz_comp, nz_freq, sim_type (see hybrid_osc.m) 
    'clicked_cur_x', [],...
    'h_rt_selGest', [],...
    'sel_ngests', [],...
    'sel_iTVs', [],...
    'MOVGESTBTN', 0,...
    'MODGESTBTN', 0,...
    'speechRate', 1,...
    'F', []);

    set(handles.ax_line, 'color', 'none')

    set(gcf,'CurrentAxes',handles.ax_line)
    set(handles.ax_line, 'XLim', [0 1])
    line([0 0], [0 .925], 'color', [.6 .6 .6],...
        'Tag', 'ln_cl', 'hitTest', 'off'); % cursor line

    set(gcf,'CurrentAxes',handles.ax_audioall)
    line(0, 0, 'color', 'white', 'tag', 'ln_audioall', 'hittest', 'off');
    xl = get(handles.ax_audioall, 'xlim');
    yl = get(handles.ax_audioall, 'ylim');
    
    patch([xl(1) xl(1) xl(2) xl(2)], [yl(1) yl(2) yl(2) yl(1)], [.3 .3 .3], 'FaceAlpha', .75, 'edgecolor', [.3 .3 .3], 'tag', 'pc_sel');

    set(gcf,'CurrentAxes',handles.ax_pi)
    line(0, 0, 'color', 'w', 'tag', 'ln_gs_pi', 'hittest', 'off');
    line(0, 0, 'color', [.5 1 .5], 'tag', 'ln_tv_pi', 'hittest', 'off');

    set(gcf,'CurrentAxes',handles.ax_glo)
    line(0, 0, 'color', 'w', 'tag', 'ln_gs_glo', 'hittest', 'off');
    line(0, 0, 'color', [.4 .4 .4], 'tag', 'ln_tv_glo', 'hittest', 'off');

    set(gcf,'CurrentAxes',handles.ax_vel)
    line(0, 0, 'color', 'w', 'tag', 'ln_gs_vel', 'hittest', 'off');
    line(0, 0, 'color', [.4 .4 .4], 'tag', 'ln_tv_vel', 'hittest', 'off');

    set(gcf,'CurrentAxes',handles.ax_tt)
    line(0, 0, 'color', 'w', 'tag', 'ln_gs_tt', 'hittest', 'off');
    line(0, 0, 'color', [.4 .4 .4], 'tag', 'ln_tv_tt', 'hittest', 'off');

    set(gcf,'CurrentAxes',handles.ax_tb)
    line(0, 0, 'color', 'w', 'tag', 'ln_gs_tb', 'hittest', 'off');
    line(0, 0, 'color', [.4 .4 .4], 'tag', 'ln_tv_tb', 'hittest', 'off');

    set(gcf,'CurrentAxes',handles.ax_lips)
    line(0, 0, 'color', 'w', 'tag', 'ln_gs_lips', 'hittest', 'off');
    line(0, 0, 'color', [.4 .4 .4], 'tag', 'ln_tv_lips', 'hittest', 'off');

    set(gcf,'CurrentAxes',handles.ax_jaw)
    line(0, 0, 'color', 'w', 'tag', 'ln_gs_jaw', 'hittest', 'off');
    line(0, 0, 'color', [.4 .4 .4], 'tag', 'ln_tv_jaw', 'hittest', 'off');

    set(gcf,'CurrentAxes',handles.ax_F0)
    line(0, 0, 'color', 'w', 'tag', 'ln_gs_F0', 'hittest', 'off');
    line(0, 0, 'color', [.4 .4 .4], 'tag', 'ln_tv_F0', 'hittest', 'off');

    set(gcf,'CurrentAxes',handles.ax_spi)
    line(0, 0, 'color', 'w', 'tag', 'ln_gs_spi', 'hittest', 'off', 'visible', 'off'); %currently, initial display off
    line(0, 0, 'color', [.4 .4 .4], 'tag', 'ln_tv_spi', 'hittest', 'off', 'visible', 'off'); %currently, initial display off

    set(gcf,'CurrentAxes',handles.ax_tr)
    line(0, 0, 'color', 'w', 'tag', 'ln_gs_tr', 'hittest', 'off', 'visible', 'off'); %currently, initial display off
    line(0, 0, 'color', [.4 .4 .4], 'tag', 'ln_tv_tr', 'hittest', 'off', 'visible', 'off'); %currently, initial display off
    
    set(gcf,'CurrentAxes',handles.ax_audiosel)
    line(0, 0, 'color', 'w', 'tag', 'ln_audiosel', 'hittest', 'off');
    
    
    spatColors = hsv(7);

    set(gcf,'CurrentAxes',handles.ax_asy_ul)
    line(0, 0, 'color', spatColors(1,:)/3, 'tag', 'ln_asy_ulx', 'hittest', 'off');
    line(0, 0, 'color', spatColors(1,:), 'tag', 'ln_asy_uly', 'hittest', 'off');

    set(gcf,'CurrentAxes',handles.ax_asy_ll)
    line(0, 0, 'color', spatColors(2,:)/3, 'tag', 'ln_asy_llx', 'hittest', 'off');
    line(0, 0, 'color', spatColors(2,:), 'tag', 'ln_asy_lly', 'hittest', 'off');

    set(gcf,'CurrentAxes',handles.ax_asy_jaw)
    line(0, 0, 'color', spatColors(3,:)/3, 'tag', 'ln_asy_jawx', 'hittest', 'off', 'visible', 'off');
    line(0, 0, 'color', spatColors(3,:), 'tag', 'ln_asy_jawy', 'hittest', 'off', 'visible', 'off');

    set(gcf,'CurrentAxes',handles.ax_asy_tt)
    line(0, 0, 'color', spatColors(4,:)/3, 'tag', 'ln_asy_ttx', 'hittest', 'off');
    line(0, 0, 'color', spatColors(4,:), 'tag', 'ln_asy_tty', 'hittest', 'off');
    
    set(gcf,'CurrentAxes',handles.ax_asy_tf)
    line(0, 0, 'color', spatColors(5,:)/3, 'tag', 'ln_asy_tfx', 'hittest', 'off'); 
    line(0, 0, 'color', spatColors(5,:), 'tag', 'ln_asy_tfy', 'hittest', 'off'); 

    set(gcf,'CurrentAxes',handles.ax_asy_td)
    line(0, 0, 'color', spatColors(6,:)/3, 'tag', 'ln_asy_tdx', 'hittest', 'off', 'visible', 'off'); %currently, initial display off
    line(0, 0, 'color', spatColors(6,:), 'tag', 'ln_asy_tdy', 'hittest', 'off', 'visible', 'off'); %currently, initial display off
    
    set(gcf,'CurrentAxes',handles.ax_asy_tr)
    line(0, 0, 'color', spatColors(7,:)/3, 'tag', 'ln_asy_trx', 'hittest', 'off', 'visible', 'off'); %currently, initial display off
    line(0, 0, 'color', spatColors(7,:), 'tag', 'ln_asy_try', 'hittest', 'off', 'visible', 'off'); %currently, initial display off
    
    
    set(gcf,'CurrentAxes',handles.ax_asypel)
    set(handles.ax_asypel, 'XLim', [50 150], 'YLim', [40 160])
    
    
    line (50, 40, 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 20, 'tag', 'ln_pels_ul', 'color', spatColors(1, :), 'hittest', 'off');
    line (50, 40, 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 20, 'tag', 'ln_pels_ll', 'color', spatColors(2, :), 'hittest', 'off');
    line (50, 40, 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 20, 'tag', 'ln_pels_jaw', 'color', spatColors(3, :), 'hittest', 'off');
    line (50, 40, 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 20, 'tag', 'ln_pels_tt', 'color', spatColors(4, :), 'hittest', 'off');
    line (50, 40, 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 20, 'tag', 'ln_pels_tf', 'color', spatColors(5, :), 'hittest', 'off');
    line (50, 40, 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 20, 'tag', 'ln_pels_td', 'color', spatColors(6, :), 'hittest', 'off');
    line (50, 40, 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 20, 'tag', 'ln_pels_tr', 'color', spatColors(7, :), 'hittest', 'off');
   
    line (50, 40, 'LineStyle', '-', 'tag', 'ln_intpl', 'color', [.4 .4 .4], 'hittest', 'off');
    line (50, 40, 'LineStyle', '-', 'tag', 'ln_pal', 'color', 'y', 'hittest', 'off'); % draw palate


    set(gcf,'CurrentAxes',handles.ax_a_lx)
    line(0, 0, 'color', spatColors(1,:)/2, 'tag', 'ln_a_lx', 'hittest', 'off', 'visible', 'off');

    set(gcf,'CurrentAxes',handles.ax_a_ja)
    line(0, 0, 'color', spatColors(1,:)/2, 'tag', 'ln_a_ja', 'hittest', 'off', 'visible', 'off');
    
    set(gcf,'CurrentAxes',handles.ax_a_uy)
    line(0, 0, 'color', spatColors(1,:)/2, 'tag', 'ln_a_uy', 'hittest', 'off', 'visible', 'off');

    set(gcf,'CurrentAxes',handles.ax_a_ly)
    line(0, 0, 'color', spatColors(1,:)/2, 'tag', 'ln_a_ly', 'hittest', 'off', 'visible', 'off');

    set(gcf,'CurrentAxes',handles.ax_a_cl)
    line(0, 0, 'color', spatColors(1,:)/2, 'tag', 'ln_a_cl', 'hittest', 'off', 'visible', 'off');

    set(gcf,'CurrentAxes',handles.ax_a_ca)
    line(0, 0, 'color', spatColors(1,:)/2, 'tag', 'ln_a_ca', 'hittest', 'off', 'visible', 'off');

    set(gcf,'CurrentAxes',handles.ax_a_tl)
    line(0, 0, 'color', spatColors(1,:)/2, 'tag', 'ln_a_tl', 'hittest', 'off', 'visible', 'off');

    set(gcf,'CurrentAxes',handles.ax_a_ta)
    line(0, 0, 'color', spatColors(1,:)/2, 'tag', 'ln_a_ta', 'hittest', 'off', 'visible', 'off');

    set(gcf,'CurrentAxes',handles.ax_a_na)
    line(0, 0, 'color', spatColors(1,:)/2, 'tag', 'ln_a_na', 'hittest', 'off', 'visible', 'off');

    set(gcf,'CurrentAxes',handles.ax_a_gw)
    line(0, 0, 'color', spatColors(1,:)/2, 'tag', 'ln_a_gw', 'hittest', 'off', 'visible', 'off');

    set(gcf,'CurrentAxes',handles.ax_area)
    line(0, 0, 'color', 'w', 'tag', 'ln_area', 'hittest', 'off');

    set(gcf,'CurrentAxes',handles.ax_casy)
    line(0, 0, 'color', 'y', 'tag', 'ln_upperoutline', 'hittest', 'off');
    line(0, 0, 'color', 'w', 'tag', 'ln_bottomoutline', 'hittest', 'off');
    line(0, 0, 'color', 'k', 'tag', 'ln_velumopen', 'hittest', 'off');
    set(handles.ax_casy, 'XLim', [50 150], 'YLim', [40 160])

    
    line (50, 40, 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 20, 'tag', 'cln_pels_ul', 'color', spatColors(1, :), 'hittest', 'off');
    line (50, 40, 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 20, 'tag', 'cln_pels_ll', 'color', spatColors(2, :), 'hittest', 'off');
    line (50, 40, 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 20, 'tag', 'cln_pels_jaw', 'color', spatColors(3, :), 'hittest', 'off');
    line (50, 40, 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 20, 'tag', 'cln_pels_tt', 'color', spatColors(4, :), 'hittest', 'off');
    line (50, 40, 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 20, 'tag', 'cln_pels_tf', 'color', spatColors(5, :), 'hittest', 'off');
    line (50, 40, 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 20, 'tag', 'cln_pels_td', 'color', spatColors(6, :), 'hittest', 'off');
    line (50, 40, 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 20, 'tag', 'cln_pels_tr', 'color', spatColors(7, :), 'hittest', 'off');
 
    
    set(gcf,'CurrentAxes',handles.ax_formants)
    line(0, 0, 'color', 'c', 'tag', 'ln_F1', 'hittest', 'off', 'visible', 'off');
    line(0, 0, 'color', 'w', 'tag', 'ln_F2', 'hittest', 'off', 'visible', 'off');
    line(0, 0, 'color', 'y', 'tag', 'ln_F3', 'hittest', 'off', 'visible', 'off');
    line(0, 0, 'color', 'm', 'tag', 'ln_F4', 'hittest', 'off', 'visible', 'off');

    
    
    % read tada.ini file and initialize
    tadadir = which ('tada');
    tadadir = tadadir(1:end-6);
    fp = fopen([tadadir 'tada.ini'], 'rt'); % open data file
   
    fscanf(fp, '%s', 1);
    flg_LowGraphic = fscanf(fp, '%d', 1);
    if ~isempty(flg_LowGraphic)
        if flg_LowGraphic, checked = 'on'; else checked = 'off'; end
    else
        checked = 'on';
    end
    set(handles.mn_LowGraphic, 'checked', checked);

    fscanf(fp, '%s', 1);
    prm_oscSimParams = [fscanf(fp, '%f', 1) fscanf(fp, '%f', 1) fscanf(fp, '%f', 1) fscanf(fp, '%f', 1) fscanf(fp, '%f', 1) fscanf(fp, '%f', 1)];
    if length(prm_oscSimParams) < 6
        prm_oscSimParams = [300 270 1 0.05 1.000000e-002 1];
    end
    state.oscSimParams = prm_oscSimParams;
    
    fscanf(fp, '%s', 1);
    prm_oscSimNoise = [fscanf(fp, '%f', 1) fscanf(fp, '%f', 1) fscanf(fp, '%f', 1) fscanf(fp, '%f', 1)];
    if length(prm_oscSimNoise) < 4
        prm_oscSimNoise = [0 0 0 2];
    end
    state.oscSimNoise = prm_oscSimNoise;
    
    fscanf(fp, '%s', 1);
    flg_proportionalFreq = fscanf(fp, '%d', 1);
    if ~isempty(flg_proportionalFreq)
        if flg_proportionalFreq, checked = 'on'; else checked = 'off'; end
    else
        checked = 'on';
    end
    set(handles.mn_proportionalFreq, 'checked', checked);
    
    fscanf(fp, '%s', 1);
    flg_apply2otherTVs = fscanf(fp, '%d', 1);
    if ~isempty(flg_apply2otherTVs)
        if flg_apply2otherTVs, checked = 'on'; else checked = 'off'; end
    else
        checked = 'on';
    end
    set(handles.mn_apply2otherTVs, 'checked', checked);
    
    fscanf(fp, '%s', 1);
    flg_genHL = fscanf(fp, '%d', 1);
    if ~isempty(flg_genHL)
        if flg_genHL, checked = 'on'; else checked = 'off'; end
    else
        checked = 'on';
    end
    set(handles.mn_genHL, 'checked', checked);
    
    fscanf(fp, '%s', 1);
    flg_PlotRelPhase = fscanf(fp, '%d', 1);
    if ~isempty(flg_PlotRelPhase)
        if flg_PlotRelPhase, checked = 'on'; else checked = 'off'; end
    else
        checked = 'on';
    end
    set(handles.mn_plotRelPhase, 'checked', checked);

    fscanf(fp, '%s', 1);
    flg_PlotCycleTicks = fscanf(fp, '%d', 1);
    if ~isempty(flg_PlotCycleTicks)
        if flg_PlotCycleTicks, checked = 'on'; else checked = 'off'; end
    else
        checked = 'on';
    end
    set(handles.mn_plotCycleTicks, 'checked', checked);
    
    fclose(fp);

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    handles = guihandles(fig);
    guidata(fig, handles);

    
    % knowhow...
    % handles = guihandles(fig);
    % 
    % !!!!!! here place new handles...
    %
    % handles = guihandles(fig);
    % guidata(fig, handles);
    

    
    
    
    
    
    
    
    
    
    
    %---------------------------------
    % Add paths m functions
    %
    tadaPath = which('tada');
    tadaPath = tadaPath(1:end-7);
    state.path = tadaPath;
    % delete the last 7 chars to get a path
    % addpath(tadaPath) ;
    if ispc
        addpath([tadaPath '\casy'], 0) ;  % 0 means the path will be in the front of search path
    else
        addpath([tadaPath '/casy'], 0) ;  % 0 means the path will be in the front of search path
    end
    % will be removed when closed

    
    
    

    % open a blank gestural score page
    fid_w = fopen(strcat('tvblank.g'), 'w');
    fprintf(fid_w, '%s\n', [num2str(10) ' ' num2str(100)]);
    fclose(fid_w);

    fstruct=dir('tvblank.g');
    if isempty(fstruct)
        return
    else
        fname=fstruct.name;
        pname=cd;
        utt_name = fstruct.name(3:end-2);
        state.OSC_flg = 0;
        gui_on_off(handles, state.OSC_flg)
        set(handles.mn_saveOscSim, 'Enable', 'off')

        state.TV_SCORE = [];
        state.utt_name = utt_name;
        state.fname = fname;
        state.pname = pname;
        set(handles.ed_uttname, 'String', utt_name)
        set(handles.pb_saveas, 'Enable', 'on')

        set(handles.cb_cos_ramp, 'value', 0)
        set(handles.cb_ramp_act, 'value', 0)
        set(handles.tb_gscore, 'value', 0)
        set(handles.tb_tv, 'value', 0)
        cd(state.pname)
        flg_pi = 0;
        clear_all_axis(handles, flg_pi)
        set(handles.tb_gscore, 'value', 1);
        set(handles.tada, 'userdata', state);
        tada('tb_gscore_Callback', handles.tb_gscore, [], handles)
        state = get(handles.tada, 'userdata');
        fclose all;
        delete(fname)
    end
    set(handles.tada, 'userdata', state);
    
elseif nargin <=2
    tvfiles = '';
    if nargin == 1 & ischar(varargin{1})
        if strcmpi(varargin{1}, 'all')
            tvfiles = 'TV*.O';
        else
            tvfiles = ['TV' varargin{1} '.G'];
        end
    end

    if nargin == 2 & ischar(varargin{1}) & ischar(varargin{2})
        gest(varargin{1}, varargin{2});
%         tvfiles = ['TV' varargin{1} '.G'];
    end

    struct_tvfiles = dir(tvfiles);
    tmp = which('tada');
    if isdir([tmp(1:end-6) 'source']), yesHLsyn = 1; else, yesHLsyn = 0; end
    
    if isempty(struct_tvfiles)
        struct_tvfiles = dir(['TV' varargin{1} '.O']);
        if ~isempty(struct_tvfiles)
            tada_woGUI(struct_tvfiles.name, yesHLsyn);
        else
            disp('File is not found')
            return
        end
    else
        for i = 1:length(struct_tvfiles)
            disp(['computing ' upper(struct_tvfiles(i).name(3:end-2)) '... ' num2str(i) ' of ' num2str(length(struct_tvfiles))]);
            tada_woGUI(struct_tvfiles(i).name, yesHLsyn)
        end
    end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

    try
        [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
    catch
        disp(lasterr); %temporarily commented
    end
else
    disp(err_msg); return
end


















%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.




% --------------------------------------------------------------------
function varargout = pb_editor_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.pb_editor.
%[fname,pname] = uigetfile('TV*.G*','TV files');

[fname,pname] = uigetfile( {'*.o', 'OSC files (*.O)';'*.g', 'TV files (*.G)'});

% if ispc
%     [fname,pname] = uigetfile( {'TV*.G*;TV*.g*;Tv*.G*;Tv*.g*;tV*.G*;tV*.g*;tv*.G*;tv*.g*;TV*.O*;TV*.o*;Tv*.O*;Tv*.o*;tV*.O*;tV*.o*;tv*.O*;tv*.o*; PH*.O*;PH*.o*;Ph*.O*;Ph*.o*;pH*.O*;pH*.o*;ph*.O*;ph*.o*', '.G or .O Files (TV*.G*, TV*.O*, or PH*.O*)'}, '.G or .O files');
% else   % due to the incompatibility btw Mac and uigetfile
%     [fname,pname] = uigetfile( {'*.g'; '*,o'}, 'TV.g, TV.o, PH.o files');
% end

if fname ~= 0
    open([pname fname])
end


% --------------------------------------------------------------------
function varargout = pb_browsefile_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.pb_browsefile.

state = get(handles.tada, 'userdata');

% delete all gestural boxes handles
delete(state.h_rt_selGest)
state.h_rt_selGest = [];
state.sel_ngests = [];
state.sel_iTVs = [];


if ispc
    [fname,pname] = uigetfile( {'*.g; *.o', 'TV files (*.G), OSC files (*.O)'});
else
    [fname,pname] = uigetfile( {'*.g; *.G; *.o; *.O', 'TV files (*.G), OSC files (*.O)'});
end

if fname ~= 0 & (strcmpi(fname(1:2), 'TV') | strcmpi(fname(1:2), 'PH'))
    tmp = find(fname == '.');
    if strcmpi(fname(3:4), 'TV')
        utt_name = fname (5: tmp(end)-1);
    else
        utt_name = fname (3: tmp(end)-1);
    end
    
    if strcmpi(fname(tmp(end)+1), 'O') % for tado
        state.OSC_flg = 1;
        gui_on_off(handles, state.OSC_flg)
        set(handles.mn_saveOscSim, 'Enable', 'on')
    elseif strcmpi(fname(tmp(end)+1), 'G') % for tada
        state.OSC_flg = 0;
        gui_on_off(handles, state.OSC_flg)
        set(handles.mn_saveOscSim, 'Enable', 'off')        
    end

    state.TV_SCORE = [];
    state.utt_name = utt_name;
    state.fname = fname;
    state.pname = pname;
    set(handles.ed_uttname, 'String', utt_name)
    set(handles.pb_saveas, 'Enable', 'on')

    set(handles.cb_cos_ramp, 'value', 0)
    set(handles.cb_ramp_act, 'value', 0)
    set(handles.tb_gscore, 'value', 0)
    set(handles.tb_tv, 'value', 0)
    cd(state.pname)
    set(handles.tada, 'userdata', state);
    flg_pi = 0;
    clear_all_axis(handles, flg_pi)
    set(handles.tb_gscore, 'value', 1);
    tada('tb_gscore_Callback', handles.tb_gscore, [], handles)
end


% --------------------------------------------------------------------
function varargout = pb_sound_Callback(h, eventdata, handles, varargin)
state = get(handles.tada, 'userdata');
sig = state.sig;
srate = state.srate;
n_frm = state.n_frm;


XLim = get(handles.ax_audiosel, 'XLim');
XLim = [ceil(XLim(1)) floor(XLim(2))];
soundsc(sig(floor(length(sig)*XLim(1)/n_frm)+1 : ceil(length(sig)*XLim(2)/n_frm)), srate)
% player = audioplayer(sig(floor(length(sig)*XLim(1)/n_frm)+1 : ceil(length(sig)*XLim(2)/n_frm)), srate);
% play(player)
% while isplaying(player) % to avoid returning audio object uncompleted
% end


% --- Executes on button press in pb_SaveWavAs.
function pb_SaveWavAs_Callback(hObject, eventdata, handles)
% hObject    handle to pb_SaveWavAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

state = get(handles.tada, 'userdata');
sig = state.sig;
srate = state.srate;
%utt_name = get(handles.ed_uttname, 'String');

XLim = get(handles.ax_audiosel, 'XLim');
c = round([XLim(1) XLim(2)]/200*srate);
if c(1)==0, c(1)=1; end
if c(2)>length(sig), c(2) = length(sig); end
sig = sig(c(1):c(2));

%audiowrite(sig, srate, [utt_name '.wav']);
[fname,pname] = uiputfile( ...
    {'*.WAV;*.WAv;*.wAV;*.WaV;*.Wav;*.wAv;*.waV;*.wav', 'WAV Files (*.wav)'}, 'Save WAV as');

if fname ~= 0
    sig = double(sig);
    sig = sig/max(abs(sig));
    warning off, audiowrite(fname, sig, srate); warning on
end

% --------------------------------------------------------------------
function mn_SaveWavAs_Callback(hObject, eventdata, handles)
% hObject    handle to mn_SaveWavAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tada('pb_SaveWavAs_Callback', handles.pb_SaveWavAs, [], handles)


% --------------------------------------------------------------------
function varargout = rb_cd_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.rb_cd.

set(handles.rb_cd, 'Value', 1)
set(handles.rb_cl, 'Value', 0)
set(handles.rb_cr, 'Value', 0)
load t_params
state = get(handles.tada, 'userdata');

if get(handles.tb_tv, 'value') == 1 | get(handles.tb_gscore, 'value') == 1
    if get(handles.tb_tv, 'value') == 1
        TV_SCORE = state.TV_SCORE;
        TV = state.TV;
        n_frm = state.n_frm;

        for i_TV = [i_LA i_TBCD i_TTCD]
            switch i_TV
                case i_LA
                    h_gs_ln = handles.ln_gs_lips;
                    h_tv_ln = handles.ln_tv_lips;
                    h_axes = handles.ax_lips;
                    set(handles.tx_lips, 'String', 'LA')
                case i_TBCD
                    h_gs_ln = handles.ln_gs_tb;
                    h_tv_ln = handles.ln_tv_tb;
                    h_axes = handles.ax_tb;
                    set(handles.tx_tb, 'String', 'TBCD')
                case i_TTCD
                    h_gs_ln = handles.ln_gs_tt;
                    h_tv_ln = handles.ln_tv_tt;
                    h_axes = handles.ax_tt;
                    set(handles.tx_tt, 'String', 'TTCD')
            end

            min_tmp = min(TV(i_TV,:));
            max_tmp = max(TV(i_TV,:));
            if min_tmp ==  max_tmp
                min_tmp = min_tmp -1;
                max_tmp = max_tmp +1;
            end

            set(h_gs_ln, 'xdata', 1:n_frm, 'ydata', TV_SCORE(i_TV).TV.PROMSUM/2*(max_tmp-min_tmp)+min_tmp);
            set(h_axes, 'XLim', [0 n_frm], 'YLim', [min_tmp max_tmp])
            set(h_tv_ln, 'xdata', 1:n_frm, 'ydata', TV(i_TV,:));
        end
        %refresh
    end
    if get(handles.tb_gscore, 'Value') == 1
        TV_SCORE = state.TV_SCORE;
        n_frm = state.n_frm;

        for i_TV = [i_LA i_TBCD i_TTCD]
            switch i_TV
                case i_LA
                    h_gs_ln = handles.ln_gs_lips;
                    h_axes = handles.ax_lips;
                    set(handles.tx_lips, 'String', 'LA')
                case i_TBCD
                    h_gs_ln = handles.ln_gs_tb;
                    h_axes = handles.ax_tb;
                    set(handles.tx_tb, 'String', 'TBCD')
                case i_TTCD
                    h_gs_ln = handles.ln_gs_tt;
                    h_axes = handles.ax_tt;
                    set(handles.tx_tt, 'String', 'TTCD')
            end
            set(h_gs_ln, 'xdata', 1:n_frm, 'ydata', TV_SCORE(i_TV).TV.PROMSUM);
            set(h_axes, 'XLim', [0 n_frm], 'YLim', [0 2])
        end
    end

    % zoom restore
    set(handles.ax_lips, 'XLim', get(handles.ax_audiosel, 'XLim'));
    set(handles.ax_tb, 'XLim', get(handles.ax_audiosel, 'XLim'));
    set(handles.ax_tt, 'XLim', get(handles.ax_audiosel, 'XLim'));
end


% --------------------------------------------------------------------
function varargout = rb_cl_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.rb_cl.

set(handles.rb_cd, 'Value', 0)
set(handles.rb_cl, 'Value', 1)
set(handles.rb_cr, 'Value', 0)
load t_params
state = get(handles.tada, 'userdata');

if get(handles.tb_tv, 'value') == 1 | get(handles.tb_gscore, 'value') == 1
    if get(handles.tb_tv, 'value') == 1
        TV_SCORE = state.TV_SCORE;
        TV = state.TV;
        n_frm = state.n_frm;
        
        for i_TV = [i_PRO i_TBCL i_TTCL]
            switch i_TV
                case i_PRO
                    h_gs_ln = handles.ln_gs_lips;
                    h_tv_ln = handles.ln_tv_lips;
                    h_axes = handles.ax_lips;
                    set(handles.tx_lips, 'String', 'PRO')
                case i_TBCL
                    h_gs_ln = handles.ln_gs_tb;
                    h_tv_ln = handles.ln_tv_tb;
                    h_axes = handles.ax_tb;
                    set(handles.tx_tb, 'String', 'TBCL')
                case i_TTCL
                    h_gs_ln = handles.ln_gs_tt;
                    h_tv_ln = handles.ln_tv_tt;
                    h_axes = handles.ax_tt;
                    set(handles.tx_tt, 'String', 'TTCL')
            end

            min_tmp = min(TV(i_TV,:));
            max_tmp = max(TV(i_TV,:));
            if min_tmp ==  max_tmp
                min_tmp = min_tmp -1;
                max_tmp = max_tmp +1;
            end

            set(h_gs_ln, 'xdata', 1:n_frm, 'ydata', TV_SCORE(i_TV).TV.PROMSUM/2*(max_tmp-min_tmp)+min_tmp);
            set(h_axes, 'XLim', [0 n_frm], 'YLim', [min_tmp max_tmp])
            set(h_tv_ln, 'xdata', 1:n_frm, 'ydata', TV(i_TV,:));
        end
        %refresh
    end
    
    if get(handles.tb_gscore, 'Value') == 1
        TV_SCORE = state.TV_SCORE;
        n_frm = state.n_frm;
        
        for i_TV = [i_PRO i_TBCL i_TTCL]
            switch i_TV
                case i_PRO
                    h_gs_ln = handles.ln_gs_lips;
                    h_axes = handles.ax_lips;
                    set(handles.tx_lips, 'String', 'PRO')
                case i_TBCL
                    h_gs_ln = handles.ln_gs_tb;
                    h_axes = handles.ax_tb;
                    set(handles.tx_tb, 'String', 'TBCL')
                case i_TTCL
                    h_gs_ln = handles.ln_gs_tt;
                    h_axes = handles.ax_tt;
                    set(handles.tx_tt, 'String', 'TTCL')
            end

            set(h_gs_ln, 'xdata', 1:n_frm, 'ydata', TV_SCORE(i_TV).TV.PROMSUM);
            set(h_axes, 'XLim', [0 n_frm], 'YLim', [0 2])        
        end
    end
    
   
    % zoom restore
    set(handles.ax_lips, 'XLim', get(handles.ax_audiosel, 'XLim'));
    set(handles.ax_tb, 'XLim', get(handles.ax_audiosel, 'XLim'));
    set(handles.ax_tt, 'XLim', get(handles.ax_audiosel, 'XLim'));
end


% --------------------------------------------------------------------
function varargout = rb_cr_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.rb_cr.

set(handles.rb_cd, 'Value', 0)
set(handles.rb_cl, 'Value', 0)
set(handles.rb_cr, 'Value', 1)
load t_params
state = get(handles.tada, 'userdata');

if get(handles.tb_tv, 'value') == 1 | get(handles.tb_gscore, 'value') == 1
    if get(handles.tb_tv, 'Value') == 1
        TV_SCORE = state.TV_SCORE;
        TV = state.TV;
        n_frm = state.n_frm;

        set(handles.tx_tt, 'String', 'TTCR')
        
        min_tmp = min(TV(i_TTCR,:));
        max_tmp = max(TV(i_TTCR,:));
        if min_tmp ==  max_tmp
            min_tmp = min_tmp -1;
            max_tmp = max_tmp +1;
        end

        set(handles.ln_gs_tt, 'xdata', 1:n_frm, 'ydata', TV_SCORE(i_TTCR).TV.PROMSUM/2*(max_tmp-min_tmp)+min_tmp);
        set(handles.ax_tt, 'XLim', [0 n_frm], 'YLim', [min_tmp max_tmp])
        set(handles.ln_tv_tt, 'xdata', 1:n_frm, 'ydata', TV(i_TTCR,:));
        %refresh
    end
    
    if get(handles.tb_gscore, 'Value') == 1
        
        TV_SCORE = state.TV_SCORE;
        n_frm = state.n_frm;
                
        set(handles.tx_tt, 'String', 'TTCR')
        set(handles.ln_gs_tt, 'xdata', 1:n_frm, 'ydata', TV_SCORE(i_TTCR).TV.PROMSUM);
        set(handles.ax_tt, 'XLim', [0 n_frm], 'YLim', [0 2])
    end
    
    % zoom restore
    set(handles.ax_tt, 'XLim', get(handles.ax_audiosel, 'XLim'));
end

% --------------------------------------------------------------------
function varargout = tb_gscore_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.tb_gscore.
load t_params
global n_rampfrm
global ramp_style

state = get(handles.tada, 'userdata');

if get(handles.tb_tv, 'Value') == 1
    set(handles.tb_tv, 'value', 0) 
end

n_rampfrm = str2num(get(handles.ed_ramp_frm, 'String'));
ramp_style = get(handles.cb_cos_ramp, 'Value');

if get(handles.tb_gscore, 'Value') == 1 % if toggle on
    rbutton3 = get(handles.rb_cr, 'Value');
    
    if rbutton3 == 1
        set(handles.rb_cd, 'Value', 1);
        set(handles.rb_cr, 'Value', 0);
        rbutton3 = get(handles.rb_cr, 'Value');
    end    
    rbutton1 = get(handles.rb_cd, 'Value');
    rbutton2 = get(handles.rb_cl, 'Value');
    
    if isempty(get(handles.ed_uttname, 'String'))
        set(handles.tb_gscore, 'Value', 0)
        errordlg('Utterance not found')
        return
    end

    tadaname = get(handles.tada, 'Name');
    utt_name = get(handles.ed_uttname, 'String');
    if ~strcmp(tadaname(1:2), 'Pi')
        flg_pi = 0;
    else
        flg_pi = 1;
    end
    clear_all_axis(handles, flg_pi)
    utt_name = get(handles.ed_uttname, 'String');
    
    % generating "TV_SCORE"
    if isempty(state.TV_SCORE) %when open tv file
        if state.OSC_flg % if it's for TADO
            [OSC] = make_osc(utt_name, state, handles);
            state.OSC = OSC;
            [TV_SCORE, ART, ms_frm, last_frm, sylBegEnd] = make_osc2gest(utt_name, OSC);
        else
            [TV_SCORE, ART, ms_frm, last_frm] = make_gest(utt_name);
            
            % comment off to extract/view noBlend gestural score (w/o REL,
            % secondary gesture). TB_v only for TB if 2nd arg = 1. 
            % Both TB_V and TB_c if 2nd arg = 2
%             [TV_SCORE, ART, ms_frm, last_frm] = make_gest_noBlend(utt_name, 2);

            if get(handles.cb_ramp_act, 'Value') % when ramp act checked
                [TV_SCORE] = make_rampprom(TV_SCORE, ms_frm, last_frm);
            else % when ramp act unchecked
                [TV_SCORE] = make_prom(TV_SCORE, ms_frm, last_frm); % compute PROM and make fake PRO
            end
        end
        [TV_SCORE, ART] = make_tvscore(TV_SCORE, ART, ms_frm, last_frm);
    else %when reuse TV_SCORE 
        TV_SCORE = state.TV_SCORE;
        ART = state.ART;
        n_frm = state.n_frm;
        ms_frm = state.ms_frm;
        last_frm=n_frm/ms_frm*wag_frm;
        if ~state.OSC_flg
            TV_SCORE_OLD = TV_SCORE; % used only for pi
            [TV_SCORE, ART] = init_tvscore(TV_SCORE, ART, n_frm); % initialize TV_SCORE and ART except basic gestural parameters
            if strcmp(tadaname(1:2), 'Pi')% when pi_applied
                t_scaled = state.t_scaled;
                [TV_SCORE] = make_piPROM (TV_SCORE, TV_SCORE_OLD, n_frm, t_scaled);
            else
                if get(handles.cb_ramp_act, 'Value') % when ramp act checked
                    [TV_SCORE] = make_rampprom(TV_SCORE, ms_frm, last_frm);
                else % when ramp act unchecked
                    [TV_SCORE] = make_prom(TV_SCORE, ms_frm, last_frm); % compute PROM and make fake PRO
                end
            end
            [TV_SCORE, ART] = make_tvscore(TV_SCORE, ART, ms_frm, last_frm); %recompute TV_SCORE
        end
    end

    if ~state.OSC_flg
        set(handles.cb_ramp_act, 'Enable', 'on')
        if get(handles.cb_ramp_act, 'value') == 1
            set(handles.cb_cos_ramp, 'Enable', 'on')
        end
    end

    n_frm = (last_frm)*ms_frm/wag_frm;
    % display an assosicated acoustic file if any
    fn1 = ffind_case([utt_name,'.wav']);
    fn2 = ffind_case(['W',utt_name,'.PCM']);
    
    if ~isempty(fn1)
        [sig srate] = audioread(fn1);
        sig = double(sig);
        sig = sig/max(abs(sig));
        sig = sig';
        set(handles.ln_audioall, 'xdata', 1/length(sig)*n_frm:1/length(sig)*n_frm:n_frm, 'ydata', sig);
        set(handles.ln_audiosel, 'xdata', 1/length(sig)*n_frm:1/length(sig)*n_frm:n_frm, 'ydata', sig);
    elseif ~isempty(fn2)
        [sig srate] = PCMread(fn2);
        sig = double(sig);
        sig = sig/max(abs(sig));
        set(handles.ln_audioall, 'xdata', 1/length(sig)*n_frm:1/length(sig)*n_frm:n_frm, 'ydata', sig);
        set(handles.ln_audiosel, 'xdata', 1/length(sig)*n_frm:1/length(sig)*n_frm:n_frm, 'ydata', sig);
    else
        sig = []; srate = []; % to temporarily avoid warning
    end

    set([handles.ax_audioall handles.ax_audiosel], 'XLim', [0 n_frm], 'YLim', [-1 1])
    set(handles.pc_sel, 'xdata', [0 0 n_frm n_frm]);
    set(handles.ax_audiosel, 'XLim', [0 n_frm], 'YLim', [-1 1])
    
    set(handles.ln_gs_vel, 'xdata', 1:n_frm, 'ydata', TV_SCORE(i_VEL).TV.PROMSUM);
    set(handles.ax_vel, 'XLim', [0 n_frm], 'YLim', [0 2])
    
    set(handles.ln_gs_jaw, 'xdata', 1:n_frm, 'ydata', TV_SCORE(i_JAW).TV.PROMSUM);
    set(handles.ax_jaw, 'XLim', [0 n_frm], 'YLim', [0 2])

    set(handles.ln_gs_glo, 'xdata', 1:n_frm, 'ydata', TV_SCORE(i_GLO).TV.PROMSUM);
    set(handles.ax_glo, 'XLim', [0 n_frm], 'YLim', [0 2])
    
    set(handles.ln_gs_F0, 'xdata', 1:n_frm, 'ydata', TV_SCORE(i_F0).TV.PROMSUM);
    set(handles.ax_F0, 'XLim', [0 n_frm], 'YLim', [0 2])

    set(handles.ln_gs_pi, 'xdata', 1:n_frm, 'ydata', TV_SCORE(i_PI).TV.PROMSUM);
    set(handles.ax_pi, 'XLim', [0 n_frm], 'YLim', [-2 2])
    
    set(handles.ln_gs_spi, 'xdata', 1:n_frm, 'ydata', TV_SCORE(i_SPI).TV.PROMSUM);
    set(handles.ax_spi, 'XLim', [0 n_frm], 'YLim', [-1 1])

    set(handles.ln_gs_tr, 'xdata', 1:n_frm, 'ydata', TV_SCORE(i_TR).TV.PROMSUM);
    set(handles.ax_tr, 'XLim', [0 n_frm], 'YLim', [0 2])
    
    set(handles.ax_line, 'XLim', [0 n_frm], 'YLim', [0 1]) %HN
    
    if rbutton1 == 1
        for i_TV = [i_LA i_TBCD i_TTCD]
            switch i_TV
                case i_LA
                    h_axes = handles.ax_lips;
                    set(handles.tx_lips, 'String', 'LA')
                    set(handles.ln_gs_lips, 'xdata', 1:n_frm, 'ydata', TV_SCORE(i_TV).TV.PROMSUM)
                case i_TBCD
                    h_axes = handles.ax_tb;
                    set(handles.tx_tb, 'String', 'TBCD')
                    set(handles.ln_gs_tb, 'xdata', 1:n_frm, 'ydata', TV_SCORE(i_TV).TV.PROMSUM)
                case i_TTCD
                    h_axes = handles.ax_tt;
                    set(handles.tx_tt, 'String', 'TTCD')
                    set(handles.ln_gs_tt, 'xdata', 1:n_frm, 'ydata', TV_SCORE(i_TV).TV.PROMSUM)
            end
            set(h_axes, 'XLim', [0 n_frm], 'YLim', [0 2])
        end
        set(handles.rb_cr, 'Enable', 'on')
    end    
    
    if rbutton2 == 1
        for i_TV = [i_PRO i_TBCL i_TTCL]
            switch i_TV
                case i_PRO
                    h_axes = handles.ax_lips;
                    set(handles.tx_lips, 'String', 'PRO')
                    set(handles.ln_gs_lips, 'xdata', 1:n_frm, 'ydata', TV_SCORE(i_TV).TV.PROMSUM)
                case i_TBCL
                    h_axes = handles.ax_tb;
                    set(handles.tx_tb, 'String', 'TBCL')
                    set(handles.ln_gs_tb, 'xdata', 1:n_frm, 'ydata', TV_SCORE(i_TV).TV.PROMSUM)
                case i_TTCL
                    h_axes = handles.ax_tt;
                    set(handles.tx_tt, 'String', 'TTCL')
                    set(handles.ln_gs_tt, 'xdata', 1:n_frm, 'ydata', TV_SCORE(i_TV).TV.PROMSUM)
            end
            
            set(h_axes, 'XLim', [0 n_frm], 'YLim', [0 2])
        end
        set(handles.rb_cr, 'Enable', 'on')
    end
  
    state.TV_SCORE = TV_SCORE;
    state.ART = ART;
    state.n_frm = n_frm;
    state.sig = sig;
    state.srate = srate;
    state.ms_frm = ms_frm;
    state.last_frm = last_frm;
    
    %reset cursors    % cursors now already deleted due to newly-drawn axis
    % error ocurrs... to avoid... this line added
    state.curfrm = [];
    %reset current point
    state.tx_curfrm = [];    
elseif get(handles.tb_gscore, 'value') == 0
    set(handles.tb_gscore, 'value', 1)
end

set(handles.tada, 'userdata', state)


function [TV_SCORE, ART] = init_tvscore (TV_SCORE, ART, n_frm)
% initialize TV_SCORE and ART except basic gestural parameters:
% TV_SCORE.GEST (BEG, END, PROM, x, k, d, w)

load t_params
for i = 1:size(TV_SCORE, 2)
    for j = 1:size(TV_SCORE(i).GEST, 2)
        TV_SCORE(i).GEST(j).PROM = zeros(1,n_frm);
        TV_SCORE(i).GEST(j).x.PROM_BLEND = zeros(1,n_frm);
        TV_SCORE(i).GEST(j).k.PROM_BLEND = zeros(1,n_frm);
        TV_SCORE(i).GEST(j).d.PROM_BLEND = zeros(1,n_frm);
        TV_SCORE(i).GEST(j).w.PROM_BLEND = zeros(1,n_frm);
        TV_SCORE(i).GEST(j).x.PROMSUM_BLEND = zeros(1,n_frm);
        TV_SCORE(i).GEST(j).k.PROMSUM_BLEND = zeros(1,n_frm);
        TV_SCORE(i).GEST(j).d.PROMSUM_BLEND = zeros(1,n_frm);
        TV_SCORE(i).GEST(j).w.PROMSUM_BLEND = zeros(1,n_frm);
        TV_SCORE(i).GEST(j).PROM_BLEND_SYN = zeros(1,n_frm);
        TV_SCORE(i).GEST(j).PROMSUM_BLEND_SYN = zeros(1,n_frm);
        TV_SCORE(i).TV.PROMSUM = zeros(1,n_frm);
        TV_SCORE(i).TV.PROM_ACT = zeros(1,n_frm);
        TV_SCORE(i).TV.x_BLEND = zeros(1,n_frm);
        TV_SCORE(i).TV.k_BLEND = zeros(1,n_frm);
        TV_SCORE(i).TV.d_BLEND = zeros(1,n_frm);
        TV_SCORE(i).TV.WGT_TV = zeros(n_frm, nARTIC);
    end
end

%     TV_SCORE(1:nTV) = struct(...        
%         'GEST', struct(...
%         'BEG', [0],...
%         'END', [0],...
%         'PROM', zeros(1,n_frm),...
%         'x', struct('VALUE', [0], 'ALPHA', [0], 'BETA', [0], 'PROM_BLEND', zeros(1,n_frm), 'PROMSUM_BLEND', zeros(1,n_frm)),...
%         'k', struct('VALUE', [0], 'ALPHA', [0], 'BETA', [0], 'PROM_BLEND', zeros(1,n_frm), 'PROMSUM_BLEND', zeros(1,n_frm)),...
%         'd', struct('VALUE', [0], 'ALPHA', [0], 'BETA', [0], 'PROM_BLEND', zeros(1,n_frm), 'PROMSUM_BLEND', zeros(1,n_frm)),...
%         'w', struct('VALUE', zeros(1,nARTIC), 'ALPHA', [0], 'BETA', [0], 'PROM_BLEND', zeros(1,n_frm), 'PROMSUM_BLEND', zeros(1,n_frm)),...
%         'PROM_BLEND_SYN', zeros(1,n_frm),...
%         'PROMSUM_BLEND_SYN', zeros(1,n_frm)),...
%         'TV', struct(...
%         'PROMSUM', zeros(1,n_frm),...
%         'PROM_ACT', zeros(1,n_frm),...
%         'x_BLEND', zeros(1,n_frm),...
%         'k_BLEND', zeros(1,n_frm),...
%         'd_BLEND', zeros(1,n_frm),...
%         'WGT_TV', zeros(n_frm, nARTIC)));
% for k = 1:size(ART, 2)
%     ART(k).TOTWGT = zeros(1,n_frm);
%     ART(k).PROM_ACT_JNT = zeros(1,n_frm);
%     ART(k).PROM_NEUT = zeros(1,n_frm);
%     ART(k).PROMSUM_JNT = zeros(1,n_frm);
% end


    
% --------------------------------------------------------------------
function varargout = tb_tv_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.tb_tv.

load t_params
state = get(handles.tada, 'userdata');

% delete all gestural boxes handles
delete(state.h_rt_selGest)
state.h_rt_selGest = [];
state.sel_ngests = [];
state.sel_iTVs = [];


global n_rampfrm
global ramp_style

if get(handles.tb_gscore, 'Value') == 1
    set(handles.tb_gscore, 'value', 0) 
end

n_rampfrm = str2num(get(handles.ed_ramp_frm, 'String'));
ramp_style = get(handles.cb_cos_ramp, 'Value');

if get(handles.tb_tv, 'Value') == 1
    rbutton3 = get(handles.rb_cr, 'Value');
    
    if rbutton3 == 1
        set(handles.rb_cd, 'Value', 1);
        set(handles.rb_cr, 'Value', 0);
        rbutton3 = get(handles.rb_cr, 'Value');
    end
    rbutton1 = get(handles.rb_cd, 'Value');
    rbutton2 = get(handles.rb_cl, 'Value');

    if isempty(get(handles.ed_uttname, 'String'))
        set(handles.tb_tv, 'Value', 0)
        errordlg('Utterance not found')
        return
    end

    if ~strcmp(get(handles.Apply_pi2gest, 'Enable'), 'off')
        set(handles.ln_tv_pi, 'xdata', 0, 'ydata', 0)
    end

    utt_name = get(handles.ed_uttname, 'String');

    if ~isempty(state.TV_SCORE)
        ART = state.ART;
        TV_SCORE = state.TV_SCORE;
        n_frm = state.n_frm;
        ms_frm = state.ms_frm;
        last_frm = n_frm/ms_frm*wag_frm;
        
        % added by HN 0910 to take the initial phonation info (new) from tv.g
        ifkill = str2num(get(handles.ed_init_kill, 'string'));
        if ~isempty(TV_SCORE(1).phon_onset)
            ifkill(1) = TV_SCORE(1).phon_onset*10;
        end

        if ~isempty(TV_SCORE(1).phon_offset)
            ifkill(2) = TV_SCORE(1).phon_offset*10;
        end
        
        [sig srate A ADOT TV TVDOT TV_SCORE ART ms_frm last_frm AREA TUBELENGTHSMOOTH UPPEROUTLINE BOTTOMOUTLINE TRSD F] = ...
            t_casy(utt_name, TV_SCORE, ART, ms_frm, last_frm, ifkill, handles);
        
        % synthesis through HLsyn, added by HN 200901
        mextype  = mexext;
        HLexe    = ['HLsyn.' mextype];
        yesHLsyn = exist( HLexe, 'file' );
        if yesHLsyn
            fnHL = [utt_name '.HL'];
            params = ParseHL(fnHL);
            sig = HLsyn(params)';
        end
        sig = double(sig);
        sig = sig/max(abs(sig));
    end

    set(handles.ax_area, 'xlim', [0 max(max(TUBELENGTHSMOOTH))], 'ylim', [0 1000])
    set(handles.ln_area, 'xdata', TUBELENGTHSMOOTH(1,:), 'ydata', AREA(1,:))
    set(handles.ln_upperoutline, 'xdata', UPPEROUTLINE(:,1,1), 'ydata', UPPEROUTLINE(:,2,1))
    set(handles.ln_bottomoutline, 'xdata', BOTTOMOUTLINE(:,1,1), 'ydata', BOTTOMOUTLINE(:,2,1))
    set(handles.ln_velumopen, 'xdata', UPPEROUTLINE(4:5,1,1), 'ydata', UPPEROUTLINE(4:5,2,1))
    
    set(0, 'CurrentFigure', handles.tada) % fixed 2004/11/17
    n_frm = (last_frm)*ms_frm/wag_frm;

    set(handles.ln_audioall, 'xdata', 1/length(sig)*n_frm:1/length(sig)*n_frm:n_frm, 'ydata', sig);
    set(handles.ln_audiosel, 'xdata', 1/length(sig)*n_frm:1/length(sig)*n_frm:n_frm, 'ydata', sig);

    set(handles.ax_audioall, 'XLim', [0 n_frm], 'YLim', [-1 1])
    set(handles.pc_sel, 'xdata', [0 0 n_frm n_frm]);
    set(handles.ax_audiosel, 'XLim', [0 n_frm], 'YLim', [-1 1])

    for i_TV = [i_JAW i_VEL i_GLO i_F0 i_TR] % i_PI i_SPI 
        switch i_TV
            case i_JAW
                h_axes = handles.ax_jaw;
                h_gs_ln = handles.ln_gs_jaw;
                h_tv_ln = handles.ln_tv_jaw;
                set(handles.tx_jaw, 'String', 'JAW')
            case i_VEL
                h_axes = handles.ax_vel;
                h_gs_ln = handles.ln_gs_vel;
                h_tv_ln = handles.ln_tv_vel;
                set(handles.tx_vel, 'String', 'VEL')
            case i_GLO
                h_axes = handles.ax_glo;
                h_gs_ln = handles.ln_gs_glo;
                h_tv_ln = handles.ln_tv_glo;
                set(handles.tx_glo, 'String', 'GLO')
            case i_F0
                h_axes = handles.ax_F0;
                h_gs_ln = handles.ln_gs_F0;
                h_tv_ln = handles.ln_tv_F0;
                set(handles.tx_F0, 'String', 'F0')
%             case i_PI
%                 h_axes = handles.ax_pi;
%                 h_gs_ln = handles.ln_gs_pi;
%                 h_tv_ln = handles.ln_tv_pi;
%                 set(handles.tx_pi, 'String', 'PI')         
%             case i_SPI
%                 h_axes = handles.ax_spi;
%                 h_gs_ln = handles.ln_gs_spi;
%                 h_tv_ln = handles.ln_tv_spi;
%                 set(handles.tx_spi, 'String', 'SPI')         
            case i_TR
                h_axes = handles.ax_tr;
                h_gs_ln = handles.ln_gs_tr;
                h_tv_ln = handles.ln_tv_tr;
                set(handles.tx_tr, 'String', 'TR')
        end
        min_tmp = min(TV(i_TV,:));
        max_tmp = max(TV(i_TV,:));
        if min_tmp ==  max_tmp
            min_tmp = min_tmp -1;
            max_tmp = max_tmp +1;
        end
        set(h_gs_ln, 'xdata', 1:n_frm, 'ydata', TV_SCORE(i_TV).TV.PROMSUM/2*(max_tmp-min_tmp)+min_tmp);
        set(h_axes, 'XLim', [0 n_frm], 'YLim', [min_tmp max_tmp])
        set(h_tv_ln, 'xdata', 1:n_frm, 'ydata', TV(i_TV,:));
    end
    set(handles.ax_line, 'XLim', [0 n_frm], 'YLim', [0 1]) %HN

%     % pi gesture display
%     if ~isempty(ffind_case(['PI',utt_name,'.G']))
%         t = [];
%         t_scaled = [];
%         pi_act = [];
%         pi_act_scaled = [];
%         [t t_scaled pi_act pi_act_scaled] = t_scaled_time_gen(utt_name);
%         last_t_idx = max(find(t<=last_frm*ms_frm/1000));
%         % draw pi gesture on time scale
%         set(handles.ln_tv_pi, 'xdata', t(1:last_t_idx), 'ydata', pi_act.signals.values(1:last_t_idx));
%         set(handles.ax_pi, 'XLim', [0 t(last_t_idx)], 'YLim', [0 1])
%     end

    if rbutton1 == 1
        for i_TV = [i_LA i_TBCD i_TTCD]
            switch i_TV
                case i_LA
                    h_axes = handles.ax_lips;
                    h_gs_ln = handles.ln_gs_lips;
                    h_tv_ln = handles.ln_tv_lips;
                    set(handles.tx_lips, 'String', 'LA')
                case i_TBCD
                    h_gs_ln = handles.ln_gs_tb;
                    h_tv_ln = handles.ln_tv_tb;
                    h_axes = handles.ax_tb;
                    set(handles.tx_tb, 'String', 'TBCD')
                case i_TTCD
                    h_gs_ln = handles.ln_gs_tt;
                    h_tv_ln = handles.ln_tv_tt;
                    h_axes = handles.ax_tt;
                    set(handles.tx_tt, 'String', 'TTCD')
            end
            min_tmp = min(TV(i_TV,:));
            max_tmp = max(TV(i_TV,:));
            if min_tmp ==  max_tmp
                min_tmp = min_tmp -1;
                max_tmp = max_tmp +1;
            end
            set(h_gs_ln, 'xdata', 1:n_frm, 'ydata', TV_SCORE(i_TV).TV.PROMSUM/2*(max_tmp-min_tmp)+min_tmp)
            set(h_axes, 'XLim', [0 n_frm], 'YLim', [min_tmp max_tmp])
            set(h_tv_ln, 'xdata', 1:n_frm, 'ydata', TV(i_TV,:))
        end
        set(handles.rb_cr, 'Enable', 'on')
    end

    if rbutton2 == 1
        for i_TV = [i_PRO i_TBCL i_TTCL]
            switch i_TV
                case i_PRO
                    h_gs_ln = handles.ln_gs_lips;
                    h_tv_ln = handles.ln_tv_lips;
                    h_axes = handles.ax_lips;
                    set(handles.tx_lips, 'String', 'PRO')
                case i_TBCL
                    h_gs_ln = handles.ln_gs_tb;
                    h_tv_ln = handles.ln_tv_tb;
                    h_axes = handles.ax_tb;
                    set(handles.tx_tb, 'String', 'TBCL')
                case i_TTCL
                    h_gs_ln = handles.ln_gs_tt;
                    h_tv_ln = handles.ln_tv_tt;
                    h_axes = handles.ax_tt;
                    set(handles.tx_tt, 'String', 'TTCL')
            end

            set(gcf,'CurrentAxes',h_axes)

            min_tmp = min(TV(i_TV,:));
            max_tmp = max(TV(i_TV,:));

            if min_tmp ==  max_tmp
                min_tmp = min_tmp -1;
                max_tmp = max_tmp +1;
            end

            set(h_gs_ln, 'xdata', 1:n_frm, 'ydata', TV_SCORE(i_TV).TV.PROMSUM/2*(max_tmp-min_tmp)+min_tmp)
            set(h_axes, 'XLim', [0 n_frm], 'YLim', [min_tmp max_tmp])
            set(h_tv_ln, 'xdata', 1:n_frm, 'ydata', TV(i_TV,:))
        end
        set(handles.rb_cr, 'Enable', 'on')
    end
    
    state.ART = ART;
    state.TV_SCORE = TV_SCORE;
    state.TV = TV;
    state.n_frm = n_frm;
    state.ms_frm = ms_frm;
    state.last_frm = last_frm;
    state.sig = sig;
    state.srate = srate;
    state.A = A;
    state.ADOT = ADOT;
    state.AREA = AREA;
    state.TUBELENGTHSMOOTH = TUBELENGTHSMOOTH;
    state.UPPEROUTLINE = UPPEROUTLINE;
    state.BOTTOMOUTLINE = BOTTOMOUTLINE;
    state.curfrm = [];
    state.cur_x = [];
    state.F = F;
    
    ASYPEL(1).SIGNAL(1,:) = utx + A(i_LX,:)*mm_per_dec; % Upper Lip X
    ASYPEL(1).SIGNAL(2,:) = uty + A(i_UY,:)*mm_per_dec; % Upper Lip Y

    ASYPEL(5).SIGNAL(1,:) = xf + A(i_CL,:)*mm_per_dec.*cos(A(i_CA,:)+A(i_JA,:) - pi/2); % Tongue body center X e1
    ASYPEL(5).SIGNAL(2,:) = yf + A(i_CL,:)*mm_per_dec.*sin(A(i_CA,:)+A(i_JA,:) - pi/2); % Tongue body certer Y e2

    ASYPEL(3).SIGNAL(1,:) = xf+rj*cos(A(i_JA,:) - pi/2); % Jaw X e3
    ASYPEL(3).SIGNAL(2,:) = yf+rj*sin(A(i_JA,:) - pi/2); % Jaw Y e4

    ASYPEL(2).SIGNAL(1,:) = ASYPEL(3).SIGNAL(1,:)+A(i_LX,:)*mm_per_dec; % Lower Lip X e5
    ASYPEL(2).SIGNAL(2,:) = ASYPEL(3).SIGNAL(2,:)+A(i_LY,:)*mm_per_dec; % Lower Lip Y e6

    ASYPEL(4).SIGNAL(1,:) = ASYPEL(5).SIGNAL(1,:)+rc*cos(A(i_JA,:) - pi/2+.55*pi)+A(i_TL,:)*mm_per_dec.*cos(A(i_JA,:) - pi/2+A(i_TA,:)+(.004*(A(i_CL,:)*mm_per_dec-950 / mermels_per_mm)) * mermels_per_mm); % Tongue Tip X e7
    ASYPEL(4).SIGNAL(2,:) = ASYPEL(5).SIGNAL(2,:)+rc*sin(A(i_JA,:) - pi/2+.55*pi)+A(i_TL,:)*mm_per_dec.*sin(A(i_JA,:) - pi/2+A(i_TA,:)+(.004*(A(i_CL,:)*mm_per_dec-950 / mermels_per_mm)) * mermels_per_mm); % Tongue Tip Y e8

    % modified by HN to test varying TD pellets depending on CA 071116
ef = -0; net_CA = .1; %def=.2085
%     ASYPEL(8).SIGNAL(1,:) = ASYPEL(5).SIGNAL(1,:); % Tongue Front X
%     ASYPEL(8).SIGNAL(2,:) = ASYPEL(5).SIGNAL(2,:)+rc; % Tongue Front Y
    ASYPEL(8).SIGNAL(1,:) = ASYPEL(5).SIGNAL(1,:)-rc*cos(pi/2+ef.*(net_CA+A(i_CA,:))); % Tongue Dorsal X
    ASYPEL(8).SIGNAL(2,:) = ASYPEL(5).SIGNAL(2,:)+rc*sin(pi/2+ef.*(net_CA+A(i_CA,:))); % Tongue Dorsal Y

%     ASYPEL(6).SIGNAL(1,:) = ASYPEL(5).SIGNAL(1,:)-rc*sin(pi/4); % Tongue Dorsal X
%     ASYPEL(6).SIGNAL(2,:) = ASYPEL(5).SIGNAL(2,:)+rc*sin(pi/4); % Tongue Dorsal Y
    ASYPEL(6).SIGNAL(1,:) = ASYPEL(5).SIGNAL(1,:)-rc*cos(pi/4+ef.*(net_CA+A(i_CA,:))); % Tongue Dorsal X
    ASYPEL(6).SIGNAL(2,:) = ASYPEL(5).SIGNAL(2,:)+rc*sin(pi/4+ef.*(net_CA+A(i_CA,:))); % Tongue Dorsal Y

%     ASYPEL(7).SIGNAL(1,:) = ASYPEL(5).SIGNAL(1,:)-rc; % Tongue Rear X
%     ASYPEL(7).SIGNAL(2,:) = ASYPEL(5).SIGNAL(2,:); % Tongue Rear Y
    ASYPEL(7).SIGNAL(1,:) = ASYPEL(5).SIGNAL(1,:)-rc*cos(ef.*(net_CA+A(i_CA,:))); % Tongue Dorsal X
    ASYPEL(7).SIGNAL(2,:) = ASYPEL(5).SIGNAL(2,:)+rc*sin(ef.*(net_CA+A(i_CA,:))); % Tongue Dorsal Y

    for i_ASYPEL = [1:4 6:8]
        min_tmp = min([min(ASYPEL(i_ASYPEL).SIGNAL(1,:)), min(ASYPEL(i_ASYPEL).SIGNAL(2,:))]);
        max_tmp = max([max(ASYPEL(i_ASYPEL).SIGNAL(1,:)), max(ASYPEL(i_ASYPEL).SIGNAL(2,:))]);
        if min_tmp ==  max_tmp
            min_tmp = min_tmp -1;
            max_tmp = max_tmp +1;
        end
        yMarg = (max_tmp-min_tmp)/10; min_tmp = min_tmp - yMarg; max_tmp = max_tmp + yMarg;
        switch i_ASYPEL
            case 1
                set(handles.ln_asy_ulx, 'xdata', 1:n_frm, 'ydata', ASYPEL(i_ASYPEL).SIGNAL(1,:))
                set(handles.ln_asy_uly, 'xdata', 1:n_frm, 'ydata', ASYPEL(i_ASYPEL).SIGNAL(2,:))
                set(handles.ax_asy_ul, 'XLim', [0 n_frm], 'YLim', [min_tmp max_tmp])
            case 2
                set(handles.ln_asy_llx, 'xdata', 1:n_frm, 'ydata', ASYPEL(i_ASYPEL).SIGNAL(1,:))
                set(handles.ln_asy_lly, 'xdata', 1:n_frm, 'ydata', ASYPEL(i_ASYPEL).SIGNAL(2,:))
                set(handles.ax_asy_ll, 'XLim', [0 n_frm], 'YLim', [min_tmp max_tmp])
            case 3
                set(handles.ln_asy_jawx, 'xdata', 1:n_frm, 'ydata', ASYPEL(i_ASYPEL).SIGNAL(1,:))
                set(handles.ln_asy_jawy, 'xdata', 1:n_frm, 'ydata', ASYPEL(i_ASYPEL).SIGNAL(2,:))
                set(handles.ax_asy_jaw, 'XLim', [0 n_frm], 'YLim', [min_tmp max_tmp])
            case 4
                set(handles.ln_asy_ttx, 'xdata', 1:n_frm, 'ydata', ASYPEL(i_ASYPEL).SIGNAL(1,:))
                set(handles.ln_asy_tty, 'xdata', 1:n_frm, 'ydata', ASYPEL(i_ASYPEL).SIGNAL(2,:))
                set(handles.ax_asy_tt, 'XLim', [0 n_frm], 'YLim', [min_tmp max_tmp])
            case 8
                set(handles.ln_asy_tfx, 'xdata', 1:n_frm, 'ydata', ASYPEL(i_ASYPEL).SIGNAL(1,:))
                set(handles.ln_asy_tfy, 'xdata', 1:n_frm, 'ydata', ASYPEL(i_ASYPEL).SIGNAL(2,:))
                set(handles.ax_asy_tf, 'XLim', [0 n_frm], 'YLim', [min_tmp max_tmp])
            case 6
                set(handles.ln_asy_tdx, 'xdata', 1:n_frm, 'ydata', ASYPEL(i_ASYPEL).SIGNAL(1,:))
                set(handles.ln_asy_tdy, 'xdata', 1:n_frm, 'ydata', ASYPEL(i_ASYPEL).SIGNAL(2,:))
                set(handles.ax_asy_td, 'XLim', [0 n_frm], 'YLim', [min_tmp max_tmp])
            case 7
                set(handles.ln_asy_trx, 'xdata', 1:n_frm, 'ydata', ASYPEL(i_ASYPEL).SIGNAL(1,:))
                set(handles.ln_asy_try, 'xdata', 1:n_frm, 'ydata', ASYPEL(i_ASYPEL).SIGNAL(2,:))
                set(handles.ax_asy_tr, 'XLim', [0 n_frm], 'YLim', [min_tmp max_tmp])
        end
    end

    hyoid = state.HYOID;
    pal = state.PAL;

    cur_x = 1;
    x_spat2d = [ASYPEL(1).SIGNAL(1,ceil(cur_x)) ...
        ASYPEL(2).SIGNAL(1,ceil(cur_x)) ...
        ASYPEL(3).SIGNAL(1,ceil(cur_x)) ...
        ASYPEL(4).SIGNAL(1,ceil(cur_x)) ...
        ASYPEL(6).SIGNAL(1,ceil(cur_x)) ...
        ASYPEL(7).SIGNAL(1,ceil(cur_x)) ...
        ASYPEL(8).SIGNAL(1,ceil(cur_x)) ...
        hyoid(1)];
    y_spat2d = [ASYPEL(1).SIGNAL(2,ceil(cur_x)) ...
        ASYPEL(2).SIGNAL(2,ceil(cur_x)) ...
        ASYPEL(3).SIGNAL(2,ceil(cur_x)) ...
        ASYPEL(4).SIGNAL(2,ceil(cur_x)) ...
        ASYPEL(6).SIGNAL(2,ceil(cur_x)) ...
        ASYPEL(7).SIGNAL(2,ceil(cur_x)) ...
        ASYPEL(8).SIGNAL(2,ceil(cur_x)) ...
        hyoid(2)];

    % axis square
    xx = min(x_spat2d(4:end-1)) : .5 : max(x_spat2d(4:end-1));
    yy = interp1(x_spat2d(4:end-1), y_spat2d(4:end-1), xx, '*PCHIP');

    set(handles.ln_pels_ul, 'xdata', x_spat2d(1), 'ydata', y_spat2d(1));
    set(handles.ln_pels_ll, 'xdata', x_spat2d(2), 'ydata', y_spat2d(2));
    set(handles.ln_pels_jaw, 'xdata', x_spat2d(3), 'ydata', y_spat2d(3));
    set(handles.ln_pels_tt, 'xdata', x_spat2d(4), 'ydata', y_spat2d(4));
    set(handles.ln_pels_tf, 'xdata', x_spat2d(7), 'ydata', y_spat2d(7));
    set(handles.ln_pels_td, 'xdata', x_spat2d(6), 'ydata', y_spat2d(6));
    set(handles.ln_pels_tr, 'xdata', x_spat2d(5), 'ydata', y_spat2d(5));

    set(handles.cln_pels_ul, 'xdata', x_spat2d(1), 'ydata', y_spat2d(1));
    set(handles.cln_pels_ll, 'xdata', x_spat2d(2), 'ydata', y_spat2d(2));
    set(handles.cln_pels_jaw, 'xdata', x_spat2d(3), 'ydata', y_spat2d(3));
    set(handles.cln_pels_tt, 'xdata', x_spat2d(4), 'ydata', y_spat2d(4));
    set(handles.cln_pels_tf, 'xdata', x_spat2d(7), 'ydata', y_spat2d(7));
    set(handles.cln_pels_td, 'xdata', x_spat2d(6), 'ydata', y_spat2d(6));
    set(handles.cln_pels_tr, 'xdata', x_spat2d(5), 'ydata', y_spat2d(5));
    
    set(handles.ln_intpl, 'xdata', xx, 'ydata', yy);
    set(handles.ln_pal, 'xdata', pal(:,1), 'ydata', pal(:,2));
    set(handles.ln_cl, 'xdata', [0 0])
    
    state.ASYPEL = ASYPEL;

    % invisible plotting on invisible articulator axes
    A = state.A;

    bPos = get(handles.ax_asy_td, 'position');
    x = bPos(1); y = 0; w = bPos(3); h = bPos(4);

    for i_ARTIC = 1:nARTIC
        min_tmp(i_ARTIC) = min(A(i_ARTIC,:));
        max_tmp(i_ARTIC) = max(A(i_ARTIC,:));
        if min_tmp(i_ARTIC) ==  max_tmp(i_ARTIC)
            min_tmp(i_ARTIC) = min_tmp(i_ARTIC) -1;
            max_tmp(i_ARTIC) = max_tmp(i_ARTIC) +1;
        end
        yMarg = (max_tmp(i_ARTIC)-min_tmp(i_ARTIC))/10;
        min_tmp(i_ARTIC) = min_tmp(i_ARTIC) - yMarg;
        max_tmp(i_ARTIC) = max_tmp(i_ARTIC) + yMarg;
    end

    set(handles.ax_a_lx, 'xlim', [0 n_frm], 'ylim', [min_tmp(i_LX) max_tmp(i_LX)])
    set(handles.ax_a_ja, 'xlim', [0 n_frm], 'ylim', [min_tmp(i_JA) max_tmp(i_JA)])
    set(handles.ax_a_uy, 'xlim', [0 n_frm], 'ylim', [min_tmp(i_UY) max_tmp(i_UY)])
    set(handles.ax_a_ly, 'xlim', [0 n_frm], 'ylim', [min_tmp(i_LY) max_tmp(i_LY)])
    set(handles.ax_a_cl, 'xlim', [0 n_frm], 'ylim', [min_tmp(i_CL) max_tmp(i_CL)])
    set(handles.ax_a_ca, 'xlim', [0 n_frm], 'ylim', [min_tmp(i_CA) max_tmp(i_CA)])
    set(handles.ax_a_tl, 'xlim', [0 n_frm], 'ylim', [min_tmp(i_TL) max_tmp(i_TL)])
    set(handles.ax_a_ta, 'xlim', [0 n_frm], 'ylim', [min_tmp(i_TA) max_tmp(i_TA)])
    set(handles.ax_a_na, 'xlim', [0 n_frm], 'ylim', [min_tmp(i_NA) max_tmp(i_NA)])
    set(handles.ax_a_gw, 'xlim', [0 n_frm], 'ylim', [min_tmp(i_GW) max_tmp(i_GW)])

    set(handles.ln_a_lx, 'xdata', 1:n_frm, 'ydata', A(i_LX, :))
    set(handles.ln_a_ja, 'xdata', 1:n_frm, 'ydata', A(i_JA, :))
    set(handles.ln_a_uy, 'xdata', 1:n_frm, 'ydata', A(i_UY, :))
    set(handles.ln_a_ly, 'xdata', 1:n_frm, 'ydata', A(i_LY, :))
    set(handles.ln_a_cl, 'xdata', 1:n_frm, 'ydata', A(i_CL, :))
    set(handles.ln_a_ca, 'xdata', 1:n_frm, 'ydata', A(i_CA, :))
    set(handles.ln_a_tl, 'xdata', 1:n_frm, 'ydata', A(i_TL, :))
    set(handles.ln_a_ta, 'xdata', 1:n_frm, 'ydata', A(i_TA, :))
    set(handles.ln_a_na, 'xdata', 1:n_frm, 'ydata', A(i_NA, :))
    set(handles.ln_a_gw, 'xdata', 1:n_frm, 'ydata', A(i_GW, :))

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(handles.ax_formants, 'xlim', [0 last_frm], 'ylim', [0 max(F(4,:))])
    set(handles.ln_F1, 'xdata', 0:last_frm, 'ydata', F(1,1:end))
    set(handles.ln_F2, 'xdata', 0:last_frm, 'ydata', F(2,1:end))
    set(handles.ln_F3, 'xdata', 0:last_frm, 'ydata', F(3,1:end))
    set(handles.ln_F4, 'xdata', 0:last_frm, 'ydata', F(4,1:end))
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    set(handles.cb_ramp_act, 'Enable', 'off')
    set(handles.cb_cos_ramp, 'Enable', 'off')

elseif get(handles.tb_tv, 'value') == 0
    set(handles.tb_tv, 'value', 1)
end
set(handles.tada, 'userdata', state)



function i_TV = get_i_TV (TVname)
load t_params
switch TVname
    case 'LA' 
        i_TV = i_LA;
    case 'PRO'
        i_TV = i_PRO;
    case 'TBCD'
        i_TV = i_TBCD;
    case 'TBCL'
        i_TV = i_TBCL;
    case 'TTCD'
        i_TV = i_TTCD;
    case 'TTCL'
        i_TV = i_TTCL;
    case 'TTCR'
        i_TV = i_TTCR;
    case 'JAW'
        i_TV = i_JAW;
    case 'VEL'
        i_TV = i_VEL;
    case 'GLO'
        i_TV = i_GLO;
    case 'F0'
        i_TV = i_F0;
    case 'PI'
        i_TV = i_PI;        
    case 'SPI'
        i_TV = i_SPI;
    case 'TR'
        i_TV = i_TR;
end

function TVname = get_TVname (i_TV)
load t_params
switch i_TV
    case i_LA 
        TVname = 'LA';
    case i_PRO 
        TVname = 'LP';
    case i_TBCD 
        TVname = 'TBCD';
    case i_TBCL 
        TVname = 'TBCL';
    case i_TTCD 
        TVname = 'TTCD';
    case i_TTCL 
        TVname = 'TTCL';
    case i_TTCR 
        TVname = 'TTCR';
    case i_JAW 
        TVname = 'JAW';
    case i_VEL 
        TVname = 'VEL';
    case i_GLO 
        TVname = 'GLO';
    case i_F0 
        TVname = 'F0';
    case i_PI
        TVname = 'PI';
    case i_SPI 
        TVname = 'SPI';
    case i_TR 
        TVname = 'TR';
end

function ARTICname = get_ARTICname (i_ARTIC)
load t_params

switch i_ARTIC
    case i_LX 
        ARTICname = 'LX';
    case i_JA 
        ARTICname = 'JA';
    case i_UY
        ARTICname = 'UH';
    case i_LY 
        ARTICname = 'LH';
    case i_CL 
        ARTICname = 'CL';
    case i_CA 
        ARTICname = 'CA';
    case i_TL
        ARTICname = 'TL';
    case i_TA
        ARTICname = 'TA';
    case i_NA
        ARTICname = 'NA';
    case i_GW
        ARTICname = 'GW';
    case i_F0a
        ARTICname = 'F0a';
    case i_PIa
        ARTICname = 'PIa';
    case i_SPIa
        ARTICname = 'SPIa';
    case i_HX
        ARTICname = 'HX';
end



% --------------------------------------------------------------------
function varargout = ax_lips_ButtonDownFcn(h, eventdata, handles, varargin)
% Stub for ButtonDownFcn of the axes handles.ax_lips.

clickGest(handles, handles.ax_lips, handles.tx_lips, [handles.tx_tb handles.tx_tt handles.tx_jaw handles.tx_vel handles.tx_glo handles.tx_F0 handles.tx_pi handles.tx_spi handles.tx_tr])


% --------------------------------------------------------------------
function varargout = ax_tb_ButtonDownFcn(h, eventdata, handles, varargin)
% Stub for ButtonDownFcn of the axes handles.ax_tb.

clickGest(handles, handles.ax_tb, handles.tx_tb, [handles.tx_lips handles.tx_tt handles.tx_jaw handles.tx_vel handles.tx_glo handles.tx_F0 handles.tx_pi handles.tx_spi handles.tx_tr])


% --------------------------------------------------------------------
function varargout = ax_tt_ButtonDownFcn(h, eventdata, handles, varargin)
% Stub for ButtonDownFcn of the axes handles.ax_tt.

clickGest(handles, handles.ax_tt, handles.tx_tt, [handles.tx_lips handles.tx_tb handles.tx_jaw handles.tx_vel handles.tx_glo handles.tx_F0 handles.tx_pi handles.tx_spi handles.tx_tr])


% --- Executes on mouse press over axes background.
function ax_jaw_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ax_jaw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clickGest(handles, handles.ax_jaw, handles.tx_jaw, [handles.tx_lips handles.tx_tt handles.tx_tb handles.tx_vel handles.tx_glo handles.tx_F0 handles.tx_pi handles.tx_spi handles.tx_tr])


% --------------------------------------------------------------------
function varargout = ax_vel_ButtonDownFcn(h, eventdata, handles, varargin)
% Stub for ButtonDownFcn of the axes handles.ax_vel.

clickGest(handles, handles.ax_vel, handles.tx_vel, [handles.tx_lips handles.tx_tb handles.tx_tt handles.tx_jaw handles.tx_glo handles.tx_F0 handles.tx_pi handles.tx_spi handles.tx_tr])


% --------------------------------------------------------------------
function varargout = ax_glo_ButtonDownFcn(h, eventdata, handles, varargin)
% Stub for ButtonDownFcn of the axes handles.ax_glo.

clickGest(handles, handles.ax_glo, handles.tx_glo, [handles.tx_lips handles.tx_tb handles.tx_tt handles.tx_jaw handles.tx_vel handles.tx_F0 handles.tx_pi handles.tx_spi handles.tx_tr])


% --- Executes on mouse press over axes background.
function ax_F0_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ax_F0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clickGest(handles, handles.ax_F0, handles.tx_F0, [handles.tx_lips handles.tx_tb handles.tx_tt handles.tx_jaw handles.tx_vel handles.tx_glo handles.tx_pi handles.tx_spi handles.tx_tr])


% --- Executes on mouse press over axes background.
function ax_pi_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ax_pi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clickGest(handles, handles.ax_pi, handles.tx_pi, [handles.tx_lips handles.tx_tb handles.tx_tt handles.tx_jaw handles.tx_vel handles.tx_glo handles.tx_F0 handles.tx_spi handles.tx_tr])


% --- Executes on mouse press over axes background.
function ax_spi_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ax_spi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clickGest(handles, handles.ax_spi, handles.tx_spi, [handles.tx_lips handles.tx_tb handles.tx_tt handles.tx_jaw handles.tx_vel handles.tx_glo handles.tx_F0 handles.tx_pi handles.tx_tr])


% --- Executes on mouse press over axes background.
function ax_tr_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ax_tr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clickGest(handles, handles.ax_tr, handles.tx_tr, [handles.tx_lips handles.tx_tb handles.tx_tt handles.tx_jaw handles.tx_vel handles.tx_glo handles.tx_F0 handles.tx_pi handles.tx_spi])


% --------------------------------------------------------------------
function varargout = pb_saveas_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.pb_saveas.

% various, concise OSC_flg...
% currently, not generate saveas output...
% think of two types of files (tv and mat files)

load t_params
state = get(handles.tada, 'userdata');

% delete all gestural boxes handles
delete(state.h_rt_selGest)
state.h_rt_selGest = [];
state.sel_ngests = [];
state.sel_iTVs = [];

utt_name = get(handles.ed_uttname, 'String');
TV_SCORE = state.TV_SCORE;
ms_frm = state.ms_frm;
last_frm = state.last_frm;

[fname,pname] = uiputfile( ...
    {'TV*.G*;TV*.g*;Tv*.G*;Tv*.g*;tV*.G*;tV*.g*;tv*.G*;tv*.g*',...
        'TV Files (TV*.G*)'}, 'TV files');

if fname == 0
    return
end
cd(pname)
str_end = [];

if strfind(fname, '.G') 
    str_end = strfind(fname, '.G') -1;
elseif strfind(fname, '.g')
    str_end = strfind(fname, '.g') -1;
end

if ~isempty(str_end)
    fname = fname(1:str_end);
end
while strcmpi(fname(1:2), 'tv')
    fname = fname(3:end);
end

% write TV .G or TV .mat
utt_save =  fname;
t_saveAs(utt_save, TV_SCORE, ms_frm)


fstruct=dir(strcat('TV', utt_save, '.G'));
if isempty(fstruct)
    return
else
    fname=fstruct.name;
    pname=cd;
    utt_name = fstruct.name(3:end-2);
    state.OSC_flg = 0;
    gui_on_off(handles, state.OSC_flg)
    set(handles.mn_saveOscSim, 'Enable', 'off')

    state.TV_SCORE = [];
    state.utt_name = utt_save;
    state.fname = fname;
    state.pname = pname;
    set(handles.ed_uttname, 'String', utt_save)
    set(handles.pb_saveas, 'Enable', 'on')

    set(handles.cb_cos_ramp, 'value', 0)
    set(handles.cb_ramp_act, 'value', 0)
    set(handles.tb_gscore, 'value', 0)
    set(handles.tb_tv, 'value', 0)
    cd(state.pname)
    flg_pi = 0;
    clear_all_axis(handles, flg_pi)
    set(handles.tb_gscore, 'value', 1);
    set(handles.tada, 'userdata', state);
    tada('tb_gscore_Callback', handles.tb_gscore, [], handles)
    state = get(handles.tada, 'userdata');
end
set(handles.tada, 'userdata', state);



































% --------------------------------------------------------------------
function varargout = tada_CreateFcn(h, eventdata, handles, varargin)
% Stub for CreateFcn of the figure handles.tada.




% --------------------------------------------------------------------
function varargout = tada_DeleteFcn(h, eventdata, handles, varargin)
% Stub for DeleteFcn of the figure handles.tada.

fn = ffind_case(['TV', '~', num2str(handles.tada), '.G']);
if ~isempty(fn)
    delete(fn)
end
fn = ffind_case(['TVTV', '~', num2str(handles.tada), '.G']);
if ~isempty(fn)
    delete(fn)
end
fn = ffind_case(['PI', '~', num2str(handles.tada), '.G']);
if ~isempty(fn)
    delete(fn)
end
fn = ffind_case(['~', num2str(handles.tada), '.wav']);
if ~isempty(fn)
    delete(fn)
end



% --------------------------------------------------------------------

% --------------------------------------------------------------------
function varargout = pb_new_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.pb_new.
tada


% --- Executes on button press in pb_play_movie.
function pb_play_movie_Callback(hObject, eventdata, handles)
% hObject    handle to pb_play_movie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

state = get(handles.tada, 'userdata');

if get(handles.cb_normal, 'value')
    set(handles.sl_playspd, 'value', state.CPLAY)
end

if get(handles.sl_playspd, 'max') < state.CPLAY
    set(handles.sl_playspd, 'value', state.CPLAY)
    errordlg('You have too slow a machine. It is time to replace.', 'Budget problem?');
end

playspd = get(handles.sl_playspd, 'value');
ASYPEL = state.ASYPEL;
hyoid = state.HYOID;

if get(handles.tb_tv, 'value')
    sig = state.sig;

    srate = state.srate;
    n_frm = state.n_frm;

    XLim = get(handles.ax_audiosel, 'XLim');
    c = [ceil(XLim(1)) floor(XLim(2))];
    if c(1) == 0
        c(1) = 1;
    end
    n_selfrm = XLim(2) - XLim(1)+1;

    player = audioplayer(sig(floor(length(sig)*XLim(1)/n_frm)+1 : ceil(length(sig)*XLim(2)/n_frm)),...
        srate/state.CPLAY*playspd);
    play(player)

    rem = [];
    if mod(c(2)-c(1), playspd) > 0
        rem = c(2);
    end
    
    tic
    for i = [c(1):playspd:c(2) rem]
        curfrm = ceil(i);
        i = round(i);
        set(handles.ed_curfrm, 'String', curfrm)
        set(handles.ln_cl, 'XData', [i i])
            x_spat2d = [ASYPEL(1).SIGNAL(1,i) ...
                ASYPEL(2).SIGNAL(1,i) ...
                ASYPEL(3).SIGNAL(1,i) ...
                ASYPEL(4).SIGNAL(1,i) ...
                ASYPEL(6).SIGNAL(1,i) ...
                ASYPEL(7).SIGNAL(1,i) ...
                ASYPEL(8).SIGNAL(1,i) ...
                hyoid(1)];
            y_spat2d = [ASYPEL(1).SIGNAL(2,i) ...
                ASYPEL(2).SIGNAL(2,i) ...
                ASYPEL(3).SIGNAL(2,i) ...
                ASYPEL(4).SIGNAL(2,i) ...
                ASYPEL(6).SIGNAL(2,i) ...
                ASYPEL(7).SIGNAL(2,i) ...
                ASYPEL(8).SIGNAL(2,i) ...
                hyoid(2)];
            xx = linspace(min(x_spat2d(4:end-1)), max(x_spat2d(4:end-1)));
            yy = interp1(x_spat2d(4:end-1), y_spat2d(4:end-1), xx, '*PCHIP');

            set(handles.ln_pels_ul, 'xdata', x_spat2d(1), 'ydata', y_spat2d(1));
            set(handles.ln_pels_ll, 'xdata', x_spat2d(2), 'ydata', y_spat2d(2));
            set(handles.ln_pels_jaw, 'xdata', x_spat2d(3), 'ydata', y_spat2d(3));
            set(handles.ln_pels_tt, 'xdata', x_spat2d(4), 'ydata', y_spat2d(4));
            set(handles.ln_pels_tf, 'xdata', x_spat2d(7), 'ydata', y_spat2d(7));
            set(handles.ln_pels_td, 'xdata', x_spat2d(6), 'ydata', y_spat2d(6));
            set(handles.ln_pels_tr, 'xdata', x_spat2d(5), 'ydata', y_spat2d(5));

            set(handles.cln_pels_ul, 'xdata', x_spat2d(1), 'ydata', y_spat2d(1));
            set(handles.cln_pels_ll, 'xdata', x_spat2d(2), 'ydata', y_spat2d(2));
            set(handles.cln_pels_jaw, 'xdata', x_spat2d(3), 'ydata', y_spat2d(3));
            set(handles.cln_pels_tt, 'xdata', x_spat2d(4), 'ydata', y_spat2d(4));
            set(handles.cln_pels_tf, 'xdata', x_spat2d(7), 'ydata', y_spat2d(7));
            set(handles.cln_pels_td, 'xdata', x_spat2d(6), 'ydata', y_spat2d(6));
            set(handles.cln_pels_tr, 'xdata', x_spat2d(5), 'ydata', y_spat2d(5));
            
            
            
            set(handles.ln_intpl, 'xdata', xx, 'ydata', yy);
             
            if strcmpi(get(handles.mn_LowGraphic, 'checked'), 'off')
                set(handles.ln_area, 'xdata', state.TUBELENGTHSMOOTH(curfrm,:), 'ydata', state.AREA(curfrm,:))
                set(handles.ln_upperoutline, 'xdata', state.UPPEROUTLINE(:,1,curfrm), 'ydata', state.UPPEROUTLINE(:,2,curfrm))
                set(handles.ln_bottomoutline, 'xdata', state.BOTTOMOUTLINE(:,1,curfrm), 'ydata', state.BOTTOMOUTLINE(:,2,curfrm))
                set(handles.ln_velumopen, 'xdata', state.UPPEROUTLINE(4:5,1,curfrm), 'ydata', state.UPPEROUTLINE(4:5,2,curfrm))
            end
          
            drawnow
    end
    t=toc;
    state.CPLAY = t/(n_selfrm/200)*playspd;
    %refresh
end
set(handles.tada, 'UserData', state)

while isplaying(player) % to avoid returning audio object uncompleted
end



% --- Executes on button press in cb_normal.
function cb_normal_Callback(hObject, eventdata, handles)
% hObject    handle to cb_normal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_normal
state = get(handles.tada, 'userdata');
if get(hObject, 'value')
    if get(handles.sl_playspd, 'max') < state.CPLAY
        set(handles.sl_playspd, 'value', state.CPLAY)
        errordlg('You have too slow a machine. It is time to replace.', 'Budget problem?');
    end
end


% --- Executes on button press in Apply_pi2gest.
function Apply_pi2gest_Callback(hObject, eventdata, handles)
% hObject    handle to Apply_pi2gest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load t_params

state = get(handles.tada, 'Userdata');
tmp = state.TV_SCORE(1).GEST;

nPI = length(state.TV_SCORE(i_PI).GEST);
handles_new_tada = handles;

utt_save = [];
for i = 1:nPI
    state = get(handles_new_tada.tada, 'Userdata');

    % scaled pi gesture display in new tada window
    TV_SCORE = state.TV_SCORE; 
    
    if TV_SCORE(i_PI).GEST(end).BEG ==0 & TV_SCORE(i_PI).GEST(end).END ==0
        errordlg('No PI-gesture is specified.')
        return
    end
    
    utt_name = get(handles_new_tada.ed_uttname, 'String');
    
    % compute scaled time
    ms_frm = state.ms_frm;
    last_frm = state.last_frm;
    n_frm = state.n_frm;
    
    % currently multiple pi gestures allowed
    height = TV_SCORE(i_PI).GEST(i).x.VALUE;
    rise_dur = sqrt(TV_SCORE(i_PI).GEST(i).k.VALUE)/2/pi;
    fall_dur = rise_dur;
    start_time = TV_SCORE(i_PI).GEST(i).BEG - rise_dur/2;
    end_time = TV_SCORE(i_PI).GEST(i).END + fall_dur/2;
    hold_dur = end_time - fall_dur/2 - (start_time + rise_dur/2);
    
    timescale=1;
    t_final = (last_frm + (end_time - start_time)*height)*ms_frm/1000 + 1; % +1 is just to make it enough
    pos_init = 0;
    
    stif_gate = .6;
    
    cos_height=height;
    cos_start_time=start_time*ms_frm/1000;
    cos_rise_dur=rise_dur*ms_frm/1000;
    cos_hold_dur=hold_dur*ms_frm/1000;
    cos_hold_dur=cos_hold_dur*timescale;
    cos_fall_dur=fall_dur*ms_frm/1000;
    cos_fall_dur=cos_fall_dur*timescale;
    
    options = odeset('AbsTol', [], 'RelTol', [], 'MaxStep', .001, 'InitialStep', .001, 'refine', 1);
    [t,x] = ode45(@pi_ode,[0 t_final],[pos_init], options, cos_height, cos_start_time, cos_rise_dur, cos_hold_dur, cos_fall_dur, stif_gate);
    t_scaled = x;
    
    
    [tmp2, n_frm] = scaled_vector(t_scaled, tmp(1).PROM, n_frm);
    tmp(1).PROM = tmp2;
    last_frm = n_frm/ms_frm*wag_frm;
    
    if ~isempty(utt_save)
        delete(h_new_tada);
    end
    h_new_tada = tada;
    utt_save = ['~' num2str(h_new_tada)];
    
    handles_new_tada = guihandles(h_new_tada);
    gui_on_off(handles_new_tada, state.OSC_flg)
    
    set(handles_new_tada.ed_uttname, 'string', utt_save)
    set(handles_new_tada.tb_gscore, 'value', 1) % togglebutton down
    if get(handles.cb_ramp_act, 'value')
        set(handles_new_tada.cb_ramp_act, 'value', 1)
    end
    if get(handles.cb_cos_ramp, 'value')
        set(handles_new_tada.cb_cos_ramp, 'value', 1)
    end
    
    new_frm_vector_idx = [];
    
    % save params in state
    state.n_frm = n_frm;
    state.last_frm = last_frm;
    state.t_scaled = t_scaled;
    set(handles_new_tada.tada, 'Userdata', state)
    
    % % draw pi gesture
    % set(handles_new_tada.ln_tv_pi, 'xdata', 0, 'ydata', 0)
    % last_t_idx = max(find(t<=last_frm*ms_frm/1000)); % convert time function to frame
    % set(handles_new_tada.ln_tv_pi, 'xdata', t(1:last_t_idx), 'ydata', pi_act_scaled.signals.values(1:last_t_idx), 'LineWidth', 3)
    % set(handles_new_tada.ax_pi, 'XLim', [0 t(last_t_idx)], 'YLim', [0 1])
    
    % object enable on/off
    set(handles_new_tada.pb_saveas, 'Enable', 'on')
    set(handles_new_tada.Apply_pi2gest, 'Enable', 'off')
    set(handles_new_tada.tada, 'Name', ['Pi-applied ' upper(utt_name)])
    set(handles_new_tada.tb_gscore, 'enable', 'off')
    
    % gscore_Callback
    tada('tb_gscore_Callback', handles_new_tada.tb_gscore, [], handles_new_tada, 'pi')
end

% --- Executes on button press in pb_ed.
function pb_ed_Callback(hObject, eventdata, handles)
% hObject    handle to pb_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

load t_params
state = get(handles.tada, 'userdata');
TV_SCORE = state.TV_SCORE;
ngest = state.ngest;
i_TV = state.i_TV;
str_TV = state.str_TV;

switch i_TV
    case {i_TBCL, i_TTCL, i_TTCR}
        rescale = deg_per_rad;
    case {i_LA, i_PRO, i_TBCD, i_TTCD, i_JAW}
        rescale = mm_per_dec;
    case {i_VEL, i_GLO, i_F0 i_PI i_SPI i_TR}
        rescale = 1;
end



if strcmpi(get(handles.mn_apply2otherTVs, 'checked'), 'on') % & i_TV ~= i_LA & i_TV ~= i_PRO % edit applies to single TV (except lips due to fake PRO problem)
    [other_iTVs other_ngests] = find_otherTVGESTs(TV_SCORE, i_TV, ngest);
    for k = 1:length(other_ngests)
        if ~isempty(other_ngests{k})

            TV_SCORE(other_iTVs{k}).GEST(other_ngests{k}).BEG = str2num(get(handles.ed_beg, 'String'));
            TV_SCORE(other_iTVs{k}).GEST(other_ngests{k}).END = str2num(get(handles.ed_end, 'String'));
        end
    end
end
TV_SCORE(i_TV).GEST(ngest).BEG = str2num(get(handles.ed_beg, 'String'));
TV_SCORE(i_TV).GEST(ngest).END = str2num(get(handles.ed_end, 'String'));


TV_SCORE(i_TV).GEST(ngest).x.VALUE = str2num(get(handles.ed_x0, 'String'))/rescale;
TV_SCORE(i_TV).GEST(ngest).k.VALUE = (str2num(get(handles.ed_f, 'String'))*(2*pi))^2;
TV_SCORE(i_TV).GEST(ngest).d.VALUE = str2num(get(handles.ed_d, 'String'))*(2*sqrt(TV_SCORE(i_TV).GEST(ngest).k.VALUE));
TV_SCORE(i_TV).GEST(ngest).x.ALPHA = str2num(get(handles.ed_alpha, 'String'));
TV_SCORE(i_TV).GEST(ngest).x.BETA = str2num(get(handles.ed_beta, 'String'));
TV_SCORE(i_TV).GEST(ngest).k.ALPHA = str2num(get(handles.ed_alpha, 'String'));
TV_SCORE(i_TV).GEST(ngest).k.BETA = str2num(get(handles.ed_beta, 'String'));
TV_SCORE(i_TV).GEST(ngest).d.ALPHA = str2num(get(handles.ed_alpha, 'String'));
TV_SCORE(i_TV).GEST(ngest).d.BETA = str2num(get(handles.ed_beta, 'String'));
TV_SCORE(i_TV).GEST(ngest).w.ALPHA = str2num(get(handles.ed_alpha, 'String'));
TV_SCORE(i_TV).GEST(ngest).w.BETA = str2num(get(handles.ed_beta, 'String'));

state.TV_SCORE = TV_SCORE;

set(handles.tada, 'userdata', state);
set(handles.tb_gscore, 'value', 1)
set(handles.tb_tv, 'value', 0)
tada('tb_gscore_Callback', handles.tb_gscore, [], handles)




% --- Executes on button press in cb_ramp_act.
function cb_ramp_act_Callback(hObject, eventdata, handles)
% hObject    handle to cb_ramp_act (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_ramp_act

state = get(handles.tada, 'userdata');
if get(hObject,'Value')
    set(handles.cb_cos_ramp, 'Enable', 'on')
    set(handles.ed_ramp_frm, 'Enable', 'on')

    set(handles.tada, 'userdata', state);
    tada('tb_gscore_Callback', handles.tb_gscore, [], handles)
else
    set(handles.cb_cos_ramp, 'Enable', 'off')
    set(handles.cb_cos_ramp, 'value', 0)
    set(handles.ed_ramp_frm, 'Enable', 'off')

    set(handles.tada, 'userdata', state);    
    tada('tb_gscore_Callback', handles.tb_gscore, [], handles)
end



% --- Executes on button press in cb_cos_ramp.
function cb_cos_ramp_Callback(hObject, eventdata, handles)
% hObject    handle to cb_cos_ramp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_cos_ramp

    state = get(handles.tada, 'userdata');
    state.TV_SCORE = [];
    set(handles.tada, 'userdata', state);
    tada('tb_gscore_Callback', handles.tb_gscore, [], handles)

    
    
function ed_beg_Callback(hObject, eventdata, handles)
% hObject    handle to ed_beg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_beg as text
%        str2double(get(hObject,'String')) returns contents of ed_beg as a double

tada('pb_ed_Callback', handles.pb_ed, [], handles)


function ed_end_Callback(hObject, eventdata, handles)
% hObject    handle to ed_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_end as text
%        str2double(get(hObject,'String')) returns contents of ed_end as a double

tada('pb_ed_Callback', handles.pb_ed, [], handles)


function ed_x0_Callback(hObject, eventdata, handles)
% hObject    handle to ed_x0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_x0 as text
%        str2double(get(hObject,'String')) returns contents of ed_x0 as a double

tada('pb_ed_Callback', handles.pb_ed, [], handles)


function ed_f_Callback(hObject, eventdata, handles)
% hObject    handle to ed_f (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_f as text
%        str2double(get(hObject,'String')) returns contents of ed_f as a double

tada('pb_ed_Callback', handles.pb_ed, [], handles)


function ed_d_Callback(hObject, eventdata, handles)
% hObject    handle to ed_d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_d as text
%        str2double(get(hObject,'String')) returns contents of ed_d as a double

tada('pb_ed_Callback', handles.pb_ed, [], handles)


function ed_alpha_Callback(hObject, eventdata, handles)
% hObject    handle to ed_alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_alpha as text
%        str2double(get(hObject,'String')) returns contents of ed_alpha as a double

tada('pb_ed_Callback', handles.pb_ed, [], handles)


function ed_beta_Callback(hObject, eventdata, handles)
% hObject    handle to ed_beta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_beta as text
%        str2double(get(hObject,'String')) returns contents of ed_beta as a double

tada('pb_ed_Callback', handles.pb_ed, [], handles)

% --- Executes on button press in pb_savemavis.
function pb_savemavis_Callback(hObject, eventdata, handles)
% hObject    handle to pb_savemavis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

load t_params

[fname,pname] = uiputfile({'*.mat', 'mat Files (*.mat)'}, 'mat files');

if fname == 0
    return
end

state = get(handles.tada, 'userdata');
t_saveMview (fname, state)


function varargout = tada_WindowButtonDownFcn(h, eventdata, handles, varargin)
% Stub for WindowButtonDownFcn of the figure handles.tada.
state = get(handles.tada, 'UserData');

cp_fig = get(handles.tada, 'CurrentPoint');
ax_audiosel = get(handles.ax_audiosel, 'Position'); % left bottom width height
ax_audioall = get(handles.ax_audioall, 'Position'); % left bottom width height

if (cp_fig(1) > ax_audioall(1) & cp_fig(1) < (ax_audioall(1) + ax_audioall(3))) & (cp_fig(2) > ax_audioall(2) & cp_fig(2) < ax_audioall(2) + ax_audioall(4)) % if click in ax_audioall

    cp_ax = get(handles.ax_audioall, 'CurrentPoint');
    pc_x = get(handles.pc_sel, 'xdata');
    xl = get(handles.ax_audioall, 'xlim');

    if strcmp(get(gcbf, 'selectionType'), 'open')
        set(handles.pc_sel, 'xdata', [xl(1) xl(1) xl(2) xl(2)])
        state.SELBTNDN = 4;
    else

        trsh = (xl(2)-xl(1))/80;
        if cp_ax(1,1) <= pc_x(1) + trsh & cp_ax(1,1) >= pc_x(1) - trsh
            state.SELBTNDN = 1;
        end

        if cp_ax(1,1) >= pc_x(3) - trsh & cp_ax(1,1) <= pc_x(3) + trsh
            state.SELBTNDN = 2;
        end

        if cp_ax(1,1) > pc_x(1) +trsh & cp_ax(1,1) < pc_x(3) - trsh
            state.SELBTNDN = 3;
            state.PREVPNT = cp_ax;
        end
    end
    set(handles.tada, 'UserData', state)
end

if (cp_fig(1) > ax_audiosel(1) & cp_fig(1) < (ax_audiosel(1) + ax_audiosel(3))) & (cp_fig(2) > ax_audiosel(2) & cp_fig(2) < ax_audiosel(2) + ax_audiosel(4)) % if click in ax_audiosel
    state.BTNDOWN = 1;
    if get(handles.tb_gscore, 'value') | get(handles.tb_tv, 'value')
        cp_axes = get(handles.ax_audiosel, 'CurrentPoint');
        cur_x = cp_axes(2,1);
        set(handles.ed_curfrm, 'String', ceil(cur_x/2))

        if get(handles.tb_gscore, 'value')
            h_ln = [handles.ln_gs_lips; handles.ln_gs_tb; handles.ln_gs_tt; handles.ln_gs_vel; handles.ln_gs_glo; handles.ln_gs_jaw];
        else
            h_ln = [handles.ln_tv_lips; handles.ln_tv_tb; handles.ln_tv_tt; handles.ln_tv_vel; handles.ln_tv_glo; handles.ln_tv_jaw];
        end

        trj_lips = get(h_ln(1,1), 'YData');
        set(handles.ed_lips, 'String', sprintf('%.2f', trj_lips(round(cur_x))))
        trj_tb = get(h_ln(2,1), 'YData');
        set(handles.ed_tb, 'String', sprintf('%.2f', trj_tb(round(cur_x))))
        trj_tt = get(h_ln(3,1), 'YData');
        set(handles.ed_tt, 'String', sprintf('%.2f', trj_tt(round(cur_x))))
        trj_vel = get(h_ln(4,1), 'YData');
        set(handles.ed_vel, 'String', sprintf('%.2f', trj_vel(round(cur_x))))
        trj_glo = get(h_ln(5,1), 'YData');
        set(handles.ed_glo, 'String', sprintf('%.2f', trj_glo(round(cur_x))))
        trj_jaw = get(h_ln(6,1), 'YData');
        set(handles.ed_jaw, 'String', sprintf('%.2f', trj_jaw(round(cur_x))))

        set(gcf,'CurrentAxes',handles.ax_line)
        set(handles.ln_cl, 'XData', [cur_x cur_x])

        if get(handles.tb_tv, 'Value')
            ASYPEL = state.ASYPEL;
            hyoid = state.HYOID;
            AREA = state.AREA;
            
            cur_x = ceil(cur_x);
            x_spat2d = [ASYPEL(1).SIGNAL(1,cur_x) ...
                ASYPEL(2).SIGNAL(1,cur_x) ...
                ASYPEL(3).SIGNAL(1,cur_x) ...
                ASYPEL(4).SIGNAL(1,cur_x) ...
                ASYPEL(6).SIGNAL(1,cur_x) ...
                ASYPEL(7).SIGNAL(1,cur_x) ...
                ASYPEL(8).SIGNAL(1,cur_x) ...
                hyoid(1)];
            y_spat2d = [ASYPEL(1).SIGNAL(2,cur_x) ...
                ASYPEL(2).SIGNAL(2,cur_x) ...
                ASYPEL(3).SIGNAL(2,cur_x) ...
                ASYPEL(4).SIGNAL(2,cur_x) ...
                ASYPEL(6).SIGNAL(2,cur_x) ...
                ASYPEL(7).SIGNAL(2,cur_x) ...
                ASYPEL(8).SIGNAL(2,cur_x) ...
                hyoid(2)];

            % axis square
            xx = linspace(min(x_spat2d(4:end-1)), max(x_spat2d(4:end-1)));
            yy = interp1(x_spat2d(4:end-1), y_spat2d(4:end-1), xx, '*PCHIP');

            set(handles.ln_pels_ul, 'xdata', x_spat2d(1), 'ydata', y_spat2d(1));
            set(handles.ln_pels_ll, 'xdata', x_spat2d(2), 'ydata', y_spat2d(2));
            set(handles.ln_pels_jaw, 'xdata', x_spat2d(3), 'ydata', y_spat2d(3));
            set(handles.ln_pels_tt, 'xdata', x_spat2d(4), 'ydata', y_spat2d(4));
            set(handles.ln_pels_tf, 'xdata', x_spat2d(7), 'ydata', y_spat2d(7));
            set(handles.ln_pels_td, 'xdata', x_spat2d(6), 'ydata', y_spat2d(6));
            set(handles.ln_pels_tr, 'xdata', x_spat2d(5), 'ydata', y_spat2d(5));

            set(handles.cln_pels_ul, 'xdata', x_spat2d(1), 'ydata', y_spat2d(1));
            set(handles.cln_pels_ll, 'xdata', x_spat2d(2), 'ydata', y_spat2d(2));
            set(handles.cln_pels_jaw, 'xdata', x_spat2d(3), 'ydata', y_spat2d(3));
            set(handles.cln_pels_tt, 'xdata', x_spat2d(4), 'ydata', y_spat2d(4));
            set(handles.cln_pels_tf, 'xdata', x_spat2d(7), 'ydata', y_spat2d(7));
            set(handles.cln_pels_td, 'xdata', x_spat2d(6), 'ydata', y_spat2d(6));
            set(handles.cln_pels_tr, 'xdata', x_spat2d(5), 'ydata', y_spat2d(5));

            set(handles.ln_intpl, 'xdata', xx, 'ydata', yy);
            set(handles.ln_area, 'xdata', state.TUBELENGTHSMOOTH(ceil(cur_x),:), 'ydata', state.AREA(ceil(cur_x),:))
            set(handles.ln_upperoutline, 'xdata', state.UPPEROUTLINE(:,1,ceil(cur_x)), 'ydata', state.UPPEROUTLINE(:,2,ceil(cur_x)))
            set(handles.ln_bottomoutline, 'xdata', state.BOTTOMOUTLINE(:,1,ceil(cur_x)), 'ydata', state.BOTTOMOUTLINE(:,2,ceil(cur_x)))
            set(handles.ln_velumopen, 'xdata', state.UPPEROUTLINE(4:5,1,ceil(cur_x)), 'ydata', state.UPPEROUTLINE(4:5,2,ceil(cur_x)))
            
            set(handles.tada, 'userdata', state);
        end
        state.cur_x = cur_x;
        set(handles.tada, 'UserData', state)
    end
end


% --- Executes on mouse motion over figure - except title and menu.
function tada_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to tada (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%xy = get(handles.ax_lips, 'CurrentPoint')

state = get(handles.tada, 'UserData');
if state.BTNDOWN
    cp_axes = get(handles.ax_audiosel, 'CurrentPoint');
    cur_x = cp_axes(2,1);
    xl = get(handles.ax_audiosel, 'xlim');
    if cur_x >= xl(1) & cur_x <= xl(2)
        set(handles.ln_cl, 'XData', [cur_x cur_x])
        set(handles.ed_curfrm, 'String', ceil(cur_x/2))

        if get(handles.tb_gscore, 'value')
            h_ln = [handles.ln_gs_lips; handles.ln_gs_tb; handles.ln_gs_tt; handles.ln_gs_vel; handles.ln_gs_glo; handles.ln_gs_jaw];
        else
            h_ln = [handles.ln_tv_lips; handles.ln_tv_tb; handles.ln_tv_tt; handles.ln_tv_vel; handles.ln_tv_glo; handles.ln_tv_jaw];
        end

        trj_lips = get(h_ln(1,1), 'YData');
        set(handles.ed_lips, 'String', sprintf('%.2f', trj_lips(ceil(cur_x))))

        trj_tb = get(h_ln(2,1), 'YData');
        set(handles.ed_tb, 'String', sprintf('%.2f', trj_tb(ceil(cur_x))))

        trj_tt = get(h_ln(3,1), 'YData');
        set(handles.ed_tt, 'String', sprintf('%.2f', trj_tt(ceil(cur_x))))

        trj_vel = get(h_ln(4,1), 'YData');
        set(handles.ed_vel, 'String', sprintf('%.2f', trj_vel(ceil(cur_x))))

        trj_glo = get(h_ln(5,1), 'YData');
        set(handles.ed_glo, 'String', sprintf('%.2f', trj_glo(ceil(cur_x))))

        trj_jaw = get(h_ln(6,1), 'YData');
        set(handles.ed_jaw, 'String', sprintf('%.2f', trj_jaw(ceil(cur_x))))

        if get(handles.tb_tv, 'Value')
            if strcmpi(get(handles.mn_LowGraphic, 'checked'), 'off')

                hyoid = state.HYOID;

                ASYPEL = state.ASYPEL;
                cur_x = ceil(cur_x);

                x_spat2d = [ASYPEL(1).SIGNAL(1,cur_x) ...
                    ASYPEL(2).SIGNAL(1,cur_x) ...
                    ASYPEL(3).SIGNAL(1,cur_x) ...
                    ASYPEL(4).SIGNAL(1,cur_x) ...
                    ASYPEL(6).SIGNAL(1,cur_x) ...
                    ASYPEL(7).SIGNAL(1,cur_x) ...
                    ASYPEL(8).SIGNAL(1,cur_x) ...
                    hyoid(1)];
                y_spat2d = [ASYPEL(1).SIGNAL(2,cur_x) ...
                    ASYPEL(2).SIGNAL(2,cur_x) ...
                    ASYPEL(3).SIGNAL(2,cur_x) ...
                    ASYPEL(4).SIGNAL(2,cur_x) ...
                    ASYPEL(6).SIGNAL(2,cur_x) ...
                    ASYPEL(7).SIGNAL(2,cur_x) ...
                    ASYPEL(8).SIGNAL(2,cur_x) ...
                    hyoid(2)];

                % axis square
                xx = linspace(min(x_spat2d(4:end-1)), max(x_spat2d(4:end-1)));
                yy = interp1(x_spat2d(4:end-1), y_spat2d(4:end-1), xx, '*PCHIP');

                set(handles.ln_pels_ul, 'xdata', x_spat2d(1), 'ydata', y_spat2d(1));
                set(handles.ln_pels_ll, 'xdata', x_spat2d(2), 'ydata', y_spat2d(2));
                set(handles.ln_pels_jaw, 'xdata', x_spat2d(3), 'ydata', y_spat2d(3));
                set(handles.ln_pels_tt, 'xdata', x_spat2d(4), 'ydata', y_spat2d(4));
                set(handles.ln_pels_tf, 'xdata', x_spat2d(7), 'ydata', y_spat2d(7));
                set(handles.ln_pels_td, 'xdata', x_spat2d(6), 'ydata', y_spat2d(6));
                set(handles.ln_pels_tr, 'xdata', x_spat2d(5), 'ydata', y_spat2d(5));

                set(handles.cln_pels_ul, 'xdata', x_spat2d(1), 'ydata', y_spat2d(1));
                set(handles.cln_pels_ll, 'xdata', x_spat2d(2), 'ydata', y_spat2d(2));
                set(handles.cln_pels_jaw, 'xdata', x_spat2d(3), 'ydata', y_spat2d(3));
                set(handles.cln_pels_tt, 'xdata', x_spat2d(4), 'ydata', y_spat2d(4));
                set(handles.cln_pels_tf, 'xdata', x_spat2d(7), 'ydata', y_spat2d(7));
                set(handles.cln_pels_td, 'xdata', x_spat2d(6), 'ydata', y_spat2d(6));
                set(handles.cln_pels_tr, 'xdata', x_spat2d(5), 'ydata', y_spat2d(5));

                set(handles.ln_intpl, 'xdata', xx, 'ydata', yy);
            
            set(handles.ln_area, 'xdata', state.TUBELENGTHSMOOTH(ceil(cur_x),:), 'ydata', state.AREA(ceil(cur_x),:))
            set(handles.ln_upperoutline, 'xdata', state.UPPEROUTLINE(:,1,ceil(cur_x)), 'ydata', state.UPPEROUTLINE(:,2,ceil(cur_x)))
            set(handles.ln_bottomoutline, 'xdata', state.BOTTOMOUTLINE(:,1,ceil(cur_x)), 'ydata', state.BOTTOMOUTLINE(:,2,ceil(cur_x)))
            set(handles.ln_velumopen, 'xdata', state.UPPEROUTLINE(4:5,1,ceil(cur_x)), 'ydata', state.UPPEROUTLINE(4:5,2,ceil(cur_x)))
            end
        end

    end
end

if state.SELBTNDN == 1
    cp_ax = get(handles.ax_audioall, 'CurrentPoint');
    pc_x = get(handles.pc_sel, 'xdata');
    xl = get(handles.ax_audioall, 'xlim');
    if cp_ax(1,1) >= xl(1)
        pc_x(1:2) = cp_ax(1,1);
        set(handles.pc_sel, 'xdata', pc_x)
    end
end

if state.SELBTNDN == 2
    cp_ax = get(handles.ax_audioall, 'CurrentPoint');
    pc_x = get(handles.pc_sel, 'xdata');
    xl = get(handles.ax_audioall, 'xlim');
    if cp_ax(1,1) <= xl(2)
        pc_x(3:4) = cp_ax(1,1);
        set(handles.pc_sel, 'xdata', pc_x)
    end
end

if state.SELBTNDN == 3
    prevpnt_ax = state.PREVPNT;
    cp_ax = get(handles.ax_audioall, 'CurrentPoint');
    pc_x = get(handles.pc_sel, 'xdata');
    mv = cp_ax(1,1) - prevpnt_ax(1,1);
    pc_x(1:4) = pc_x(1:4) + mv;
    xl = get(handles.ax_audioall, 'xlim');
    if pc_x(1) >= xl(1) & pc_x(3) <= xl(2)
        state.PREVPNT = cp_ax;
        set(handles.pc_sel, 'xdata', pc_x)
    end
end

if state.MOVGESTBTN == 1
    state = get(handles.tada, 'userdata');
    cp_ax = get(gca, 'CurrentPoint');
    mov_dist = cp_ax(2,1) - state.clicked_cur_x;
    state.clicked_cur_x = cp_ax(2,1);
    pos_rt = get(state.h_rt_selGest, 'position'); if ~iscell(pos_rt), pos_rt= {pos_rt}; end


    outrng = 0;
    for k = 1:length(state.h_rt_selGest)
        h_axes = selAxes(state.sel_iTVs(k), handles);
        x = get(h_axes,'xlim');
        pos_rt{k}(1) = pos_rt{k}(1) + mov_dist;
        if pos_rt{k}(1) < x(1) | pos_rt{k}(1)+pos_rt{k}(3) > x(2)
            outrng = 1;
        end
    end

    if outrng ~= 1
        for k = 1:length(state.h_rt_selGest)
            set(state.h_rt_selGest(k), 'position', pos_rt{k})
        end
    end

end

if state.MODGESTBTN > 0
    state = get(handles.tada, 'userdata');
    cp_ax = get(gca, 'CurrentPoint');
    mov_dist = cp_ax(2,1) - state.clicked_cur_x;
    state.clicked_cur_x = cp_ax(2,1);
    pos_rt = get(state.h_rt_selGest, 'position'); if ~iscell(pos_rt), pos_rt= {pos_rt}; end

    outrng = 0;
    for k = 1:length(state.h_rt_selGest)
        h_axes = selAxes(state.sel_iTVs(k), handles);
        x = get(h_axes,'xlim');

        if state.MODGESTBTN == 1
            pos_rt{k}(1) = pos_rt{k}(1) + mov_dist;
            pos_rt{k}(3) = pos_rt{k}(3) - mov_dist;
        elseif state.MODGESTBTN == 2
            pos_rt{k}(1) = pos_rt{k}(1) ;
            pos_rt{k}(3) = pos_rt{k}(3) + mov_dist;
        end

        if pos_rt{k}(1) < x(1) | pos_rt{k}(1)+pos_rt{k}(3)> x(2)
            outrng = 1;
        end
    end
    if outrng ~= 1
        for k = 1:length(state.h_rt_selGest)
            set(state.h_rt_selGest(k), 'position', pos_rt{k})
        end
    end
end

set(handles.tada, 'UserData', state)



% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function tada_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to tada (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load t_params
state = get(handles.tada, 'UserData');

if state.SELBTNDN > 0
    xl = get(handles.pc_sel, 'xdata');
    XLim = [xl(1) xl(3)];
    set(handles.ax_audiosel, 'XLim', [XLim(1) XLim(2)])
    set(handles.ax_lips, 'XLim', [XLim(1) XLim(2)])
    set(handles.ax_tb, 'XLim', [XLim(1) XLim(2)])
    set(handles.ax_tt, 'XLim', [XLim(1) XLim(2)])
    set(handles.ax_jaw, 'XLim', [XLim(1) XLim(2)])
    set(handles.ax_vel, 'XLim', [XLim(1) XLim(2)])
    set(handles.ax_glo, 'XLim', [XLim(1) XLim(2)])
    set(handles.ax_F0, 'XLim', [XLim(1) XLim(2)])
    set(handles.ax_pi, 'XLim', [XLim(1) XLim(2)])
    set(handles.ax_spi, 'XLim', [XLim(1) XLim(2)])
    set(handles.ax_tr, 'XLim', [XLim(1) XLim(2)])
    set(handles.ax_asy_ul, 'XLim', [XLim(1) XLim(2)])
    set(handles.ax_asy_ll, 'XLim', [XLim(1) XLim(2)])
    set(handles.ax_asy_jaw, 'XLim', [XLim(1) XLim(2)])
    set(handles.ax_asy_tt, 'XLim', [XLim(1) XLim(2)])
    set(handles.ax_asy_tf, 'XLim', [XLim(1) XLim(2)])
    set(handles.ax_asy_tr, 'XLim', [XLim(1) XLim(2)])
    set(handles.ax_asy_td, 'XLim', [XLim(1) XLim(2)])
    set(handles.ax_line, 'XLim', [XLim(1) XLim(2)])
    set(handles.ax_a_lx, 'XLim', [XLim(1) XLim(2)])
    set(handles.ax_a_ja, 'XLim', [XLim(1) XLim(2)])
    set(handles.ax_a_uy, 'XLim', [XLim(1) XLim(2)])
    set(handles.ax_a_ly, 'XLim', [XLim(1) XLim(2)])
    set(handles.ax_a_cl, 'XLim', [XLim(1) XLim(2)])
    set(handles.ax_a_ca, 'XLim', [XLim(1) XLim(2)])
    set(handles.ax_a_tl, 'XLim', [XLim(1) XLim(2)])
    set(handles.ax_a_ta, 'XLim', [XLim(1) XLim(2)])
    set(handles.ax_a_na, 'XLim', [XLim(1) XLim(2)])
    set(handles.ax_a_gw, 'XLim', [XLim(1) XLim(2)])
    set(handles.ax_formants, 'XLim', [XLim(1)/(state.ms_frm/wag_frm) XLim(2)/(state.ms_frm/wag_frm)])
    %refresh
end

if state.BTNDOWN == 1 &  strcmpi(get(handles.mn_LowGraphic, 'checked'), 'on') & get(handles.tb_tv, 'Value')
    cp_axes = get(handles.ax_audiosel, 'CurrentPoint');
    cur_x =  cp_axes(2,1);
    xl = get(handles.ax_audiosel, 'xlim');
    
            set(handles.ed_curfrm, 'String', ceil(cur_x/2))

        if get(handles.tb_gscore, 'value')
            h_ln = [handles.ln_gs_lips; handles.ln_gs_tb; handles.ln_gs_tt; handles.ln_gs_vel; handles.ln_gs_glo; handles.ln_gs_jaw];
        else
            h_ln = [handles.ln_tv_lips; handles.ln_tv_tb; handles.ln_tv_tt; handles.ln_tv_vel; handles.ln_tv_glo; handles.ln_tv_jaw];
        end

        trj_lips = get(h_ln(1,1), 'YData');
        set(handles.ed_lips, 'String', sprintf('%.2f', trj_lips(ceil(cur_x))))

        trj_tb = get(h_ln(2,1), 'YData');
        set(handles.ed_tb, 'String', sprintf('%.2f', trj_tb(ceil(cur_x))))

        trj_tt = get(h_ln(3,1), 'YData');
        set(handles.ed_tt, 'String', sprintf('%.2f', trj_tt(ceil(cur_x))))

        trj_vel = get(h_ln(4,1), 'YData');
        set(handles.ed_vel, 'String', sprintf('%.2f', trj_vel(ceil(cur_x))))

        trj_glo = get(h_ln(5,1), 'YData');
        set(handles.ed_glo, 'String', sprintf('%.2f', trj_glo(ceil(cur_x))))

        trj_jaw = get(h_ln(6,1), 'YData');
        set(handles.ed_jaw, 'String', sprintf('%.2f', trj_jaw(ceil(cur_x))))

        if get(handles.tb_tv, 'Value')
            hyoid = state.HYOID;

            ASYPEL = state.ASYPEL;
            cur_x = ceil(cur_x);

            x_spat2d = [ASYPEL(1).SIGNAL(1,cur_x) ...
                ASYPEL(2).SIGNAL(1,cur_x) ...
                ASYPEL(3).SIGNAL(1,cur_x) ...
                ASYPEL(4).SIGNAL(1,cur_x) ...
                ASYPEL(6).SIGNAL(1,cur_x) ...
                ASYPEL(7).SIGNAL(1,cur_x) ...
                ASYPEL(8).SIGNAL(1,cur_x) ...
                hyoid(1)];
            y_spat2d = [ASYPEL(1).SIGNAL(2,cur_x) ...
                ASYPEL(2).SIGNAL(2,cur_x) ...
                ASYPEL(3).SIGNAL(2,cur_x) ...
                ASYPEL(4).SIGNAL(2,cur_x) ...
                ASYPEL(6).SIGNAL(2,cur_x) ...
                ASYPEL(7).SIGNAL(2,cur_x) ...
                ASYPEL(8).SIGNAL(2,cur_x) ...
                hyoid(2)];

            % axis square
            xx = linspace(min(x_spat2d(4:end-1)), max(x_spat2d(4:end-1)));
            yy = interp1(x_spat2d(4:end-1), y_spat2d(4:end-1), xx, '*PCHIP');

            set(handles.ln_pels_ul, 'xdata', x_spat2d(1), 'ydata', y_spat2d(1));
            set(handles.ln_pels_ll, 'xdata', x_spat2d(2), 'ydata', y_spat2d(2));
            set(handles.ln_pels_jaw, 'xdata', x_spat2d(3), 'ydata', y_spat2d(3));
            set(handles.ln_pels_tt, 'xdata', x_spat2d(4), 'ydata', y_spat2d(4));
            set(handles.ln_pels_tf, 'xdata', x_spat2d(7), 'ydata', y_spat2d(7));
            set(handles.ln_pels_td, 'xdata', x_spat2d(6), 'ydata', y_spat2d(6));
            set(handles.ln_pels_tr, 'xdata', x_spat2d(5), 'ydata', y_spat2d(5));

            set(handles.cln_pels_ul, 'xdata', x_spat2d(1), 'ydata', y_spat2d(1));
            set(handles.cln_pels_ll, 'xdata', x_spat2d(2), 'ydata', y_spat2d(2));
            set(handles.cln_pels_jaw, 'xdata', x_spat2d(3), 'ydata', y_spat2d(3));
            set(handles.cln_pels_tt, 'xdata', x_spat2d(4), 'ydata', y_spat2d(4));
            set(handles.cln_pels_tf, 'xdata', x_spat2d(7), 'ydata', y_spat2d(7));
            set(handles.cln_pels_td, 'xdata', x_spat2d(6), 'ydata', y_spat2d(6));
            set(handles.cln_pels_tr, 'xdata', x_spat2d(5), 'ydata', y_spat2d(5));

            set(handles.ln_intpl, 'xdata', xx, 'ydata', yy);

            
            
    if cur_x >= xl(1) & cur_x <= xl(2)
            set(handles.ln_area, 'xdata', state.TUBELENGTHSMOOTH(ceil(cur_x),:), 'ydata', state.AREA(ceil(cur_x),:))
            set(handles.ln_upperoutline, 'xdata', state.UPPEROUTLINE(:,1,ceil(cur_x)), 'ydata', state.UPPEROUTLINE(:,2,ceil(cur_x)))
            set(handles.ln_bottomoutline, 'xdata', state.BOTTOMOUTLINE(:,1,ceil(cur_x)), 'ydata', state.BOTTOMOUTLINE(:,2,ceil(cur_x)))
            set(handles.ln_velumopen, 'xdata', state.UPPEROUTLINE(4:5,1,ceil(cur_x)), 'ydata', state.UPPEROUTLINE(4:5,2,ceil(cur_x)))
    end
        end








end


if state.MOVGESTBTN == 1 | state.MODGESTBTN > 0 % when moving a gesture box or modifying the size
    TV_SCORE = state.TV_SCORE;
    pos_rt = get(state.h_rt_selGest, 'position');  if ~iscell(pos_rt), pos_rt= {pos_rt}; end
    sel_iTVs = state.sel_iTVs;
    sel_ngests = state.sel_ngests;

    if strcmpi(get(handles.mn_apply2otherTVs, 'checked'), 'on')% & i_TV ~= i_LA & i_TV ~= i_PRO % edit applies to single TV (except lips due to fake PRO problem)
        [other_iTVs other_ngests] = find_otherTVGESTs(TV_SCORE, sel_iTVs, sel_ngests);

        for k = 1:length(other_ngests)
            if ~isempty(other_ngests{k})
                TV_SCORE(other_iTVs{k}).GEST(other_ngests{k}).BEG = round(pos_rt{k}(1)/2);
                TV_SCORE(other_iTVs{k}).GEST(other_ngests{k}).END = round((pos_rt{k}(1)+pos_rt{k}(3))/2);

                if state.MODGESTBTN > 0 & strcmpi(get(handles.mn_proportionalFreq, 'checked'), 'on') % k proportional to gestural interval
                    omega_10frm = 6;
                    prevDamp = TV_SCORE(other_iTVs{k}).GEST(other_ngests{k}).d.VALUE/2/sqrt(TV_SCORE(other_iTVs{k}).GEST(other_ngests{k}).k.VALUE);

                    TV_SCORE(other_iTVs{k}).GEST(other_ngests{k}).k.VALUE =...
                        (omega_10frm*10/(TV_SCORE(other_iTVs{k}).GEST(other_ngests{k}).END - TV_SCORE(other_iTVs{k}).GEST(other_ngests{k}).BEG)*(2*pi))^2;

                    TV_SCORE(other_iTVs{k}).GEST(other_ngests{k}).d.VALUE = prevDamp *2 *sqrt(TV_SCORE(other_iTVs{k}).GEST(other_ngests{k}).k.VALUE);
                end
            end
        end
    end

    for k = 1:length(sel_ngests)

        TV_SCORE(sel_iTVs(k)).GEST(sel_ngests(k)).BEG = round(pos_rt{k}(1)/2);
        TV_SCORE(sel_iTVs(k)).GEST(sel_ngests(k)).END = round((pos_rt{k}(1)+pos_rt{k}(3))/2);

        if state.MODGESTBTN > 0 & strcmpi(get(handles.mn_proportionalFreq, 'checked'), 'on') % k proportional to gestural interval
            omega_10frm = 6;
            prevDamp = TV_SCORE(sel_iTVs(k)).GEST(sel_ngests(k)).d.VALUE/2/sqrt(TV_SCORE(sel_iTVs(k)).GEST(sel_ngests(k)).k.VALUE);

            TV_SCORE(sel_iTVs(k)).GEST(sel_ngests(k)).k.VALUE =...
                (omega_10frm*10/(TV_SCORE(sel_iTVs(k)).GEST(sel_ngests(k)).END - TV_SCORE(sel_iTVs(k)).GEST(sel_ngests(k)).BEG)*(2*pi))^2;

            TV_SCORE(sel_iTVs(k)).GEST(sel_ngests(k)).d.VALUE = prevDamp *2 *sqrt(TV_SCORE(sel_iTVs(k)).GEST(sel_ngests(k)).k.VALUE);
        end
    end


    state.MOVGESTBTN = 0;
    state.MODGESTBTN = 0;

    state.TV_SCORE = TV_SCORE;
    
    set(handles.tada, 'userdata', state)
    set(handles.tb_gscore, 'value', 1)
    set(handles.tb_tv, 'value', 0)
    
    tada('tb_gscore_Callback', handles.tb_gscore, [], handles)
    state = get(handles.tada, 'UserData'); % This line should be present.
end



state.BTNDOWN = 0;
state.SELBTNDN = 0;
state.PREVPNT = 0;


if state.OSC_flg ==1
    tada('tb_osclink_Callback', handles.tb_osclink, [], handles)
end

set(handles.tada, 'UserData', state)


function [other_iTVs other_ngests] =find_otherTVGESTs(TV_SCORE, sel_iTVs, sel_ngests)
load t_params
other_iTVs= [];
other_ngests= [];
for i = 1:length(sel_iTVs)
    i_TV = sel_iTVs(i);
    ngests = sel_ngests(i);
    switch i_TV
        case {i_TBCL}
            i_OTHER_TV = [i_TBCD];
        case {i_TBCD}
            i_OTHER_TV = [i_TBCL];
        case {i_TTCD}
            i_OTHER_TV = [i_TTCL];
        case {i_TTCL}
            i_OTHER_TV = [i_TTCD];
        case {i_LA}
            i_OTHER_TV = [i_PRO];
        case {i_PRO}
            i_OTHER_TV = [i_LA];
        case {i_VEL}
            i_OTHER_TV = [];
        case {i_GLO}
            i_OTHER_TV = [];
        case {i_F0}
            i_OTHER_TV = [];
        case {i_PI}
            i_OTHER_TV = [];
        case {i_SPI}
            i_OTHER_TV = [];
        case {i_TR}
            i_OTHER_TV = [];
    end

    B0 = TV_SCORE(i_TV).GEST(ngests).BEG;
    E0 = TV_SCORE(i_TV).GEST(ngests).END;

    iBEG = [TV_SCORE(i_OTHER_TV).GEST.BEG] == B0;
    iEND = [TV_SCORE(i_OTHER_TV).GEST.END] == E0;
    i_OTHER_GEST = find(iBEG == iEND & ~(iBEG == 0 & iEND ==0));
    other_iTVs{i} = i_OTHER_TV;
    other_ngests{i} = i_OTHER_GEST;
end
    


% --- Executes on button press in pb_seltraj.
function pb_seltraj_Callback(hObject, eventdata, handles)
% hObject    handle to pb_seltraj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
all_list = get(handles.lb_alltraj, 'string');
idx_add = get(handles.lb_alltraj, 'value');
add_list = all_list(idx_add);
sel_list = get(handles.lb_seltraj, 'string');

for i = 1:length(idx_add)
    if isempty(strmatch(add_list(i), sel_list, 'exact'))
        sel_list = [sel_list; add_list(i)];
    end
end
set(handles.lb_alltraj, 'value', [])
set(handles.lb_seltraj, 'value', [])
set(handles.lb_seltraj, 'string', sel_list)




% --- Executes on button press in pb_deltraj.
function pb_deltraj_Callback(hObject, eventdata, handles)
% hObject    handle to pb_deltraj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sel_list = get(handles.lb_seltraj, 'string');
idx_del = get(handles.lb_seltraj, 'value');
if idx_del
    sel_list(idx_del) = [];
    set(handles.lb_seltraj, 'value', [])
    set(handles.lb_seltraj, 'string', sel_list)
end



% --- Executes on button press in pb_acttraj.
function pb_acttraj_Callback(hObject, eventdata, handles)
% hObject    handle to pb_acttraj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

state = get(handles.tada, 'userdata');
n_frm = state.n_frm;

set(handles.ax_lips, 'visible', 'off')
set(handles.ax_tb, 'visible', 'off')
set(handles.ax_tt, 'visible', 'off')
set(handles.ax_jaw, 'visible', 'off')
set(handles.ax_vel, 'visible', 'off')
set(handles.ax_glo, 'visible', 'off')
set(handles.ax_pi, 'visible', 'off')
set(handles.ax_F0, 'visible', 'off')
set(handles.ax_spi, 'visible', 'off')
set(handles.ax_tr, 'visible', 'off')

set(handles.ln_gs_lips, 'visible', 'off')
set(handles.ln_gs_tb, 'visible', 'off')
set(handles.ln_gs_tt, 'visible', 'off')
set(handles.ln_gs_jaw, 'visible', 'off')
set(handles.ln_gs_vel, 'visible', 'off')
set(handles.ln_gs_glo, 'visible', 'off')
set(handles.ln_gs_F0, 'visible', 'off')
set(handles.ln_gs_pi, 'visible', 'off')
set(handles.ln_gs_spi, 'visible', 'off')
set(handles.ln_gs_tr, 'visible', 'off')

set(handles.ln_tv_lips, 'visible', 'off')
set(handles.ln_tv_tb, 'visible', 'off')
set(handles.ln_tv_tt, 'visible', 'off')
set(handles.ln_tv_jaw, 'visible', 'off')
set(handles.ln_tv_vel, 'visible', 'off')
set(handles.ln_tv_glo, 'visible', 'off')
set(handles.ln_tv_pi, 'visible', 'off')
set(handles.ln_tv_F0, 'visible', 'off')
set(handles.ln_tv_spi, 'visible', 'off')
set(handles.ln_tv_tr, 'visible', 'off')

set(handles.ax_asy_ul, 'visible', 'off')
set(handles.ax_asy_ll, 'visible', 'off')
set(handles.ax_asy_jaw, 'visible', 'off')
set(handles.ax_asy_tt, 'visible', 'off')
set(handles.ax_asy_tf, 'visible', 'off')
set(handles.ax_asy_tr, 'visible', 'off')
set(handles.ax_asy_td, 'visible', 'off')

set(handles.ln_asy_ulx, 'visible', 'off')
set(handles.ln_asy_llx, 'visible', 'off')
set(handles.ln_asy_jawx, 'visible', 'off')
set(handles.ln_asy_ttx, 'visible', 'off')
set(handles.ln_asy_tfx, 'visible', 'off')
set(handles.ln_asy_trx, 'visible', 'off')
set(handles.ln_asy_tdx, 'visible', 'off')

set(handles.ln_asy_uly, 'visible', 'off')
set(handles.ln_asy_lly, 'visible', 'off')
set(handles.ln_asy_jawy, 'visible', 'off')
set(handles.ln_asy_tty, 'visible', 'off')
set(handles.ln_asy_tfy, 'visible', 'off')
set(handles.ln_asy_try, 'visible', 'off')
set(handles.ln_asy_tdy, 'visible', 'off')

set(handles.ax_a_lx, 'visible', 'off')
set(handles.ax_a_ja, 'visible', 'off')
set(handles.ax_a_uy, 'visible', 'off')
set(handles.ax_a_ly, 'visible', 'off')
set(handles.ax_a_cl, 'visible', 'off')
set(handles.ax_a_ca, 'visible', 'off')
set(handles.ax_a_tl, 'visible', 'off')
set(handles.ax_a_ta, 'visible', 'off')
set(handles.ax_a_na, 'visible', 'off')
set(handles.ax_a_gw, 'visible', 'off')

set(handles.ln_a_lx, 'visible', 'off')
set(handles.ln_a_ja, 'visible', 'off')
set(handles.ln_a_uy, 'visible', 'off')
set(handles.ln_a_ly, 'visible', 'off')
set(handles.ln_a_cl, 'visible', 'off')
set(handles.ln_a_ca, 'visible', 'off')
set(handles.ln_a_tl, 'visible', 'off')
set(handles.ln_a_ta, 'visible', 'off')
set(handles.ln_a_na, 'visible', 'off')
set(handles.ln_a_gw, 'visible', 'off')

set(handles.ax_formants, 'visible', 'off')
set(handles.ln_F1, 'visible', 'off')
set(handles.ln_F2, 'visible', 'off')
set(handles.ln_F3, 'visible', 'off')
set(handles.ln_F4, 'visible', 'off')

set(handles.tx_lips, 'visible', 'off')
set(handles.tx_tb, 'visible', 'off')
set(handles.tx_tt, 'visible', 'off')
set(handles.tx_vel, 'visible', 'off')
set(handles.tx_glo, 'visible', 'off')
set(handles.tx_F0, 'visible', 'off')
set(handles.tx_pi, 'visible', 'off')
set(handles.tx_spi, 'visible', 'off')
set(handles.tx_tr, 'visible', 'off')

set(handles.tx_asy_ul, 'visible', 'off')
set(handles.tx_asy_ll, 'visible', 'off')
set(handles.tx_asy_jaw, 'visible', 'off')
set(handles.tx_asy_tt, 'visible', 'off')
set(handles.tx_asy_tf, 'visible', 'off')
set(handles.tx_asy_tr, 'visible', 'off')
set(handles.tx_asy_td, 'visible', 'off')

set(handles.tx_a_lx, 'visible', 'off')
set(handles.tx_a_ja, 'visible', 'off')
set(handles.tx_a_uy, 'visible', 'off')
set(handles.tx_a_ly, 'visible', 'off')
set(handles.tx_a_cl, 'visible', 'off')
set(handles.tx_a_ca, 'visible', 'off')
set(handles.tx_a_tl, 'visible', 'off')
set(handles.tx_a_ta, 'visible', 'off')
set(handles.tx_a_na, 'visible', 'off')
set(handles.tx_a_gw, 'visible', 'off')
set(handles.tx_formants, 'visible', 'off')

all_list = get(handles.lb_alltraj, 'string');
sel_list = get(handles.lb_seltraj, 'string');
n_ax = length(sel_list);

tPos = get(handles.ax_audiosel, 'position');
bPos = 0.037037037037037056;
x = tPos(1); w = tPos(3);
h = (tPos(2)-bPos)/n_ax; t = tPos(2); 

for i = 1:n_ax
    if strmatch(sel_list(i), 'LIPS', 'exact')
        h_ax = handles.ax_lips; h_ln = [handles.ln_gs_lips handles.ln_tv_lips];
        h_tx = handles.tx_lips;
    elseif strmatch(sel_list(i), 'TB', 'exact')
        h_ax = handles.ax_tb; h_ln = [handles.ln_gs_tb handles.ln_tv_tb];
        h_tx = handles.tx_tb;
    elseif strmatch(sel_list(i), 'TT', 'exact')
        h_ax = handles.ax_tt; h_ln = [handles.ln_gs_tt handles.ln_tv_tt];
        h_tx = handles.tx_tt;
    elseif strmatch(sel_list(i), 'JAW', 'exact')
        h_ax = handles.ax_jaw; h_ln = [handles.ln_gs_jaw handles.ln_tv_jaw];
        h_tx = handles.tx_jaw;
    elseif strmatch(sel_list(i), 'VEL', 'exact')
        h_ax = handles.ax_vel; h_ln = [handles.ln_gs_vel handles.ln_tv_vel];
        h_tx = handles.tx_vel;
    elseif strmatch(sel_list(i), 'GLO', 'exact')
        h_ax = handles.ax_glo; h_ln = [handles.ln_gs_glo handles.ln_tv_glo];
        h_tx = handles.tx_glo;
    elseif strmatch(sel_list(i), 'F0', 'exact')
        h_ax = handles.ax_F0; h_ln = [handles.ln_gs_F0 handles.ln_tv_F0];
        h_tx = handles.tx_F0;
    elseif strmatch(sel_list(i), 'PI', 'exact')
        h_ax = handles.ax_pi; h_ln = [handles.ln_gs_pi handles.ln_tv_pi];
        h_tx = handles.tx_pi;
    elseif strmatch(sel_list(i), 'SPI', 'exact')
        h_ax = handles.ax_spi; h_ln = [handles.ln_gs_spi handles.ln_tv_spi];
        h_tx = handles.tx_spi;
    elseif strmatch(sel_list(i), 'TRt', 'exact')
        h_ax = handles.ax_tr; h_ln = [handles.ln_gs_tr handles.ln_tv_tr];
        h_tx = handles.tx_tr;
    elseif strmatch(sel_list(i), 'UL', 'exact')
        h_ax = handles.ax_asy_ul; h_ln = [handles.ln_asy_ulx handles.ln_asy_uly];
        h_tx = handles.tx_asy_ul;
    elseif strmatch(sel_list(i), 'LL', 'exact')
        h_ax = handles.ax_asy_ll; h_ln = [handles.ln_asy_llx handles.ln_asy_lly];
        h_tx = handles.tx_asy_ll;
    elseif strmatch(sel_list(i), 'JAWp', 'exact')
        h_ax = handles.ax_asy_jaw; h_ln = [handles.ln_asy_jawx handles.ln_asy_jawy];
        h_tx = handles.tx_asy_jaw;
    elseif strmatch(sel_list(i), 'TTp', 'exact')
        h_ax = handles.ax_asy_tt; h_ln = [handles.ln_asy_ttx handles.ln_asy_tty];
        h_tx = handles.tx_asy_tt;
    elseif strmatch(sel_list(i), 'TF', 'exact')
        h_ax = handles.ax_asy_tf; h_ln = [handles.ln_asy_tfx handles.ln_asy_tfy];
        h_tx = handles.tx_asy_tf;
    elseif strmatch(sel_list(i), 'TR', 'exact')
        h_ax = handles.ax_asy_tr; h_ln = [handles.ln_asy_trx handles.ln_asy_try];
        h_tx = handles.tx_asy_tr;
    elseif strmatch(sel_list(i), 'TD', 'exact')
        h_ax = handles.ax_asy_td; h_ln = [handles.ln_asy_tdx handles.ln_asy_tdy];
        h_tx = handles.tx_asy_td;
    elseif strmatch(sel_list(i), 'LX', 'exact')
        h_ax = handles.ax_a_lx; h_ln = handles.ln_a_lx;
        h_tx = handles.tx_a_lx;
    elseif strmatch(sel_list(i), 'JA', 'exact')
        h_ax = handles.ax_a_ja; h_ln = handles.ln_a_ja;
        h_tx = handles.tx_a_ja;
    elseif strmatch(sel_list(i), 'UY', 'exact')
        h_ax = handles.ax_a_uy; h_ln = handles.ln_a_uy;
        h_tx = handles.tx_a_uy;
    elseif strmatch(sel_list(i), 'LY', 'exact')
        h_ax = handles.ax_a_ly; h_ln = handles.ln_a_ly;
        h_tx = handles.tx_a_ly;
    elseif strmatch(sel_list(i), 'CL', 'exact')
        h_ax = handles.ax_a_cl; h_ln = handles.ln_a_cl;
        h_tx = handles.tx_a_cl;
    elseif strmatch(sel_list(i), 'CA', 'exact')
        h_ax = handles.ax_a_ca; h_ln = handles.ln_a_ca;
        h_tx = handles.tx_a_ca;
    elseif strmatch(sel_list(i), 'TL', 'exact')
        h_ax = handles.ax_a_tl; h_ln = handles.ln_a_tl;
        h_tx = handles.tx_a_tl;
    elseif strmatch(sel_list(i), 'TA', 'exact')
        h_ax = handles.ax_a_ta; h_ln = handles.ln_a_ta;
        h_tx = handles.tx_a_ta;
    elseif strmatch(sel_list(i), 'NA', 'exact')
        h_ax = handles.ax_a_na; h_ln = handles.ln_a_na;
        h_tx = handles.tx_a_na;
    elseif strmatch(sel_list(i), 'GW', 'exact')
        h_ax = handles.ax_a_gw; h_ln = handles.ln_a_gw;
        h_tx = handles.tx_a_gw;
    elseif strmatch(sel_list(i), 'Fmt', 'exact')
        h_ax = handles.ax_formants; h_ln = [handles.ln_F1 handles.ln_F2 handles.ln_F3 handles.ln_F4];
        h_tx = handles.tx_formants;
    end
    set(h_ax, 'visible', 'on', 'position', [x t-i*h w h])
    set(h_tx, 'visible', 'on', 'position', [x-.0365 t-(i-1)*h-.03 .02 .024])
    set(h_ln, 'visible', 'on')
end



    
% --- Executes on button press in pb_selup.
function pb_selup_Callback(hObject, eventdata, handles)
% hObject    handle to pb_selup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sel_list = get(handles.lb_seltraj, 'string');
idx_sel = get(handles.lb_seltraj, 'value');
if length(sel_list) > 1 & idx_sel > 1
    tmp = sel_list(idx_sel-1);
    sel_list(idx_sel-1) = sel_list(idx_sel);
    sel_list(idx_sel) = tmp;
    set(handles.lb_seltraj, 'string', sel_list)
    set(handles.lb_seltraj, 'value', idx_sel-1)
end

% --- Executes on button press in pb_seldown.
function pb_seldown_Callback(hObject, eventdata, handles)
% hObject    handle to pb_seldown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sel_list = get(handles.lb_seltraj, 'string');
idx_sel = get(handles.lb_seltraj, 'value');
if length(sel_list) > 1 & idx_sel < length(sel_list)
    tmp = sel_list(idx_sel+1);
    sel_list(idx_sel+1) = sel_list(idx_sel);
    sel_list(idx_sel) = tmp;
    set(handles.lb_seltraj, 'string', sel_list)
    set(handles.lb_seltraj, 'value', idx_sel+1)
end


% --- Executes on button press in pb_refresh.
function pb_refresh_Callback(hObject, eventdata, handles)
% hObject    handle to pb_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


state = get(handles.tada, 'userdata');

% delete all gestural boxes handles
delete(state.h_rt_selGest)
state.h_rt_selGest = [];
state.sel_ngests = [];
state.sel_iTVs = [];

fname = state.fname;

pname = state.pname;

if fname ~= 0 & (strcmpi(fname(1:2), 'TV') | strcmpi(fname(1:2), 'PH'))
    tmp = find(fname == '.');
    if strcmpi(fname(3:4), 'TV')
        utt_name = fname (5: tmp(end)-1);
    else
        utt_name = fname (3: tmp(end)-1);
    end
    
    if strcmpi(fname(tmp(end)+1), 'O') % for tado
        state.OSC_flg = 1;
        gui_on_off(handles, state.OSC_flg)
        set(handles.mn_saveOscSim, 'Enable', 'on')
    elseif strcmpi(fname(tmp(end)+1), 'G') % for tada
        state.OSC_flg = 0;
        gui_on_off(handles, state.OSC_flg)
        set(handles.mn_saveOscSim, 'Enable', 'off')        
    end

    state.TV_SCORE = [];
    state.utt_name = utt_name;
    state.fname = fname;
    state.pname = pname;
    set(handles.ed_uttname, 'String', utt_name)
    set(handles.pb_saveas, 'Enable', 'on')

    set(handles.cb_cos_ramp, 'value', 0)
    set(handles.cb_ramp_act, 'value', 0)
    set(handles.tb_gscore, 'value', 0)
    set(handles.tb_tv, 'value', 0)
    cd(state.pname)
    set(handles.tada, 'userdata', state);
    flg_pi = 0;
    clear_all_axis(handles, flg_pi)
    set(handles.tb_gscore, 'value', 1);
    tada('tb_gscore_Callback', handles.tb_gscore, [], handles)
end







% --- Executes on button press in tb_osclink.
function tb_osclink_Callback(hObject, eventdata, handles)
% hObject    handle to tb_osclink (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tb_osclink


if ~get(handles.tb_osclink, 'Value')
    axes(handles.ax_back)
    cla
    set(handles.ax_back, 'Visible', 'off')
    if ~isempty(findobj('Tag', 'osc_coupled'))
        delete(findobj('Tag', 'osc_coupled'))
    end
    return
end

state = get(handles.tada, 'UserData');
OSC = state.OSC;
TV_SCORE = state.TV_SCORE;
load t_params
coupled_TV = [];

% find coupled pairs of TV_SCORE.GEST and relative phase 
% i.e., generate coupled_TV
for i = [i_LA, i_TBCD, i_TTCD, i_VEL, i_GLO, i_F0]
    for j = 1:length(TV_SCORE(i).GEST)
        coupl_idx = find(~isnan(TV_SCORE(i).GEST(j).OSC_RELPHASE)==1);
        for k = coupl_idx
            for m = [i_LA, i_TBCD, i_TTCD, i_VEL, i_GLO, i_F0]
                for n = 1:length(TV_SCORE(m).GEST)
                    if strcmpi(TV_SCORE(m).GEST(n).OSC_ID, OSC(k).OSC_ID)
                       coupled_TV = [coupled_TV;[i j m n TV_SCORE(i).GEST(j).OSC_RELPHASE(k)]];
                    end
                end
            end
        end
    end
end

% delete redundant row
del = [];
sz = size(coupled_TV); 
for p = 1:sz(1)-1
    for q = p+1:sz(1)
        if coupled_TV(p,1:2) == coupled_TV(q,3:4) & coupled_TV(p,3:4) == coupled_TV(q,1:2)
            del = [del q];
        end
    end
end

coupled_TV(del,:) =[];

pos_audioall = get(handles.ax_audioall, 'Position');
pos_lips = get(handles.ax_lips, 'Position');
pos_tb = get(handles.ax_tb, 'Position');
pos_tt = get(handles.ax_tt, 'Position');
pos_vel = get(handles.ax_vel, 'Position');
pos_glo = get(handles.ax_glo, 'Position');
pos_f0 = get(handles.ax_F0, 'Position');
pos_pi = get(handles.ax_pi, 'Position');

n_frm = state.n_frm;

axes(handles.ax_back)
set(handles.ax_back, 'Visible', 'on')
set(gca, 'Color', 'none')

sz = size(coupled_TV);
ln = [];

for i = 1: sz(1)
    n1_TV = coupled_TV(i,1);
    n1_GEST = coupled_TV(i,2);
    
    n2_TV = coupled_TV(i,3);
    n2_GEST = coupled_TV(i,4);
    
    GEST1 = find(TV_SCORE(n1_TV).GEST(n1_GEST).PROM > 0);
    BEG1 = GEST1(1);
    END1 = GEST1(end);
    x1= (BEG1 + END1)/2;
    switch n1_TV
        case {i_PRO, i_LA}
            y1=pos_lips(2)+pos_lips(4)/4;
        case {i_TBCL, i_TBCD}
            y1=pos_tb(2)+pos_tb(4)/4;
        case {i_TTCL, i_TTCD, i_TTCR}
            y1=pos_tt(2)+pos_tt(4)/4; 
        case i_VEL
            y1=pos_vel(2)+pos_vel(4)/4;
        case i_GLO
            y1=pos_glo(2)+pos_glo(4)/4;
        case i_F0
            y1=pos_f0(2)+pos_f0(4)/4;
    end
    
    GEST2 = find(TV_SCORE(n2_TV).GEST(n2_GEST).PROM > 0);
    BEG2 = GEST2(1);
    END2 = GEST2(end);
    x2= (BEG2 + END2)/2;
    switch n2_TV
        case {i_PRO, i_LA}
            y2=pos_lips(2)+pos_lips(4)/4;
        case {i_TBCL, i_TBCD}
            y2=pos_tb(2)+pos_tb(4)/4;
        case {i_TTCL, i_TTCD, i_TTCR}
            y2=pos_tt(2)+pos_tt(4)/4; 
        case i_VEL
            y2=pos_vel(2)+pos_vel(4)/4;
        case i_GLO
            y2=pos_glo(2)+pos_glo(4)/4;
        case i_F0
            y2=pos_f0(2)+pos_f0(4)/4;
    end
    
    set(gca, 'Position', [pos_pi(1) 0 pos_pi(3) 1])
    set(handles.ax_back, 'XLim', get(handles.ax_lips, 'XLim'))
    set(handles.ax_back, 'YLim', [0 1])
    set(handles.ax_back, 'XTick', [])
    set(handles.ax_back, 'YTick', [])
    
    if mod(coupled_TV(i,end), 360) == 0 
        clr = [0 .9 .4]; %green
    elseif coupled_TV(i,end) == 180 | coupled_TV(i,end) == -180
        clr = [1 0 0];
    else
        clr = [.8 .8 0];
    end
    
    text1 = TV_SCORE(n1_TV).GEST(n1_GEST).OSC_ID;
    tmp1 = findstr(text1, '_');
    text1(tmp1) = ' ';
    h_text1 = text(x1, y1, text1,...
        'HorizontalAlignment', 'Center', 'FontSize', 8.5, 'Color', [.2 .7 1], 'tag', ['tx_osc1' num2str(i)]);
    text2 = TV_SCORE(n2_TV).GEST(n2_GEST).OSC_ID;
    tmp2 = findstr(text2, '_');
    text2(tmp2) = ' ';
    h_text2 = text(x2, y2, text2,...
        'HorizontalAlignment', 'Center', 'FontSize', 8.5, 'Color', [.2 .7 1], 'tag', ['tx_osc2' num2str(i)]);
    
    % if VEL, GLo share clo, crt, nar or rel oscillator
    if ((n1_TV == i_VEL | n1_TV == i_GLO) & ...      
            regexpfind(TV_SCORE(n1_TV).GEST(n1_GEST).OSC_ID, '\w*_clo|\w*_crt|\w*_nar|\w*_rel')) | ...
       ((n2_TV == i_VEL | n2_TV == i_GLO) & ...
            regexpfind(TV_SCORE(n2_TV).GEST(n2_GEST).OSC_ID, '\w*_clo|\w*_crt|\w*_nar|\w*_rel'))

    % if TB share oscillator with TT (CD/CL)
    elseif n1_TV == i_TBCD & regexpfind({TV_SCORE(i_TTCD).GEST.OSC_ID}, TV_SCORE(n1_TV).GEST(n1_GEST).OSC_ID)
    elseif n2_TV == i_TBCD & regexpfind({TV_SCORE(i_TTCD).GEST.OSC_ID}, TV_SCORE(n2_TV).GEST(n2_GEST).OSC_ID)
    elseif n1_TV == i_TBCL & regexpfind({TV_SCORE(i_TTCL).GEST.OSC_ID}, TV_SCORE(n1_TV).GEST(n1_GEST).OSC_ID)
    elseif n2_TV == i_TBCL & regexpfind({TV_SCORE(i_TTCL).GEST.OSC_ID}, TV_SCORE(n2_TV).GEST(n2_GEST).OSC_ID)        

    % if TB share oscillator with Lips (CD/CL) 
    elseif n1_TV == i_TBCD & regexpfind({TV_SCORE(i_LA).GEST.OSC_ID}, TV_SCORE(n1_TV).GEST(n1_GEST).OSC_ID)
    elseif n2_TV == i_TBCD & regexpfind({TV_SCORE(i_LA).GEST.OSC_ID}, TV_SCORE(n2_TV).GEST(n2_GEST).OSC_ID)
    elseif n1_TV == i_TBCL & regexpfind({TV_SCORE(i_PRO).GEST.OSC_ID}, TV_SCORE(n1_TV).GEST(n1_GEST).OSC_ID)
    elseif n2_TV == i_TBCL & regexpfind({TV_SCORE(i_PRO).GEST.OSC_ID}, TV_SCORE(n2_TV).GEST(n2_GEST).OSC_ID)        

    else

%         % to avoid graphical overlap of coupling lines
%         a = (y2-y1)/(x2-x1);
%         x1 = x1 + cos(atan(a))*.01; x2 = x2 + cos(atan(a))*.01;
%         y1 = y1 + sin(atan(a))*.01; y2 = y2 + sin(atan(a))*.01;
        
        h_line = line([x1 x2],[y1 y2], 'LineWidth', 1.5, 'Color', clr, 'tag', ['ln_osc' num2str(i)]);
        set(h_line, 'UserData', coupled_TV(i,:))
        set(h_line, 'ButtonDownFcn', 'tada(''line_ButtonDownFcn'',gcbo,[],guidata(gcbo))')
    end
end


function line_ButtonDownFcn(hObject, eventdata, handles)
load t_params
state = get(handles.tada, 'Userdata');
h_osc_coupled = guihandles(osc_coupled);

coupled_TV = get(hObject, 'UserData');

n_TV1 = coupled_TV(1);
n_GEST1 = coupled_TV(2);

n_TV2 = coupled_TV(3);
n_GEST2 = coupled_TV(4);

OSC = state.OSC;
TV_SCORE = state.TV_SCORE;

sz_OSC = length(OSC);
for i = 1:sz_OSC
    if strcmpi(TV_SCORE(n_TV1).GEST(n_GEST1).OSC_ID, OSC(i).OSC_ID)
        set(h_osc_coupled.tx_id1, 'String', OSC(i).OSC_ID)
        n_RELPHASE2 = i; n_OSC1 = i;
        set(h_osc_coupled.tx_beg1, 'String', OSC(i).OSC_BEG)
        set(h_osc_coupled.tx_end1, 'String', OSC(i).OSC_END)
    end
    
    if strcmpi(TV_SCORE(n_TV2).GEST(n_GEST2).OSC_ID, OSC(i).OSC_ID)
        set(h_osc_coupled.tx_id2, 'String', OSC(i).OSC_ID)
        n_RELPHASE1 = i; n_OSC2 = i;
        set(h_osc_coupled.tx_beg2, 'String', OSC(i).OSC_BEG)
        set(h_osc_coupled.tx_end2, 'String', OSC(i).OSC_END)        
    end
end

set(h_osc_coupled.tx_relphase1, 'String', OSC(n_OSC1).OSC_RELPHASE(n_RELPHASE1))
set(h_osc_coupled.tx_relphase2, 'String', OSC(n_OSC2).OSC_RELPHASE(n_RELPHASE2))
set(h_osc_coupled.tx_finrelphase1, 'String', OSC(n_OSC1).OSC_FINRELPHASE(n_RELPHASE1))
set(h_osc_coupled.tx_finrelphase2, 'String', OSC(n_OSC2).OSC_FINRELPHASE(n_RELPHASE2))
set(h_osc_coupled.tx_omega1, 'String', OSC(n_OSC1).OSC_OMEGA)
set(h_osc_coupled.tx_omega2, 'String', OSC(n_OSC2).OSC_OMEGA)
set(h_osc_coupled.tx_escap1, 'String', OSC(n_OSC1).OSC_ESCAP)
set(h_osc_coupled.tx_escap2, 'String', OSC(n_OSC2).OSC_ESCAP)
set(h_osc_coupled.tx_ampinit1, 'String', OSC(n_OSC1).OSC_AMPINIT)
set(h_osc_coupled.tx_ampinit2, 'String', OSC(n_OSC2).OSC_AMPINIT)
set(h_osc_coupled.tx_phaseinit1, 'String', OSC(n_OSC1).OSC_PHASEINIT)
set(h_osc_coupled.tx_phaseinit2, 'String', OSC(n_OSC2).OSC_PHASEINIT)
set(h_osc_coupled.tx_couplstrnth1, 'String', OSC(n_OSC1).OSC_COUPLSTRNTH(n_RELPHASE1))
set(h_osc_coupled.tx_couplstrnth2, 'String', OSC(n_OSC2).OSC_COUPLSTRNTH(n_RELPHASE2))


function clear_all_axis(handles, flg_pi)
% clear all axis
set(handles.ln_audioall, 'xdata', 0, 'ydata', 0)
set(handles.ln_audiosel, 'xdata', 0, 'ydata', 0)
set(handles.ln_gs_glo, 'xdata', 0, 'ydata', 0)
set(handles.ln_gs_vel, 'xdata', 0, 'ydata', 0)
set(handles.ln_gs_tt, 'xdata', 0, 'ydata', 0)
set(handles.ln_gs_tb, 'xdata', 0, 'ydata', 0)
set(handles.ln_gs_lips, 'xdata', 0, 'ydata', 0)
set(handles.ln_gs_jaw, 'xdata', 0, 'ydata', 0)
set(handles.ln_gs_F0, 'xdata', 0, 'ydata', 0)
set(handles.ln_gs_pi, 'xdata', 0, 'ydata', 0)
set(handles.ln_gs_spi, 'xdata', 0, 'ydata', 0)
set(handles.ln_gs_tr, 'xdata', 0, 'ydata', 0)

if ~flg_pi
    set(handles.ln_tv_pi, 'xdata', 0, 'ydata', 0)
end
set(handles.ln_tv_spi, 'xdata', 0, 'ydata', 0)
set(handles.ln_tv_tr, 'xdata', 0, 'ydata', 0)
set(handles.ln_tv_lips, 'xdata', 0, 'ydata', 0)
set(handles.ln_tv_tb, 'xdata', 0, 'ydata', 0)
set(handles.ln_tv_tt, 'xdata', 0, 'ydata', 0)
set(handles.ln_tv_jaw, 'xdata', 0, 'ydata', 0)
set(handles.ln_tv_vel, 'xdata', 0, 'ydata', 0)
set(handles.ln_tv_glo, 'xdata', 0, 'ydata', 0)
set(handles.ln_tv_F0, 'xdata', 0, 'ydata', 0)

set(handles.ln_asy_ulx, 'xdata', 0, 'ydata', 0)
set(handles.ln_asy_llx, 'xdata', 0, 'ydata', 0)
set(handles.ln_asy_jawx, 'xdata', 0, 'ydata', 0)
set(handles.ln_asy_ttx, 'xdata', 0, 'ydata', 0)
set(handles.ln_asy_tfx, 'xdata', 0, 'ydata', 0)
set(handles.ln_asy_trx, 'xdata', 0, 'ydata', 0)
set(handles.ln_asy_tdx, 'xdata', 0, 'ydata', 0)

set(handles.ln_asy_uly, 'xdata', 0, 'ydata', 0)
set(handles.ln_asy_lly, 'xdata', 0, 'ydata', 0)
set(handles.ln_asy_jawy, 'xdata', 0, 'ydata', 0)
set(handles.ln_asy_tty, 'xdata', 0, 'ydata', 0)
set(handles.ln_asy_tfy, 'xdata', 0, 'ydata', 0)
set(handles.ln_asy_try, 'xdata', 0, 'ydata', 0)
set(handles.ln_asy_tdy, 'xdata', 0, 'ydata', 0)

set(handles.ln_a_lx, 'xdata', 0, 'ydata', 0)
set(handles.ln_a_ja, 'xdata', 0, 'ydata', 0)
set(handles.ln_a_uy, 'xdata', 0, 'ydata', 0)
set(handles.ln_a_ly, 'xdata', 0, 'ydata', 0)
set(handles.ln_a_cl, 'xdata', 0, 'ydata', 0)
set(handles.ln_a_ca, 'xdata', 0, 'ydata', 0)
set(handles.ln_a_tl, 'xdata', 0, 'ydata', 0)
set(handles.ln_a_ta, 'xdata', 0, 'ydata', 0)
set(handles.ln_a_na, 'xdata', 0, 'ydata', 0)
set(handles.ln_a_gw, 'xdata', 0, 'ydata', 0)

set(handles.ln_F4, 'xdata', 0, 'ydata', 0)
set(handles.ln_F3, 'xdata', 0, 'ydata', 0)
set(handles.ln_F2, 'xdata', 0, 'ydata', 0)
set(handles.ln_F1, 'xdata', 0, 'ydata', 0)

set(handles.ln_pels_ul, 'xdata', 50, 'ydata', 40)
set(handles.ln_pels_ll, 'xdata', 50, 'ydata', 40)
set(handles.ln_pels_jaw, 'xdata', 50, 'ydata', 40)
set(handles.ln_pels_tt, 'xdata', 50, 'ydata', 40)
set(handles.ln_pels_tf, 'xdata', 50, 'ydata', 40)
set(handles.ln_pels_td, 'xdata', 50, 'ydata', 40)
set(handles.ln_pels_tr, 'xdata', 50, 'ydata', 40)

set(handles.cln_pels_ul, 'xdata', 50, 'ydata', 40)
set(handles.cln_pels_ll, 'xdata', 50, 'ydata', 40)
set(handles.cln_pels_jaw, 'xdata', 50, 'ydata', 40)
set(handles.cln_pels_tt, 'xdata', 50, 'ydata', 40)
set(handles.cln_pels_tf, 'xdata', 50, 'ydata', 40)
set(handles.cln_pels_td, 'xdata', 50, 'ydata', 40)
set(handles.cln_pels_tr, 'xdata', 50, 'ydata', 40)

set(handles.ln_intpl, 'xdata', 50, 'ydata', 40)
set(handles.ln_pal, 'xdata', 50, 'ydata', 40)
set(handles.ln_upperoutline, 'xdata', 0, 'ydata', 0)
set(handles.ln_bottomoutline, 'xdata', 0, 'ydata', 0)
set(handles.ln_velumopen, 'xdata', 0, 'ydata', 0)
set(handles.ln_area, 'xdata', 0, 'ydata', 0)
set(gcf,'CurrentAxes',handles.ax_back)
cla
set(handles.ax_back, 'Visible', 'off')




function gui_on_off(handles, OSC_flg)
switch OSC_flg
    case 1
        set(handles.cb_cos_ramp, 'Enable', 'off')
        set(handles.cb_ramp_act, 'Enable', 'off')
        set(handles.ed_speech_rate, 'Enable', 'on')
        set(handles.ed_nscale, 'Enable', 'on')
        set(handles.tb_osclink, 'Enable', 'on')
        set(handles.tb_osclink, 'value', 0)
        set(handles.Apply_pi2gest, 'Enable', 'off')
        set(handles.cm_AddGest, 'Visible', 'off')
        set(handles.cm_DelGest, 'Visible', 'off')
    case 0
        set(handles.cb_cos_ramp, 'Enable', 'on')
        set(handles.cb_ramp_act, 'Enable', 'on')
        set(handles.ed_speech_rate, 'Enable', 'off')
        set(handles.ed_nscale, 'Enable', 'off')
        set(handles.tb_osclink, 'Enable', 'off')
        set(handles.tb_osclink, 'value', 0)
        set(handles.Apply_pi2gest, 'Enable', 'on')
        set(handles.cm_AddGest, 'Visible', 'on')
        set(handles.cm_DelGest, 'Visible', 'on')

end


% --- Executes on button press in pb_opensig.
function pb_opensig_Callback(hObject, eventdata, handles)
% hObject    handle to pb_opensig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

state = get(handles.tada, 'userdata');
n_frm = state.n_frm;
% display an assosicated acoustic file if any

if ispc
    [fn1,pname] = uigetfile( {'*.wav;*.pcm', 'wav, pcm Files (*.wav, *.pcm)'; '*.*', 'All Files (*.*)'}, 'wav, pcm files');
else   % due to the incompatibility btw Mac and uigetfile
    [fn1,pname] = uigetfile( {'*.wav';'*.pcm'}, 'wav, pcm files');
end

if isempty(fn1)
    return
end

if strcmpi(fn1(end-2:end), 'wav') 
    [sig srate] = audioread(fn1);
    sig = double(sig);
    sig = sig/max(abs(sig));
    sig = sig';
    set(handles.ln_audioall, 'xdata', 1/length(sig)*n_frm:1/length(sig)*n_frm:n_frm, 'ydata', sig);
    set(handles.ln_audiosel, 'xdata', 1/length(sig)*n_frm:1/length(sig)*n_frm:n_frm, 'ydata', sig);
elseif strcmpi(fn1(end-2:end), 'pcm')
    [sig srate] = PCMread(fn2);
    sig = double(sig);
    sig = sig/max(abs(sig));

    set(handles.ln_audioall, 'xdata', 1/length(sig)*n_frm:1/length(sig)*n_frm:n_frm, 'ydata', sig);
    set(handles.ln_audiosel, 'xdata', 1/length(sig)*n_frm:1/length(sig)*n_frm:n_frm, 'ydata', sig);
else
    return
end

set([handles.ax_audioall handles.ax_audiosel], 'XLim', [0 n_frm], 'YLim', [-1 1])
set(handles.pc_sel, 'xdata', [0 0 n_frm n_frm]);
set(handles.ax_audiosel, 'XLim', [0 n_frm], 'YLim', [-1 1])

state.sig = sig;
state.srate = srate;
set(handles.tada, 'userdata', state)



function ed_init_kill_Callback(hObject, eventdata, handles)
% hObject    handle to ed_init_kill (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_init_kill as text
%        str2double(get(hObject,'String')) returns contents of ed_init_kill as a double


% --- Executes during object creation, after setting all properties.
function ed_init_kill_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_init_kill (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




% --------------------------------------------------------------------
function mn_LowGraphic_Callback(hObject, eventdata, handles)
% hObject    handle to mn_LowGraphic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmpi(get(hObject, 'checked'), 'on')
    set(hObject, 'checked', 'off')
else
    set(hObject, 'checked', 'on')
end


% --- Executes when user attempts to close tada.
function tada_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to tada (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% write tada.ini
state = get(handles.tada, 'userdata');
tadadir = which ('tada');
tadadir = tadadir(1:end-6);
fid_w = fopen([tadadir 'tada.ini'], 'w'); % open data file

fprintf(fid_w, '%s', ['[LowGraphic] ']);
checked = get(handles.mn_LowGraphic, 'checked');
if strmatch(checked, 'on', 'exact'), flg = 1; else flg = 0; end
fprintf(fid_w, '%d\n', flg);

fprintf(fid_w, '%s', ['[SetOscSimParam] ']);
fprintf(fid_w, '%d %d %d %3.2f %d %d\n', state.oscSimParams);

fprintf(fid_w, '%s', ['[SetOscSimNoise] ']);
fprintf(fid_w, '%d %d %d %d\n', state.oscSimNoise);

fprintf(fid_w, '%s', ['[ProFreq2Act] ']);
checked = get(handles.mn_proportionalFreq, 'checked');
if strmatch(checked, 'on', 'exact'), flg = 1; else flg = 0; end
fprintf(fid_w, '%d\n', flg);

fprintf(fid_w, '%s', ['[Apply2OtherTVs] ']);
checked = get(handles.mn_apply2otherTVs, 'checked');
if strmatch(checked, 'on', 'exact'), flg = 1; else flg = 0; end
fprintf(fid_w, '%d\n', flg);

fprintf(fid_w, '%s', ['[GenHLsynInput] ']);
checked = get(handles.mn_genHL, 'checked');
if strmatch(checked, 'on', 'exact'), flg = 1; else flg = 0; end
fprintf(fid_w, '%d\n', flg);

fprintf(fid_w, '%s', ['[PlotRelPhase] ']);
checked = get(handles.mn_plotRelPhase, 'checked');
if strmatch(checked, 'on', 'exact'), flg = 1; else flg = 0; end
fprintf(fid_w, '%d\n', flg);

fprintf(fid_w, '%s', ['[PlotCycleTicks] ']);
checked = get(handles.mn_plotCycleTicks, 'checked');
if strmatch(checked, 'on', 'exact'), flg = 1; else flg = 0; end
fprintf(fid_w, '%d', flg);

fclose(fid_w);








% Hint: delete(hObject) closes the figure
delete(hObject);

tadaPath = which('tada');
tadaPath = tadaPath(1:end-7);

warning off

if isempty(findobj('tag', 'tada'))
    if ispc
        rmpath([tadaPath '\casy']) ;  % remove this path in order to avoid the functions
        % in this folder recalled by other commands.
    else
        rmpath([tadaPath '/casy']) ;  % remove this path in order to avoid the functions
        % in this folder recalled by other commands.
    end
end
warning on










% --------------------------------------------------------------------
function i_ARTIC = get_i_ARTIC(ARTICname)
load t_params

switch ARTICname
    case 'LX'
        i_ARTIC = i_LX;
    case 'JA' 
        i_ARTIC = i_JA;
    case 'UH'
        i_ARTIC = i_UY;
    case 'LH'
        i_ARTIC = i_LY;
    case 'CL'
        i_ARTIC = i_CL;
    case 'CA' 
        i_ARTIC = i_CA;
    case 'TL'
        i_ARTIC = i_TL;
    case 'TA'
        i_ARTIC = i_TA;
    case 'NA'
        i_ARTIC = i_NA;
    case 'GW'
        i_ARTIC = i_GW;
    case 'F0a'
        i_ARTIC = i_F0a;
    case 'PIa'
        i_ARTIC = i_PIa;
    case 'SPIa'
        i_ARTIC = i_SPIa;
    case 'HX'
        i_ARTIC = i_HX;
end


% --------------------------------------------------------------------
function mn_oscSimParams_Callback(hObject, eventdata, handles)
% hObject    handle to mn_mn_oscSimParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

state = get(handles.tada, 'userdata');

prompt = {'Sim parameters (SimTime, SettleTime, RelTol, MaxStep, InitStep, Refine)'};
dlg_title = 'Set SIM params';
num_lines = 1;
str=num2str(state.oscSimParams);
str(findstr(str, '  '))=[];
dfltAns = {str};
InputStr = inputdlg(prompt,dlg_title,num_lines,dfltAns);
if isempty(InputStr)
    return
else
    InputStr = InputStr{1};
end
state.oscSimParams = str2num(InputStr);
set(handles.tada, 'userdata', state);




% --------------------------------------------------------------------
function mn_oscSimNoise_Callback(hObject, eventdata, handles)
% hObject    handle to mn_oscSimNoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%nz_task, nz_comp, nz_freq, sim_type (see hybrid_osc.m) 

state = get(handles.tada, 'userdata');

prompt = {'OscSim noise parameters (nz_task, nz_comp, nz_freq, sim_type)'};
dlg_title = 'Set SIM params';
num_lines = 1;
str=num2str(state.oscSimNoise);
str(findstr(str, '  '))=[];
dfltAns = {str};
InputStr = inputdlg(prompt,dlg_title,num_lines,dfltAns);
if isempty(InputStr)
    return
else
    InputStr = InputStr{1};
end
state.oscSimNoise = str2num(InputStr);
set(handles.tada, 'userdata', state);


% --------------------------------------------------------------------
function mn_saveOscSim_Callback(hObject, eventdata, handles)
% hObject    handle to mn_saveOscSim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

state = get(handles.tada, 'userdata');
OSC = state.OSC;
eval(['save OSC_' state.utt_name ' OSC'])




% --------------------------------------------------------------------
function cm_AddDelGest_Callback(hObject, eventdata, handles)
% hObject    handle to cm_AddDelGest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

load t_params
state = get(handles.tada, 'userdata');
TV_SCORE = state.TV_SCORE;

len_sel_ngests = length(state.sel_ngests);
if len_sel_ngests < 1
    set(handles.cm_DelGest, 'visible', 'off')
elseif len_sel_ngests >=1
    set(handles.cm_DelGest, 'visible', 'on')
end



% --------------------------------------------------------------------
function cm_DelGest_Callback(hObject, eventdata, handles)
% hObject    handle to cm_DelGest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
state = get(handles.tada, 'userdata');
TV_SCORE = state.TV_SCORE;

len_sel_ngests = length(state.sel_ngests);
% if len_sel_ngests == 0
%     if length(TV_SCORE(state.i_TV).GEST) == 1
%         TV_SCORE(state.i_TV).GEST(1).BEG = 0;
%         TV_SCORE(state.i_TV).GEST(1).END = 0;
%     else
%         TV_SCORE(state.i_TV).GEST(state.ngest) = [];
%     end
% else
if len_sel_ngests >= 1
    [state.sel_ngests idx] = sort(state.sel_ngests, 'descend');
    state.sel_iTVs = state.sel_iTVs(idx);
    for k=1:len_sel_ngests      % must solve
        if length(TV_SCORE(state.sel_iTVs(k)).GEST) == 1
            TV_SCORE(state.sel_iTVs(k)).GEST(1).BEG = 0;
            TV_SCORE(state.sel_iTVs(k)).GEST(1).END = 0;
        else
            TV_SCORE(state.sel_iTVs(k)).GEST(state.sel_ngests(k)) = [];
        end
    end
    delete(state.h_rt_selGest)
    state.h_rt_selGest = [];
    state.sel_ngests = [];
    state.sel_iTVs = [];
end

state.TV_SCORE = TV_SCORE;
set(handles.tada, 'userdata', state);
set(handles.tb_gscore, 'value', 1)
set(handles.tb_tv, 'value', 0)
tada('tb_gscore_Callback', handles.tb_gscore, [], handles)




% --------------------------------------------------------------------
function cm_AddGest_Callback(hObject, eventdata, handles)
% hObject    handle to cm_AddGest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

load t_params
state = get(handles.tada, 'userdata');
TV_SCORE = state.TV_SCORE;

%temporarily block multiple PI gestures
if state.i_TV == i_PI & TV_SCORE(i_PI).GEST(end).BEG~=0 & TV_SCORE(i_PI).GEST(end).END~=0
    errordlg('Currently, muliple PI gestures are not allowed')
    return
end

n_frm = state.n_frm;

prompt = {'Gestural parameters (TV,0,Dur,0,Targ,Stif,Damp,Ws,Blend)'};
dlg_title = 'Add a gesture';
num_lines = 1;

begfrm = ceil(state.clicked_cur_x) - 10;
endfrm = ceil(state.clicked_cur_x) + 10;
if begfrm < 0
    begfrm = 0;
end

if endfrm > n_frm
    endfrm = n_frm;
end

switch state.i_TV
    case i_LA
        dfltAns = {['LA 0 ' num2str(round(begfrm/2)) ' ' num2str(round(endfrm/2)) ' 0 -2.5 6.4 1 JA=32,UH=5,LH=5 100 0.01']};
    case i_PRO
        dfltAns = {['PRO 0 ' num2str(round(begfrm/2)) ' ' num2str(round(endfrm/2)) ' 0 12 4 1 LX=5 100 0.01']};
    case i_TBCD
        dfltAns = {['TBCD 0 ' num2str(round(begfrm/2)) ' ' num2str(round(endfrm/2)) ' 0 15 2.2222 1 JA=1,CL=1,CA=1 0.01 100']};
    case i_TBCL
        dfltAns = {['TBCL 0 ' num2str(round(begfrm/2)) ' ' num2str(round(endfrm/2)) ' 0 170.6 2.9412 1 JA=1,CL=1,CA=1 1 1']};
    case i_TTCD
        dfltAns = {['TTCD 0 ' num2str(round(begfrm/2)) ' ' num2str(round(endfrm/2)) ' 0 3.5 6.4 1 JA=32,CL=32,CA=32,TL=1,TA=1 100 0.01']};
    case i_TTCL
        dfltAns = {['TTCL 0 ' num2str(round(begfrm/2)) ' ' num2str(round(endfrm/2)) ' 0 56 6.4 1 JA=32,CL=32,CA=32,TL=1,TA=1 1 1']};
    case i_JAW
        dfltAns = {['JAW 0 ' num2str(round(begfrm/2)) ' ' num2str(round(endfrm/2)) ' 0 10 6.4 1 JA=32 1 1']};
    case i_VEL
        dfltAns = {['VEL 0 ' num2str(round(begfrm/2)) ' ' num2str(round(endfrm/2)) ' 0 0.2 8 1 NA=1 0 0']};
    case i_GLO
        dfltAns = {['GLO 0 ' num2str(round(begfrm/2)) ' ' num2str(round(endfrm/2)) ' 0 0.6 10 1 GW=1 1 1']};
    case i_F0
        dfltAns = {['F0 0 ' num2str(round(begfrm/2)) ' ' num2str(round(endfrm/2)) ' 0 150 10 1 F0a=1 1 1']};
    case i_PI
        dfltAns = {['PI 0 ' num2str(round(begfrm/2)) ' ' num2str(round(endfrm/2)) ' 0 0.7 4 1 PIa=1 1 1']};
    case i_SPI                                                              
        dfltAns = {['SPI 0 ' num2str(round(begfrm/2)) ' ' num2str(round(endfrm/2)) ' 0 0.6 10 1 SPIa=1 1 1']};
    case i_TR
        dfltAns = {['TR 0 ' num2str(round(begfrm/2)) ' ' num2str(round(endfrm/2)) ' 0 0.6 10 1 HX=1 1 1']};
end

InputStr = inputdlg(prompt,dlg_title,num_lines,dfltAns);
if isempty(InputStr)
    return
else
    InputStr = InputStr{1};
end
x = findstr(InputStr, ' ');
eval(['i_TV = i_' InputStr(1:x(1)-1) ';']);

ngest = length(TV_SCORE(i_TV).GEST);
ngest = ngest +1;

switch i_TV
    case {i_TBCL, i_TTCL, i_TTCR}
        rescale = deg_per_rad;
    case {i_LA, i_PRO, i_TBCD, i_TTCD, i_JAW}
        rescale = mm_per_dec;
    case {i_VEL, i_GLO, i_F0 i_PI i_SPI i_TR}
        rescale = 1;
end

TV_SCORE(i_TV).GEST(ngest)=...
struct(...
        'BEG', [0],...
        'END', [0],...
        'PROM', zeros(1,n_frm),...
        'x', struct('VALUE', [0], 'ALPHA', [0], 'BETA', [0], 'PROM_BLEND', zeros(1,n_frm), 'PROMSUM_BLEND', zeros(1,n_frm)),...
        'k', struct('VALUE', [0], 'ALPHA', [0], 'BETA', [0], 'PROM_BLEND', zeros(1,n_frm), 'PROMSUM_BLEND', zeros(1,n_frm)),...
        'd', struct('VALUE', [0], 'ALPHA', [0], 'BETA', [0], 'PROM_BLEND', zeros(1,n_frm), 'PROMSUM_BLEND', zeros(1,n_frm)),...
        'w', struct('VALUE', zeros(1,nARTIC), 'ALPHA', [0], 'BETA', [0], 'PROM_BLEND', zeros(1,n_frm), 'PROMSUM_BLEND', zeros(1,n_frm)),...
        'PROM_BLEND_SYN', zeros(1,n_frm),...
        'PROMSUM_BLEND_SYN', zeros(1,n_frm),...
        'OSCID', '');

TV_SCORE(i_TV).GEST(ngest).BEG = str2num(InputStr(x(2)+1:x(3)-1));
TV_SCORE(i_TV).GEST(ngest).END = str2num(InputStr(x(3)+1:x(4)-1));
TV_SCORE(i_TV).GEST(ngest).x.VALUE = str2num(InputStr(x(5)+1:x(6)-1))/rescale;
TV_SCORE(i_TV).GEST(ngest).k.VALUE = (str2num(InputStr(x(6)+1:x(7)-1))*(2*pi))^2;
TV_SCORE(i_TV).GEST(ngest).d.VALUE = str2num(InputStr(x(7)+1:x(8)-1))*(2*sqrt(TV_SCORE(i_TV).GEST(ngest).k.VALUE));
TV_SCORE(i_TV).GEST(ngest).x.ALPHA = str2num(InputStr(x(9)+1:x(10)-1));
TV_SCORE(i_TV).GEST(ngest).x.BETA = str2num(InputStr(x(10)+1:end));
TV_SCORE(i_TV).GEST(ngest).k.ALPHA = str2num(InputStr(x(9)+1:x(10)-1));
TV_SCORE(i_TV).GEST(ngest).k.BETA = str2num(InputStr(x(10)+1:end));
TV_SCORE(i_TV).GEST(ngest).d.ALPHA = str2num(InputStr(x(9)+1:x(10)-1));
TV_SCORE(i_TV).GEST(ngest).d.BETA = str2num(InputStr(x(10)+1:end));
TV_SCORE(i_TV).GEST(ngest).w.ALPHA = str2num(InputStr(x(9)+1:x(10)-1));
TV_SCORE(i_TV).GEST(ngest).w.BETA = str2num(InputStr(x(10)+1:end));

w_str = InputStr(x(8)+1:x(9)-1);
w_str = [',' w_str ','];
x = findstr(w_str, '=');
y = findstr(w_str, ',');

w = zeros(1,nTV);

for i = 1: length(x)
    idx = get_i_ARTIC(w_str(y(i)+1:x(i)-1));
    w(idx) = str2num(w_str(x(i)+1: y(i+1)-1));
end

TV_SCORE(i_TV).GEST(ngest).w.VALUE = w;

state.TV_SCORE = TV_SCORE;

set(handles.tada, 'userdata', state)
set(handles.tb_gscore, 'value', 1)
set(handles.tb_tv, 'value', 0)
tada('tb_gscore_Callback', handles.tb_gscore, [], handles)



function clickGest(handles, h_ax_selOrgan, h_tx_selOrgan, h_tx_unselOrgan)
selectionType = get(gcbf, 'selectionType');
state = get(gcbf, 'userdata');

switch selectionType
    case 'normal' % left click
        [i_TV ngest] = sel_gest(handles, h_tx_selOrgan, h_tx_unselOrgan);

        if ~isempty(state.h_rt_selGest) & ~isempty(ngest)...
                & ~isempty(find(ngest ==state.sel_ngests(find(state.sel_iTVs == i_TV))))%when click on one of _selected_ gestures
            state.MOVGESTBTN = 1;  % button down for moving one of selected gestures
            cp_axes = get(h_ax_selOrgan, 'CurrentPoint');
            state.clicked_cur_x = cp_axes(2,1);
        else    %when click to see gestural parameters
            state.i_TV = i_TV;
            state.ngest = ngest;
        end
        set(handles.tada, 'userdata', state);
    case 'alt' % right click

        [i_TV ngest] = sel_gest(handles, h_tx_selOrgan, h_tx_unselOrgan);

        state.i_TV = i_TV;
        cp_axes = get(h_ax_selOrgan, 'CurrentPoint');
        state.clicked_cur_x = cp_axes(2,1);
        set(handles.tada, 'userdata', state);
    case 'open' % double click

        delete(state.h_rt_selGest)
        state.h_rt_selGest = [];
        state.sel_ngests = [];
        state.sel_iTVs = [];
        set(handles.tada, 'userdata', state);
    case 'extend' % shift click
        if state.OSC_flg | get(handles.tb_tv, 'value'), return, end        
        sel_gest(handles, h_tx_selOrgan, h_tx_unselOrgan);
        selMovGests(handles)
end





% --------------------------------------------------------------------
function selMovGests(handles)
% handles    structure with handles and user data (see GUIDATA)
state = get(handles.tada, 'userdata');
if ~isempty(state.ngest)        % when click on a gesture
    load t_params
    TV_SCORE = state.TV_SCORE;

    h_axes = selAxes(state.i_TV, handles);

    unselG = [];
    for k = 1:length(state.sel_ngests)
        if find(state.sel_ngests(k) == state.ngest) &...
                find(state.sel_iTVs(k) == state.i_TV);
            unselG = k;
            break
        end

    end

    if ~isempty(unselG)
        delete(state.h_rt_selGest(k))
        state.h_rt_selGest(k) = [];
        state.sel_ngests(k) = [];
        state.sel_iTVs(k) = [];
    else
        axes(h_axes)
        h_rt_selGest = rectangle('Position',[TV_SCORE(state.i_TV).GEST(state.ngest).BEG*2, 0,...
            TV_SCORE(state.i_TV).GEST(state.ngest).END*2-TV_SCORE(state.i_TV).GEST(state.ngest).BEG*2,1],...
            'edgecolor', 'c', 'linewidth', 3,...
            'ButtonDownFcn', '');
        set(h_rt_selGest, 'ButtonDownFcn', 'tada(''rt_movGest_ButtonDownFcn'',gcbo,[],guidata(gcbo))')

        state.h_rt_selGest = [state.h_rt_selGest h_rt_selGest];
        state.sel_ngests = [state.sel_ngests state.ngest];
        state.sel_iTVs = [state.sel_iTVs state.i_TV];
        
        % added by HN to avoid ax_TVs from disappearing
        axes(handles.ax_line)

    end
    set(handles.tada, 'userdata', state);
end



function h_axes = selAxes(i_TV, handles)
    load t_params
    switch i_TV
        case {i_LA, i_PRO}
            h_axes = handles.ax_lips;
        case {i_TBCD, i_TBCL}
            h_axes = handles.ax_tb;
        case {i_TTCD, i_TTCL, i_TTCR}
            h_axes = handles.ax_tt;
        case {i_JAW}
            h_axes = handles.ax_jaw;
        case {i_VEL}
            h_axes = handles.ax_vel;
        case {i_GLO}
            h_axes = handles.ax_glo;
        case {i_F0}
            h_axes = handles.ax_F0;
        case {i_PI}
            h_axes = handles.ax_pi;
        case {i_SPI}
            h_axes = handles.ax_spi;
        case {i_TR}
            h_axes = handles.ax_tr;
    end

    
    

function [i_TV ngest]=sel_gest(handles, h_text, h_othertexts)
if (get(handles.tb_gscore, 'Value') | get(handles.tb_tv, 'Value'))
    load t_params
    state = get(handles.tada, 'userdata');
    xy = get(gca, 'CurrentPoint');
    
    str_TV = get(h_text, 'String');
    i_TV = get_i_TV(str_TV);
    ngest = disp_param (i_TV, xy, handles, h_text, h_othertexts);
    state = get(handles.tada, 'UserData'); % This line should be present.
    
    state.ngest = ngest;
    state.i_TV = i_TV;
    state.str_TV = str_TV;
    set(handles.tada, 'userdata', state)
end


function ngest = disp_param (i_TV, xy, handles, h_text, h_othertexts)

if xy(1,1) < 0
    ngest = [];
    return
end

load t_params
state = get(handles.tada, 'userdata');


TV_SCORE = state.TV_SCORE;
ms_frm = state.ms_frm;

ngest = []; % n_th gesture
x_pnt = ceil(xy(1,1));
y_pnt = xy(1,2);
minmax = get(gca, 'YLim');

if i_TV == i_PI | i_TV == i_SPI
    if (TV_SCORE(i_TV).TV.PROMSUM(x_pnt) < y_pnt & y_pnt > 0)|...
            (TV_SCORE(i_TV).TV.PROMSUM(x_pnt) > y_pnt & y_pnt < 0)
        return
    end
else
    y_pnt = (y_pnt - minmax(1))*2/(minmax(2)-minmax(1)); %scaled to 0~2
    if TV_SCORE(i_TV).TV.PROMSUM(x_pnt) < y_pnt
        return
    end
end

y_pnt = ceil(y_pnt); % ceiled y_pnt (e.g. 1, 2)

set(h_text, 'ForegroundColor', 'r')

for i = 1: length(h_othertexts)
    set(h_othertexts(i), 'ForegroundColor', 'w')
end

for i = 1:length(TV_SCORE(i_TV).GEST)
    if x_pnt >= TV_SCORE(i_TV).GEST(i).BEG*ms_frm/wag_frm & x_pnt <= TV_SCORE(i_TV).GEST(i).END*ms_frm/wag_frm
        ngest = [ngest i];
    end
end

switch i_TV
    case {i_TBCL, i_TTCL, i_TTCR}
        rescale = deg_per_rad;
    case { i_LA, i_PRO, i_TBCD, i_TTCD, i_JAW}
        rescale = mm_per_dec;
    case {i_VEL, i_GLO, i_F0 i_PI i_SPI i_TR}
        rescale = 1;
end

if length(ngest) == 1
    set(handles.ed_beg, 'String', TV_SCORE(i_TV).GEST(ngest).BEG);
    set(handles.ed_end, 'String', TV_SCORE(i_TV).GEST(ngest).END);
    set(handles.ed_x0, 'String', TV_SCORE(i_TV).GEST(ngest).x.VALUE*rescale);
    set(handles.ed_f, 'String', sqrt(TV_SCORE(i_TV).GEST(ngest).k.VALUE)/(2*pi));
    set(handles.ed_d, 'String', TV_SCORE(i_TV).GEST(ngest).d.VALUE ...
        /(2*sqrt(TV_SCORE(i_TV).GEST(ngest).k.VALUE)));
    set(handles.ed_alpha, 'String', TV_SCORE(i_TV).GEST(ngest).x.ALPHA);
    set(handles.ed_beta, 'String', TV_SCORE(i_TV).GEST(ngest).x.BETA);
elseif length(ngest) == 2

    if TV_SCORE(i_TV).GEST(ngest(1)).BEG >TV_SCORE(i_TV).GEST(ngest(2)).BEG ...
            | (TV_SCORE(i_TV).GEST(ngest(1)).BEG ==TV_SCORE(i_TV).GEST(ngest(2)).BEG ...
            & TV_SCORE(i_TV).GEST(ngest(1)).END >TV_SCORE(i_TV).GEST(ngest(2)).END)
        ngest = [ngest(2) ngest(1)];
    end

    if y_pnt ==1
        set(handles.ed_beg, 'String', TV_SCORE(i_TV).GEST(ngest(1)).BEG);
        set(handles.ed_end, 'String', TV_SCORE(i_TV).GEST(ngest(1)).END);
        set(handles.ed_x0, 'String', TV_SCORE(i_TV).GEST(ngest(1)).x.VALUE*rescale);
        set(handles.ed_f, 'String', sqrt(TV_SCORE(i_TV).GEST(ngest(1)).k.VALUE)/(2*pi));
        set(handles.ed_d, 'String', TV_SCORE(i_TV).GEST(ngest(1)).d.VALUE ...
            /(2*sqrt(TV_SCORE(i_TV).GEST(ngest(1)).k.VALUE)));
        set(handles.ed_alpha, 'String', TV_SCORE(i_TV).GEST(ngest(1)).x.ALPHA);
        set(handles.ed_beta, 'String', TV_SCORE(i_TV).GEST(ngest(1)).x.BETA);
        ngest = ngest(1);
    elseif y_pnt == 2
        set(handles.ed_beg, 'String', TV_SCORE(i_TV).GEST(ngest(2)).BEG);
        set(handles.ed_end, 'String', TV_SCORE(i_TV).GEST(ngest(2)).END);
        set(handles.ed_x0, 'String', TV_SCORE(i_TV).GEST(ngest(2)).x.VALUE*rescale);
        set(handles.ed_f, 'String', sqrt(TV_SCORE(i_TV).GEST(ngest(2)).k.VALUE)/(2*pi));
        set(handles.ed_d, 'String', TV_SCORE(i_TV).GEST(ngest(2)).d.VALUE ...
            /(2*sqrt(TV_SCORE(i_TV).GEST(ngest(2)).k.VALUE)));
        set(handles.ed_alpha, 'String', TV_SCORE(i_TV).GEST(ngest(2)).x.ALPHA);
        set(handles.ed_beta, 'String', TV_SCORE(i_TV).GEST(ngest(2)).x.BETA);
        ngest = ngest(2);
    end

end


% --------------------------------------------------------------------
function varargout = rt_movGest_ButtonDownFcn(h, eventdata, handles, varargin)
state = get(handles.tada, 'userdata');
pos_rt = get(h, 'position');
cp_ax = get(gca, 'CurrentPoint');
state.clicked_cur_x = cp_ax(2,1);

x = abs([pos_rt(1) pos_rt(1)+pos_rt(3)] - cp_ax(2,1));


if x(1) < x(2) & x(1)<1
    state.MODGESTBTN = 1;  % button down for modifying selected gestures (Left)
elseif x(1) > x(2) & x(2)<1
    state.MODGESTBTN = 2;  % button down for modifying selected gestures (Right)
end

set(handles.tada, 'userdata', state)



% --------------------------------------------------------------------
function mn_proportionalFreq_Callback(hObject, eventdata, handles)
% hObject    handle to mn_proportionalFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmpi(get(hObject, 'checked'), 'on')
    set(hObject, 'checked', 'off')
else
    set(hObject, 'checked', 'on')
end



function ed_speech_rate_Callback(hObject, eventdata, handles)
% hObject    handle to ed_speech_rate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_speech_rate as text
%        str2double(get(hObject,'String')) returns contents of ed_speech_rate as a double


state = get(handles.tada, 'userdata');
state.speechRate = str2num(get(handles.ed_speech_rate, 'String'));
set(handles.tada, 'userdata', state);


% --------------------------------------------------------------------
function mn_saveFinalAsInitial_Callback(hObject, eventdata, handles)
% hObject    handle to mn_saveFinalAsInitial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

load t_params
state = get(handles.tada, 'userdata');
utt_name = get(handles.ed_uttname, 'String');
OSC = state.OSC;
ms_frm = state.ms_frm;

[fname,pname] = uiputfile( ...
    {'PH*.O*;PH*.o*;Ph*.O*;Ph*.o*;pH*.O*;pH*.o*;ph*.O*;ph*.o*',...
        'PH Files (PH*.O*)'}, 'PH files');

if fname == 0
    return
end

str_end = [];

if strfind(fname, '.O') 
    str_end = strfind(fname, '.O') -1;
elseif strfind(fname, '.o')
    str_end = strfind(fname, '.o') -1;
end

if ~isempty(str_end)
    fname = fname(1:str_end);
end
while strcmpi(fname(1:2), 'ph')
    fname = fname(3:end);
end

utt_save =  fname;

copyfile(['TV' utt_name '.O'], ['TV' utt_save '.O'])


% write ph.o
fid_w = fopen(strcat('PH', utt_save, '.O'), 'w');

% for i = 1:size(OSC, 2)
%     ln = ['''' OSC(i).OSC_ID ''' '...
%         num2str(OSC(i).OSC_OMEGA) ' '...
%         num2str(OSC(i).OSC_GENRELPH) ' '...
%         num2str(OSC(i).OSC_ESCAP) ' '...
%         num2str(OSC(i).OSC_AMPINIT) ' '...
%         num2str(OSC(i).OSC_FINPHASE) ' / '...
%         num2str(OSC(i).OSC_RAMPPHASES)];
%     fprintf(fid_w, '%s\n', ln);
% end

% modified by HN 070529
% phaseinit is saved instead of saving finphase
for i = 1:size(OSC, 2)
    ln = ['''' OSC(i).OSC_ID ''' '...
        num2str(OSC(i).OSC_OMEGA) ' '...
        num2str(OSC(i).OSC_GENRELPH) ' '...
        num2str(OSC(i).OSC_ESCAP) ' '...
        num2str(OSC(i).OSC_AMPINIT) ' '...
        num2str(OSC(i).OSC_PHASEINIT) ' / '...
        num2str(OSC(i).OSC_RAMPPHASES)];
    fprintf(fid_w, '%s\n', ln);
end



fprintf(fid_w, '%s\n', '/coupling/');

for i = 1:size(OSC, 2)-1
    for j = i:size(OSC, 2)
        if ~isnan(OSC(i).OSC_RELPHASE(j))
            if OSC(i).OSC_RELPHASE(j) > 0
                ln = ['''' OSC(j).OSC_ID ''' '...
                    '''' OSC(i).OSC_ID ''' '...
                    num2str(OSC(j).OSC_COUPLSTRNTH(i)) ' '...
                    num2str(OSC(i).OSC_COUPLSTRNTH(j)) ' '...
                    num2str(abs(OSC(j).OSC_RELPHASE(i)))];
            else
                ln = ['''' OSC(i).OSC_ID ''' '...
                    '''' OSC(j).OSC_ID ''' '...
                    num2str(OSC(i).OSC_COUPLSTRNTH(j)) ' '...
                    num2str(OSC(j).OSC_COUPLSTRNTH(i)) ' '...
                    num2str(abs(OSC(i).OSC_RELPHASE(j)))];
            end
            fprintf(fid_w, '%s\n', ln);
        end
    end
end


fclose(fid_w);



% --------------------------------------------------------------------
function mn_genHL_Callback(hObject, eventdata, handles)
% hObject    handle to mn_genHL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if strcmpi(get(hObject, 'checked'), 'on')
    set(hObject, 'checked', 'off')
else
    set(hObject, 'checked', 'on')
end


% --------------------------------------------------------------------
function mn_options_Callback(hObject, eventdata, handles)
% hObject    handle to mn_options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmpi(get(hObject, 'checked'), 'on')
    set(hObject, 'checked', 'off')
else
    set(hObject, 'checked', 'on')
end



% --------------------------------------------------------------------
function mn_plotRelPhase_Callback(hObject, eventdata, handles)
% hObject    handle to mn_plotRelPhase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmpi(get(hObject, 'checked'), 'on')
    set(hObject, 'checked', 'off')
else
    set(hObject, 'checked', 'on')
end



% --------------------------------------------------------------------
function mn_apply2otherTVs_Callback(hObject, eventdata, handles)
% hObject    handle to mn_apply2otherTVs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if strcmpi(get(hObject, 'checked'), 'on')
    set(hObject, 'checked', 'off')
else
    set(hObject, 'checked', 'on')
end


% --------------------------------------------------------------------
function mn_gestInout_Callback(hObject, eventdata, handles)
% hObject    handle to mn_gestInout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load t_params
[fname,pname] = uiputfile({'tv*.o', 'output File (*.o)'}, 'specify GEST output file and working directory');
if fname == 0
    return
end

while strcmpi(fname(1:2), 'tv')
    fname = fname(3:end);
end
while strcmpi(fname(end-1:end), '.o')
    fname = fname(1:end-2);
end

prompt = {'Input(orthography) -required',...
    'Output(filename) -required',...
    'Language directory -optional',...
    'Prefix -optional'};

dlg_title = 'GEST input output specification';
num_lines = 1;
def = {fname, fname, '', ''};
options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
ans = inputdlg(prompt,dlg_title,num_lines,def, options);

if isempty(ans), return, end

cd(pname)
if isempty(ans{1}) | isempty(ans{2})
    errordlg('input(orthography) & output(filename) are required')
elseif isempty(ans{3}) & ~isempty(ans{4})
    errordlg('PH file requires dictionary file specification')
elseif ~isempty(ans{3}) & ~isempty(ans{4})
    gest(ans{2}, ans{1}, ans{3}, ans{4})
elseif ~isempty(ans{3}) & isempty(ans{4})
    gest(ans{2}, ans{1}, ans{3})
elseif isempty(ans{3}) & isempty(ans{4})
    gest(ans{2}, ans{1})
end


    
% --------------------------------------------------------------------
function mn_setOSCsim_Callback(hObject, eventdata, handles)
% hObject    handle to mn_setOSCsim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mn_save_Callback(hObject, eventdata, handles)
% hObject    handle to mn_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mn_gest_Callback(hObject, eventdata, handles)
% hObject    handle to mn_gest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mn_saveAs_Callback(hObject, eventdata, handles)
% hObject    handle to mn_saveAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tada('pb_saveas_Callback', handles.pb_saveas, [], handles)



% --------------------------------------------------------------------
function mn_Traj_Callback(hObject, eventdata, handles)
% hObject    handle to mn_Traj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tada('pb_savemavis_Callback', handles.pb_savemavis, [], handles)

% --------------------------------------------------------------------
function mn_duplicate_Callback(hObject, eventdata, handles)
% hObject    handle to mn_duplicate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% borrowed from mview code without permission

state = get(handles.tada, 'userdata');
h = gcbf;
ch = figure('colormap', get(h, 'colormap'), 'name', state.utt_name);
copyobj(flipud(findobj(h,'type','axes')), ch);
copyobj(flipud(findobj(h,'type','line', '-regexp', 'tag', 'ln_osc*' )), findobj(h,'tag','ax_line'));
copyobj(flipud(findobj(h,'type','text', '-regexp', 'tag', 'tx_osc*' )), findobj(h,'tag','ax_line'));


% --------------------------------------------------------------------
function Version_Callback(hObject, eventdata, handles)
% hObject    handle to Version (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function versionNo_Callback(hObject, eventdata, handles)
% hObject    handle to versionNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mn_plotCycleTicks_Callback(hObject, eventdata, handles)
% hObject    handle to mn_plotCycleTicks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmpi(get(hObject, 'checked'), 'on')
    set(hObject, 'checked', 'off')
else
    set(hObject, 'checked', 'on')
end



% --- Executes on button press in pb_makeMov.
function pb_makeMov_Callback(hObject, eventdata, handles)
% hObject    handle to pb_makeMov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

load t_params
state = get(handles.tada, 'userdata');
ASYPEL = state.ASYPEL;
TV_SCORE = state.TV_SCORE;
TV = state.TV;
hyoid = state.HYOID;
pal = state.PAL;
sig = state.sig;
srate = state.srate;
fName = state.utt_name;
XLim = get(handles.ax_audiosel, 'XLim');
c = [XLim(1) XLim(2)];

%%
h_fig = figure('units','pixels','resize','off', 'menubar','none');
rect = get(h_fig, 'position'); rect(2) = rect(2) -250; rect(4) = rect(4)+300;
set(h_fig, 'position', rect)

%% display waveform,spectrogram & TVs
%%
h_wav = axes('position',[.02  .57 .96  .07]);
plot(sig, 'k')
set(h_wav, 'XLim', round([c(1) c(2)]*50), 'YLim', [-1 1],  'xtick',[], 'ytick',[], 'box', 'on');

%%
h_spec = axes('position',[.02  .44  .96  .13]);
selrng = round(XLim/2*100);
if selrng(1) == 0, selrng(1) = 1; end
myspecgrm(sig(selrng(1):selrng(2)), srate, h_spec)

%%
h_LA = axes('position',[.02  .356  .96  .084]);
h_TB = axes('position',[.02  .272  .96  .084]);
h_TT = axes('position',[.02  .188  .96  .084]);
h_VEL = axes('position',[.02  .104  .96  .084]);
h_GLO = axes('position',[.02  .02  .96  .084]);

h_TVCDs = [h_LA h_TB h_TT h_VEL h_GLO];
i_TVCDs = [i_LA i_TBCD i_TTCD i_VEL i_GLO];

for i = 1:length(i_TVCDs)
    axes(h_TVCDs(i))
    plot(TV_SCORE(i_TVCDs(i)).TV.PROMSUM, 'k'), hold on
    mn = min(TV(i_TVCDs(i),:)); mx = max(TV(i_TVCDs(i),:));
    if mn == mx
        plot(TV(i_TVCDs(i),:)-mx +1) 
    else
        plot((TV(i_TVCDs(i),:) -mn)/max(TV(i_TVCDs(i),:) - mn)*2)
    end
    set(h_TVCDs(i), 'XLim', [c(1) c(2)], 'YLim', [0 2],  'xtick',[], 'ytick',[], 'box', 'on');
    switch i_TVCDs(i)
        case i_LA, tx = 'LA'; 
        case i_TBCD, tx = 'TBCD'; 
        case i_TTCD, tx = 'TTCD'; 
        case i_VEL, tx = 'VEL'; 
        case i_GLO, tx = 'GLO';
    end
    text(1+c(1), 1.8, tx, 'FontSize', 8)
end

%%
h_cl = axes('position',[.02 .02 .96 .62]);
ln_cl = line([0 0],[0 1],'color',[0 .6 0]);
set(h_cl, 'XLim', [c(1) c(2)]*50, 'color','none','xtick',[],'ytick',[]);

if round(c(1)) == 0
    c(1) = 1;
end

set(h_fig, 'name', ['''' fName '''' ' in CASY']);

%% display casy
%%
h_casy = axes('position',[.2375  .65  .525  .33], 'ydir', 'normal', 'xtick',[], 'ytick',[], 'box', 'on', 'visible', 'on');
set(h_casy, 'XLim', [50 150], 'YLim', [40 160])
ln_upperoutline = line(0, 0, 'color', 'k', 'visible', 'on');
ln_bottomoutline = line(0, 0, 'color', 'k', 'visible', 'on');
ln_velumopen = line(0, 0, 'color', 'w', 'visible', 'on');

%%
h_asypel = axes('position',[.2375  .65  .525  .33],'ydir', 'normal', 'xtick',[], 'ytick',[], 'box', 'on', 'visible', 'off');
set(h_asypel, 'XLim', [50 150], 'YLim', [40 160])
nSens = 8;
col = hsv(nSens+2);
for si = 1 : nSens,
	tail(si) = line('color',col(si,:), 'marker','.', 'markerSize',1, ...
					'xdata',50,'ydata',40, 'visible', 'off');
	head(si) = line('color',col(si,:),'marker','o','markerfaceColor',col(si,:), ...
					'xdata',50,'ydata',40, 'visible', 'off');
end;
line('xdata',pal(:,1),'ydata',pal(:,2), 'visible', 'off');
ln_intpl=line(50, 40, 'color', [.8 .8 .8], 'LineStyle', '-', 'visible', 'off');

%%
x_spat2d_all = [];
y_spat2d_all = [];
nr=7;
if get(handles.tb_tv, 'value')
    if ~isempty(ffind_case(sprintf('%s.avi',fName)))
        delete(sprintf('%s.avi',fName))
    end
    mov = avifile(sprintf('%s_casy.avi',fName),'fps',200/nr,'compression','none', 'keyframe', 200/nr);
    for i = c(1):nr:c(2)
            i = round(i);
            x_spat2d = [ASYPEL(1).SIGNAL(1,i) ...
                ASYPEL(2).SIGNAL(1,i) ...
                ASYPEL(3).SIGNAL(1,i) ...
                ASYPEL(4).SIGNAL(1,i) ...
                ASYPEL(6).SIGNAL(1,i) ...
                ASYPEL(7).SIGNAL(1,i) ...
                ASYPEL(8).SIGNAL(1,i) ...
                hyoid(1)];
            y_spat2d = [ASYPEL(1).SIGNAL(2,i) ...
                ASYPEL(2).SIGNAL(2,i) ...
                ASYPEL(3).SIGNAL(2,i) ...
                ASYPEL(4).SIGNAL(2,i) ...
                ASYPEL(6).SIGNAL(2,i) ...
                ASYPEL(7).SIGNAL(2,i) ...
                ASYPEL(8).SIGNAL(2,i) ...
                hyoid(2)];
            xx = linspace(min(x_spat2d(4:end-1)), max(x_spat2d(4:end-1)));
            yy = interp1(x_spat2d(4:end-1), y_spat2d(4:end-1), xx, '*PCHIP');
            x_spat2d_all = [x_spat2d_all; x_spat2d];
            y_spat2d_all = [y_spat2d_all; y_spat2d];
            for si = 1 : nSens,
                if si >=2
                    len_tail = 6; 
                    len_tail = min(len_tail, size(x_spat2d_all,1));
                    set(tail(si),'xdata',x_spat2d_all(end-len_tail+1:end,si),'ydata',y_spat2d_all(end-len_tail+1:end,si));
                end
                set(head(si),'xdata',x_spat2d(si),'ydata',y_spat2d(si));
            end;
            set(ln_intpl, 'xdata', xx, 'ydata', yy);

            set(ln_upperoutline, 'xdata', state.UPPEROUTLINE(:,1,i), 'ydata', state.UPPEROUTLINE(:,2,i))
            set(ln_bottomoutline, 'xdata', state.BOTTOMOUTLINE(:,1,i), 'ydata', state.BOTTOMOUTLINE(:,2,i))
            set(ln_velumopen, 'xdata', state.UPPEROUTLINE(4:5,1,i), 'ydata', state.UPPEROUTLINE(4:5,2,i))

            set(ln_cl, 'xdata', [i i]*50)
            drawnow
            f = getframe(h_fig, [10 10 545 700]);
        	mov = addframe(mov,f);
    end
end
mov = close(mov);


set(h_fig, 'name', ['''' fName '''' ' in pseudo pellets']);
%% display pseudo-pellets
%%
h_casy = axes('position',[.2375  .65  .525  .33], 'ydir', 'normal', 'xtick',[], 'ytick',[], 'box', 'on', 'visible', 'off');
set(h_casy, 'XLim', [50 150], 'YLim', [40 160])
ln_upperoutline = line(0, 0, 'color', 'k', 'visible', 'off');
ln_bottomoutline = line(0, 0, 'color', 'k', 'visible', 'off');
ln_velumopen = line(0, 0, 'color', 'k', 'visible', 'off');

%%
h_asypel = axes('position',[.2375  .65  .525  .33],'ydir', 'normal', 'xtick',[], 'ytick',[], 'box', 'on', 'visible', 'on');
set(h_asypel, 'XLim', [50 150], 'YLim', [40 160])
nSens = 8;
col = hsv(nSens+2);
for si = 1 : nSens,
	tail(si) = line('color',col(si,:), 'marker','.', 'markerSize',1, ...
					'xdata',50,'ydata',40, 'visible', 'on');
	head(si) = line('color',col(si,:),'marker','o','markerfaceColor',col(si,:), ...
					'xdata',50,'ydata',40, 'visible', 'on');
end;
line('xdata',pal(:,1),'ydata',pal(:,2), 'visible', 'on');
ln_intpl=line(50, 40, 'color', [.8 .8 .8], 'LineStyle', '-', 'visible', 'on');

%%
x_spat2d_all = [];
y_spat2d_all = [];
if get(handles.tb_tv, 'value')
    if ~isempty(ffind_case(sprintf('%s.avi',fName)))
        delete(sprintf('%s.avi',fName))
    end
    mov = avifile(sprintf('%s_pel.avi',fName),'fps',200/nr,'compression','none', 'keyframe', 200/nr);
    for i = c(1):nr:c(2)
            i = round(i);
            x_spat2d = [ASYPEL(1).SIGNAL(1,i) ...
                ASYPEL(2).SIGNAL(1,i) ...
                ASYPEL(3).SIGNAL(1,i) ...
                ASYPEL(4).SIGNAL(1,i) ...
                ASYPEL(6).SIGNAL(1,i) ...
                ASYPEL(7).SIGNAL(1,i) ...
                ASYPEL(8).SIGNAL(1,i) ...
                hyoid(1)];
            y_spat2d = [ASYPEL(1).SIGNAL(2,i) ...
                ASYPEL(2).SIGNAL(2,i) ...
                ASYPEL(3).SIGNAL(2,i) ...
                ASYPEL(4).SIGNAL(2,i) ...
                ASYPEL(6).SIGNAL(2,i) ...
                ASYPEL(7).SIGNAL(2,i) ...
                ASYPEL(8).SIGNAL(2,i) ...
                hyoid(2)];
            xx = linspace(min(x_spat2d(4:end-1)), max(x_spat2d(4:end-1)));
            yy = interp1(x_spat2d(4:end-1), y_spat2d(4:end-1), xx, '*PCHIP');
            x_spat2d_all = [x_spat2d_all; x_spat2d];
            y_spat2d_all = [y_spat2d_all; y_spat2d];
            for si = 1 : nSens,
                if si >=2
                    len_tail = 6; 
                    len_tail = min(len_tail, size(x_spat2d_all,1));
                    set(tail(si),'xdata',x_spat2d_all(end-len_tail+1:end,si),'ydata',y_spat2d_all(end-len_tail+1:end,si));
                end
                set(head(si),'xdata',x_spat2d(si),'ydata',y_spat2d(si));
            end;
            set(ln_intpl, 'xdata', xx, 'ydata', yy);

            set(ln_upperoutline, 'xdata', state.UPPEROUTLINE(:,1,i), 'ydata', state.UPPEROUTLINE(:,2,i))
            set(ln_bottomoutline, 'xdata', state.BOTTOMOUTLINE(:,1,i), 'ydata', state.BOTTOMOUTLINE(:,2,i))
            set(ln_velumopen, 'xdata', state.UPPEROUTLINE(4:5,1,i), 'ydata', state.UPPEROUTLINE(4:5,2,i))

            set(ln_cl, 'xdata', [i i]*50)
            drawnow
            f = getframe(h_fig, [10 10 545 700]);
        	mov = addframe(mov,f);
    end
end
mov = close(mov);

close(h_fig)

