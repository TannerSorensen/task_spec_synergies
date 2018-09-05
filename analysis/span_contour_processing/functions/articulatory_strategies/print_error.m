function print_error(strategies)
% PRINT_ERROR - print the error between the sum of articulator
% contributions and the total change in constriction degree
% 
% INPUT:
%  Variable name: strategies
%  Size: 1x1
%  Class: struct
%  Description: Struct with the following fields.
%  - jaw: Nx6 array of double; entries are jaw contributions to change in
%  each of 6 constriction degrees (columns) in N real-time magnetic 
%  resonance imaging video frames (rows)
%  - lip: Nx6 array of double; entries are lip contributions to change in
%  each of 6 constriction degrees (columns) in N real-time magnetic 
%  resonance imaging video frames (rows)
%  - tng: Nx6 array of double; entries are tongue contributions to change 
%  in each of 6 constriction degrees (columns) in N real-time magnetic 
%  resonance imaging video frames (rows)
%  - tng: Nx6 array of double; entries are velum contributions to change 
%  in each of 6 constriction degrees (columns) in N real-time magnetic 
%  resonance imaging video frames (rows)
%  - dz: Nx6 array of double; entries are change in each of 6 constriction 
%  degrees (columns) in N real-time magnetic resonance imaging video frames
%  (rows)
%  - dw: Nx8 array of double; entries are change in 8 factor coefficients 
%  (columns) in N real-time magnetic resonance imaging video frames (rows)
%  - cl: (cell array of strings) identifier for the 6 places of 
%  articulation
% 
% FUNCTION OUTPUT: 
%  none
% 
% SAVED OUTPUT: 
%  none
% 
% Tanner Sorensen
% Signal Analysis and Interpretation Laboratory
% Feb. 16, 2017

jaw = strategies.jaw;
lip = strategies.lip;
tng = strategies.tng;
vel = strategies.vel;
dz = strategies.dz;
cl = strategies.cl;
[n, nz] = size(dz);

for i=1:nz
    fprintf('\n%s\n',cl{i})
    % Display error calculations for...
    if strcmp(cl{i},'pharU')
        % ...velopharyngeal constriction degree
        fprintf('dz percent error: %.2f\n', 100 * mean(abs(vel(1:n,i) - dz(1:n,i))) / mean(abs(dz(1:n,i))) )
        fprintf('correlation: %.2f\n', corr(vel(1:n,i), dz(1:n,i)) )
    elseif strcmp(cl{i},'bilabial')
        % ...bilabial constriction degree
        fprintf('dz percent error: %.2f\n', 100 * mean(abs(jaw(1:n,i)+lip(1:n,i) - dz(1:n,i))) / mean(abs(dz(1:n,i))) )
        fprintf('correlation: %.2f\n', corr(jaw(1:n,1)+lip(1:n,i), dz(1:n,i)) )
    else
        % ...lingual constriction degrees
        fprintf('dz percent error: %.2f\n', 100 * mean(abs(jaw(1:n,i)+tng(1:n,i) - dz(1:n,i))) / mean(abs(dz(1:n,i))) )
        fprintf('correlation: %.2f\n', corr(jaw(1:n,i)+tng(1:n,i), dz(1:n,i)))
    end
    disp('')
end

end