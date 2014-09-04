function varargout = Alexizer(varargin)
% Alexizer
% 
% Description:	alexize the world
% 
% Syntax:	Alexizer
% 
% Updated: 2012-06-10
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Alexizer_OpeningFcn, ...
                   'gui_OutputFcn',  @Alexizer_OutputFcn, ...
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
%------------------------------------------------------------------------------%

%------------------------------------------------------------------------------%
function Alexizer_OpeningFcn(hObject, eventdata, handles, varargin)
	global AlexizerInfo;
	
	handles.output = hObject;
	
	%set the gui position
		pS		= get(0,'ScreenSize');
		p		= get(hObject,'Position');
		p(1)	= 0;
		p(2)	= (pS(4)-p(4))/2;
		set(hObject,'Position',p);
	
	%prepare the input device
		handles.input.t			= [];
		handles.input.x			= [];
		handles.input.device	= Alexizer.Input.PsychMic;
		handles.timer.input		= timer(...
									'Name'			, 'alexizer_input'					, ...
									'TimerFcn'		, @Alexizer_Input					, ...
									'Period'		, handles.input.device.duration	, ...
									'ExecutionMode'	, 'fixedRate'						  ...
									);
	
	% Update handles structure
	guidata(hObject, handles);
	AlexizerInfo	= handles;
	
	% UIWAIT makes Alexizer wait for user response (see UIRESUME)
	uiwait(handles.figMain);
%------------------------------------------------------------------------------%
function varargout = Alexizer_OutputFcn(hObject, eventdata, handles)
	global AlexizerInfo;
	
	stop(AlexizerInfo.timer.input);
	delete(AlexizerInfo.timer.input);
	AlexizerInfo.input.device.Close;
%------------------------------------------------------------------------------%

%------------------------------------------------------------------------------%
function togAnalyze_Callback(hObject, eventdata, handles)
	bOn	= toggleOnOff(hObject);
	
	if bOn
		handles.input.device.Open;
		handles.input.device.Start;
		start(handles.timer.input);
	else
		stop(handles.timer.input);
		handles.input.device.Close;
	end
%------------------------------------------------------------------------------%
function togSynthesize_Callback(hObject, eventdata, handles)
	bOn	= toggleOnOff(hObject);
%------------------------------------------------------------------------------%

%------------------------------------------------------------------------------%
function bOn = toggleOnOff(hObject)
	switch get(hObject,'String')
		case 'Off'
			bOn	= true;
			
			set(hObject,'String','On','BackgroundColor',[0 0.5 0],'ForegroundColor',[0 1 0]);
		case 'On'
			bOn	= false;
			
			set(hObject,'String','Off','BackgroundColor',[0.5 0 0],'ForegroundColor',[1 0 0]);
	end
%------------------------------------------------------------------------------%


%------------------------------------------------------------------------------%
function mnuFile_Callback(hObject, eventdata, handles)
%------------------------------------------------------------------------------%
function mnuDevices_Callback(hObject, eventdata, handles)
%------------------------------------------------------------------------------%
function mnuInput_Callback(hObject, eventdata, handles)
	Alexizer.InputDevice;
%------------------------------------------------------------------------------%
function mnuOutput_Callback(hObject, eventdata, handles)
%------------------------------------------------------------------------------%

%------------------------------------------------------------------------------%
function Alexizer_Input(varargin)
	global AlexizerInfo;
	
	[t,x]	= AlexizerInfo.input.device.Read;
	
	nMax	= t2k(30,AlexizerInfo.input.device.rate)-1;
	
	AlexizerInfo.input.t	= [AlexizerInfo.input.t; t];
	AlexizerInfo.input.x	= [AlexizerInfo.input.x; x];
	
	AlexizerInfo.input.t	= AlexizerInfo.input.t(max(1,end-nMax+1):end);
	AlexizerInfo.input.x	= AlexizerInfo.input.x(max(1,end-nMax+1):end);
	
	tMax	= max(30,t(end));
	tMin	= tMax-30;
	
	hp	= plot(AlexizerInfo.axData,AlexizerInfo.input.t,AlexizerInfo.input.x);
	set(hp,'Color',[0 1 0.5]);
	set(AlexizerInfo.axData,'Color',[0 0 0],'XLim',[tMin tMax],'XTickLabel','','YLim',[-1 1],'XColor',[1 1 1],'YColor',[1 1 1],'XGrid','on','XMinorGrid','on','YGrid','on','YMinorGrid','on');
	drawnow
%------------------------------------------------------------------------------%
