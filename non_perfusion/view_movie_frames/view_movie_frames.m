function varargout = view_movie_frames(varargin)
% VIEW_MOVIE_FRAMES MATLAB code for view_movie_frames.fig
%      VIEW_MOVIE_FRAMES, by itself, creates a new VIEW_MOVIE_FRAMES or raises the existing
%      singleton*.
%
%      H = VIEW_MOVIE_FRAMES returns the handle to a new VIEW_MOVIE_FRAMES or the handle to
%      the existing singleton*.
%
%      VIEW_MOVIE_FRAMES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEW_MOVIE_FRAMES.M with the given input arguments.
%
%      VIEW_MOVIE_FRAMES('Property','Value',...) creates a new VIEW_MOVIE_FRAMES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before view_movie_frames_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to view_movie_frames_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help view_movie_frames

% Last Modified by GUIDE v2.5 16-Jul-2014 14:26:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @view_movie_frames_OpeningFcn, ...
                   'gui_OutputFcn',  @view_movie_frames_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before view_movie_frames is made visible.
function view_movie_frames_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to view_movie_frames (see VARARGIN)


% Choose default command line output for view_movie_frames
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes view_movie_frames wait for user response (see UIRESUME)
% uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = view_movie_frames_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in nextFrame.
function nextFrame_Callback(hObject, eventdata, handles)
% hObject    handle to nextFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.ready_to_rumble == 1)
    cur_frame = handles.frame_current;
    if(cur_frame + 1 <= handles.frame_count)
        handles.frame_current = handles.frame_current + 1;
    end
    paths = handles.frame_paths;
    filename = paths{handles.frame_current};
    img = imread([handles.pathname, filename]);
    axes(handles.axes1);
    imshow(img);
    set(handles.fileNameEdit, 'String', filename);
end
guidata(hObject, handles);


% --- Executes on button press in prevFrame.
function prevFrame_Callback(hObject, eventdata, handles)
% hObject    handle to prevFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.ready_to_rumble == 1)
    cur_frame = handles.frame_current;
    if(cur_frame + 1 > 0)
        handles.frame_current = handles.frame_current - 1;
    end
    paths = handles.frame_paths;
    filename = paths{handles.frame_current};
    img = imread([handles.pathname, filename]);
    axes(handles.axes1);
    imshow(img);
    set(handles.fileNameEdit, 'String', filename);
end
guidata(hObject, handles);

function filePath_Callback(hObject, eventdata, handles)
% hObject    handle to filePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filePath as text
%        str2double(get(hObject,'String')) returns contents of filePath as a double
handles.filename = get(hObject,'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function filePath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadVideoXML.
function loadVideoXML_Callback(hObject, eventdata, handles)
% hObject    handle to loadVideoXML (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    path_to_file = [handles.pathname, handles.filename];
    if(exist(path_to_file, 'file') == 0)
        handles.ready_to_rumble = 0;
    else
        [count, paths, times] = get_images_from_video_xml(path_to_file);
        handles.frame_count = count;
        handles.frame_paths = paths;
        handles.frame_times = times;
        handles.frame_current = 0;
        handles.ready_to_rumble = 1;
    end
    guidata(hObject, handles);


% --- Executes on button press in browseFile.
function browseFile_Callback(hObject, eventdata, handles)
% hObject    handle to browseFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName,~] = uigetfile('*.xml');
handles.filename = FileName;
handles.pathname = PathName;
fullpath = [handles.pathname, handles.filename];
set(handles.filePath, 'String', fullpath);
guidata(hObject, handles);



function fileNameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to fileNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fileNameEdit as text
%        str2double(get(hObject,'String')) returns contents of fileNameEdit as a double


% --- Executes during object creation, after setting all properties.
function fileNameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
