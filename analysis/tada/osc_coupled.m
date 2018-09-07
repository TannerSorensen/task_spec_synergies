function varargout = osc_coupled(varargin)
% OSC_COUPLED M-file for osc_coupled.fig
%      OSC_COUPLED, by itself, creates a new OSC_COUPLED or raises the existing
%      singleton*.
%
%      H = OSC_COUPLED returns the handle to a new OSC_COUPLED or the handle to
%      the existing singleton*.
%
%      OSC_COUPLED('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OSC_COUPLED.M with the given input arguments.
%
%      OSC_COUPLED('Property','Value',...) creates a new OSC_COUPLED or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before osc_coupled_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to osc_coupled_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help osc_coupled

% Last Modified by GUIDE v2.5 14-Dec-2005 11:33:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @osc_coupled_OpeningFcn, ...
                   'gui_OutputFcn',  @osc_coupled_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before osc_coupled is made visible.
function osc_coupled_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to osc_coupled (see VARARGIN)

% Choose default command line output for osc_coupled
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes osc_coupled wait for user response (see UIRESUME)
% uiwait(handles.osc_coupled);


% --- Outputs from this function are returned to the command line.
function varargout = osc_coupled_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




function tx_finrelphase1_Callback(hObject, eventdata, handles)
% hObject    handle to tx_finrelphase1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tx_finrelphase1 as text
%        str2double(get(hObject,'String')) returns contents of tx_finrelphase1 as a double


% --- Executes during object creation, after setting all properties.
function tx_finrelphase1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tx_finrelphase1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function tx_finrelphase2_Callback(hObject, eventdata, handles)
% hObject    handle to tx_finrelphase2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tx_finrelphase2 as text
%        str2double(get(hObject,'String')) returns contents of tx_finrelphase2 as a double


% --- Executes during object creation, after setting all properties.
function tx_finrelphase2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tx_finrelphase2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit23_Callback(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit23 as text
%        str2double(get(hObject,'String')) returns contents of edit23 as a double


% --- Executes during object creation, after setting all properties.
function edit23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function tx_escap1_Callback(hObject, eventdata, handles)
% hObject    handle to tx_escap1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tx_escap1 as text
%        str2double(get(hObject,'String')) returns contents of tx_escap1 as a double


% --- Executes during object creation, after setting all properties.
function tx_escap1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tx_escap1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function tx_couplstrnth1_Callback(hObject, eventdata, handles)
% hObject    handle to tx_couplstrnth1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tx_couplstrnth1 as text
%        str2double(get(hObject,'String')) returns contents of tx_couplstrnth1 as a double


% --- Executes during object creation, after setting all properties.
function tx_couplstrnth1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tx_couplstrnth1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function tx_phaseinit1_Callback(hObject, eventdata, handles)
% hObject    handle to tx_phaseinit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tx_phaseinit1 as text
%        str2double(get(hObject,'String')) returns contents of tx_phaseinit1 as a double


% --- Executes during object creation, after setting all properties.
function tx_phaseinit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tx_phaseinit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function tx_omega2_Callback(hObject, eventdata, handles)
% hObject    handle to tx_omega2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tx_omega2 as text
%        str2double(get(hObject,'String')) returns contents of tx_omega2 as a double


% --- Executes during object creation, after setting all properties.
function tx_omega2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tx_omega2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function tx_escap2_Callback(hObject, eventdata, handles)
% hObject    handle to tx_escap2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tx_escap2 as text
%        str2double(get(hObject,'String')) returns contents of tx_escap2 as a double


% --- Executes during object creation, after setting all properties.
function tx_escap2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tx_escap2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function tx_couplstrnth2_Callback(hObject, eventdata, handles)
% hObject    handle to tx_couplstrnth2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tx_couplstrnth2 as text
%        str2double(get(hObject,'String')) returns contents of tx_couplstrnth2 as a double


% --- Executes during object creation, after setting all properties.
function tx_couplstrnth2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tx_couplstrnth2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function tx_phaseinit2_Callback(hObject, eventdata, handles)
% hObject    handle to tx_phaseinit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tx_phaseinit2 as text
%        str2double(get(hObject,'String')) returns contents of tx_phaseinit2 as a double


% --- Executes during object creation, after setting all properties.
function tx_phaseinit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tx_phaseinit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function tx_ampinit1_Callback(hObject, eventdata, handles)
% hObject    handle to tx_ampinit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tx_ampinit1 as text
%        str2double(get(hObject,'String')) returns contents of tx_ampinit1 as a double


% --- Executes during object creation, after setting all properties.
function tx_ampinit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tx_ampinit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function tx_ampinit2_Callback(hObject, eventdata, handles)
% hObject    handle to tx_ampinit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tx_ampinit2 as text
%        str2double(get(hObject,'String')) returns contents of tx_ampinit2 as a double


% --- Executes during object creation, after setting all properties.
function tx_ampinit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tx_ampinit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


