function [cyc v] = cal_cyc(s, t, flg, thrsh)
% s: signal, thrsh: to distinguish different cycles, 
% flg: cycle for peaks or trough (1: peaks, 0:troughs) 

if nargin <4
    thrsh = 20;
    if nargin <3
        flg = 'p';
    end
end
    
[pk tr] = find_peaks(s);
if strcmpi(flg, 'p') 
    v = t(pk); 
else strcmpi(flg, 't')
    v = t(tr); 
end

cycles = diff(v);
[pp tt] = find_peaks(cycles);
if isempty(pp) | isempty(tt) % if it is so flat
    cyc = mean(cycles);
else
    cyc = sort([mean(cycles(pp)) mean(cycles(tt))]);
    if cyc(2)-cyc(1) <= thrsh
        cyc = mean(cyc);
    end
end