function fn_out = ffind_case(varargin)
% Copyright Haskins Laboratories, Inc., 2000-2004
% 270 Crown Street, New Haven, CT 06514, USA
% coded by Hosung Nam (hosung.nam@yale.edu)
%
% case-insensively find filename matching wanted filename

if nargin == 1
    fn_all = dir(['*.*']);
elseif nargin == 2
    fn_all = dir([varargin{2} '\*.*']);
end
fn_in = varargin{1};

sz = size(fn_all);
fn_all_copy = fn_all;
k = [];
fn_out = [];

for i = 1:sz(1)
    idx = find(fn_all(i).name == ';');
    if idx
        fn_all_copy(i).name = fn_all(i).name(1:idx-1);
    end
    if strcmpi(fn_in, fn_all_copy(i).name)
        k = [k i];
    end
end

if ~isempty(k)
    if length(k) >1
        button = questdlg(['More than one file of  ', fn_in, '. Do you want to open any?'], 'Select File', 'Yes', 'No', 'Yes');
        if strcmp(button,'Yes')
            fn_out = fn_all(k(1)).name;
        elseif strcmp(button,'No')
            fn_out = [];
        end
    else
        fn_out = fn_all(k(1)).name;
    end
end

if nargin == 2
    fn_out = [varargin{2} '\' fn_out];
end