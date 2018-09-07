function pi2gscore(utt_name, utt_save, t, t_scaled)
% Copyright Haskins Laboratories, Inc., 2000-2004
% 270 Crown Street, New Haven, CT 06514, USA
% coded by Hosung Nam (hosung.nam@yale.edu)
%

% update TV
fn = ffind_case(['TV',utt_name,'.G']);    % temporary filename

if isempty(fn)                   % if empty
    errordlg('TV~.G file not found','File Error');
    return
end

fid_r = fopen(fn, 'rt'); % open data file

% first line information (msec frame, last frame No.)
ms_frm = fscanf(fid_r, '%f', 1); %msec frame
old_last_frm = fscanf(fid_r, '%f\n', 1); %last frame No.
%srate = 1000/ms_frm;
%n_frm = (last_frm)*ms_frm/wag_frm;

t_scl_utt = find(t_scaled <= old_last_frm * ms_frm/1000);
new_last_frm = ceil(t(t_scl_utt(end))/ms_frm*1000);

fid_w = fopen(strcat('TV', utt_save, '.G'), 'w');
fprintf(fid_w, '%s\n', [num2str(ms_frm) ' ' num2str(new_last_frm)]);

while 1
    tline = fgetl(fid_r);
    if ~ischar(tline), break, end
    
    sp = findstr(tline, ' ');
    
    old_BEG = str2num(tline(sp(2)+1:sp(3)-1));
    old_END = str2num(tline(sp(3)+1:sp(4)-1));
    
    t_scl_gest = find(t_scaled >= old_BEG * ms_frm/1000 & t_scaled <= old_END * ms_frm/1000);
    new_BEG = floor(t(t_scl_gest(1))/ms_frm*1000);
    new_END = ceil(t(t_scl_gest(end))/ms_frm*1000);
    
    new_tline = [tline(1:sp(2)) num2str(new_BEG) ' ' num2str(new_END) tline(sp(4):end)];
    fprintf(fid_w, '%s\n', new_tline);
end

fclose(fid_r);
fclose(fid_w);

% update TVTV
fn2 = ffind_case(['TVTV',utt_name,'.G']);    % temporary filename

if isempty(fn2)                   % if empty
    errordlg('TVTV~.G file not found','File Error');
    return
end

fid_r = fopen(fn2, 'rt'); % open data file

% first line information (msec frame, last frame No.)
ms_frm = fscanf(fid_r, '%f', 1); %msec frame
old_last_frm = fscanf(fid_r, '%f\n', 1); %last frame No.
%srate = 1000/ms_frm;
%n_frm = (last_frm)*ms_frm/wag_frm;

t_scl_utt = find(t_scaled <= old_last_frm * ms_frm/1000);
new_last_frm = ceil(t(t_scl_utt(end))/ms_frm*1000);

fid_w = fopen(strcat('TVTV', utt_save, '.G'), 'w');
fprintf(fid_w, '%s\n', [num2str(ms_frm) ' ' num2str(new_last_frm)]);

while 1
    tline = fgetl(fid_r);
    if ~ischar(tline), break, end
    
    sp = findstr(tline, ' ');
    
    old_BEG = str2num(tline(sp(2)+1:sp(3)-1));
    old_END = str2num(tline(sp(3)+1:sp(4)-1));
    
    t_scl_gest = find(t_scaled >= old_BEG * ms_frm/1000 & t_scaled <= old_END * ms_frm/1000);
    new_BEG = floor(t(t_scl_gest(1))/ms_frm*1000);
    new_END = ceil(t(t_scl_gest(end))/ms_frm*1000);
    
    new_tline = [tline(1:sp(2)) num2str(new_BEG) ' ' num2str(new_END) tline(sp(4):end)];
    fprintf(fid_w, '%s\n', new_tline);
end

fclose(fid_r);
fclose(fid_w);

% blank PI file
% fid_w = fopen(strcat('PI', utt_save, '.G'), 'w');
% fprintf(fid_w, '%s\n', ['0 0']);
% fprintf(fid_w, '%s\n', ['0 0 0 0 0']);
% fclose(fid_w);