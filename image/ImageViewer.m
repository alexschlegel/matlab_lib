function varargout = ImageViewer(varargin)
% ImageViewer
% 
% Description:	image viewing GUI
% 
% Syntax:	ImageViewer(im,<options>)
% 
% In:
% 	im	- an image array or the path to an image file
%	<options>:
%		zoom:		(<best fit>) the zoom, as a percentage
%		position:	(<center>) the (T,L) of the image display center
% 
% Updated: 2012-07-09
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ImageViewer_OpeningFcn, ...
                   'gui_OutputFcn',  @ImageViewer_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1}) && ~FileExists(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


%------------------------------------------------------------------------------%
function ImageViewer_OpeningFcn(hObject, eventdata, handles, varargin)
	[im,handles.opt]	= ParseArgs(varargin,[],...
							'zoom'		, []	, ...
							'position'	, []	  ...
							);
	
	handles.im		= GetImage(im);
	handles.pos		= handles.opt.position;
	handles.zoom	= handles.opt.zoom;
	
	%set the figure position
		mp	= get(0,'MonitorPositions');
		p	= get(handles.figMain,'Position');
		pH	= get(handles.sldH,'Position');
		pV	= get(handles.sldV,'Position');
		sz	= size(handles.im);
		
		lF	= (mp(1,3) - p(3))/2;
		bF	= (mp(1,4) - p(4))/2;
		wF	= min(sz(2)+pV(3),mp(3));
		hF	= min(sz(1)+pH(4),mp(4));
		
		set(handles.figMain,'Position',[lF bF wF hF]);
	
	handles.output = hObject;
	
	guidata(hObject, handles);
	
	% UIWAIT makes ImageViewer wait for user response (see UIRESUME)
	% uiwait(handles.figMain);
%------------------------------------------------------------------------------%
function varargout = ImageViewer_OutputFcn(hObject, eventdata, handles) 
	varargout{1} = handles.output;
%------------------------------------------------------------------------------%

%------------------------------------------------------------------------------%
function figMain_ResizeFcn(hObject, eventdata, handles)
	%resize the elements
		p	= get(hObject,'Position');
		
		pH	= get(handles.sldH,'Position');
		pV	= get(handles.sldV,'Position');
		
		pH(3)	= p(3) - pV(3);
		pV(4)	= p(4) - pH(4);
		pV(1)	= p(3) - pV(3);
		
		set(handles.sldH,'Position',pH);
		set(handles.sldV,'Position',pV);
	%reshow the image
		handles = ShowImage(handles);
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%


%------------------------------------------------------------------------------%
function sldH_Callback(hObject, eventdata, handles)
	x	= get(handles.sldH,'Value');
	
	handles	= SetPosition(handles,handles.pos(1),x);
	handles	= ShowImage(handles);
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function sldV_Callback(hObject, eventdata, handles)
	y	= get(handles.sldV,'Value');
	mn	= get(handles.sldV,'Min');
	mx	= get(handles.sldV,'Max');
	
	handles	= SetPosition(handles,mn+mx-y,handles.pos(2));
	handles	= ShowImage(handles);
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%



%------------------------------------------------------------------------------%
function mnuZoom_Callback(hObject, eventdata, handles)
	z	= ask('New Zoom:','title','Image Viewer','default',handles.zoom);
	
	if ~isempty(z)
		handles	= SetZoom(handles,z);
		handles	= ShowImage(handles);
		
		guidata(hObject,handles);
	end
%------------------------------------------------------------------------------%
function mnuPosition_Callback(hObject, eventdata, handles)
	y	= ask('New Y:','title','Image Viewer','default',handles.pos(1));
	x	= ask('New X:','title','Image Viewer','default',handles.pos(2));
	
	if ~isempty(y) && ~isempty(x)
		handles	= SetPosition(handles,y,x);
		handles	= ShowImage(handles);
		
		guidata(hObject,handles);
	end
%------------------------------------------------------------------------------%
function mnuImage_Callback(hObject, eventdata, handles)
%------------------------------------------------------------------------------%


%------------------------------------------------------------------------------%
function sldH_CreateFcn(hObject, eventdata, handles)
	if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor',[.9 .9 .9]);
	end
%------------------------------------------------------------------------------%
function sldV_CreateFcn(hObject, eventdata, handles)
	if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor',[.9 .9 .9]);
	end
%------------------------------------------------------------------------------%

%------------------------------------------------------------------------------%
function im = GetImage(im)
	if ischar(im)
		im	= rgbRead(im);
	end
	
	if ndims(im)==2
		im	= repmat(im,[1 1 3]);
	end
	
	im	= im2double(im);
%------------------------------------------------------------------------------%
function handles = SetZoom(handles,z)
	%set the zoom
		p	= get(handles.figMain,'Position');
		pH	= get(handles.sldH,'Position');
		pV	= get(handles.sldV,'Position');
		sz	= size(handles.im);
		
		hAMax	= p(4) - pH(4);
		wAMax	= p(3) - pV(3);
		
		hI	= sz(1);
		wI	= sz(2);
		
		zMin	= 100*min(hAMax/hI,wAMax/wI);
		
		handles.zoom	= max(zMin,z);
		
	%set the sliders
		hIShow	= min(hAMax./(handles.zoom/100),hI);
		wIShow	= min(wAMax./(handles.zoom/100),wI);
		
		if hAMax/wAMax > hIShow/wIShow
			hA	= wAMax*(hIShow/wIShow);
			wA	= wAMax;
		else
			hA	= hAMax;
			wA	= hAMax*(wIShow/hIShow);
		end
		
		hAZ	= hA/(handles.zoom/100);
		wAZ	= wA/(handles.zoom/100);
		
		%vertical
			tCMin	= hAZ/2;
			tCMax	= hI - tCMin;
			
			handles.pos(1)	= min(tCMax,max(tCMin,handles.pos(1)));
			
			if round(tCMin)~=round(tCMax) && tCMin<tCMax
				sldS	= 1/(tCMax-tCMin);
				sldB	= min(1,100/(tCMax-tCMin));
				
				set(handles.sldV,'Visible','on','Min',tCMin,'Max',tCMax,'SliderStep',[sldS sldB],'Value',tCMin+tCMax-handles.pos(1));
			else
				set(handles.sldV,'Visible','off');
			end
		%horizontal
			lCMin	= wAZ/2;
			lCMax	= wI - lCMin;
			
			handles.pos(2)	= min(lCMax,max(lCMin,handles.pos(2)));
			
			if round(lCMin)~=round(lCMax) && lCMin<lCMax
				sldS	= 1/(lCMax-lCMin);
				sldB	= min(1,100/(lCMax-lCMin));
				
				set(handles.sldH,'Visible','on','Min',lCMin,'Max',lCMax,'SliderStep',[sldS sldB],'Value',handles.pos(2));
			else
				set(handles.sldH,'Visible','off');
			end
%------------------------------------------------------------------------------%
function handles = SetPosition(handles,y,x)
	%set the position
		p	= get(handles.figMain,'Position');
		pH	= get(handles.sldH,'Position');
		pV	= get(handles.sldV,'Position');
		sz	= size(handles.im);
		
		hAMax	= p(4) - pH(4);
		wAMax	= p(3) - pV(3);
		
		hI	= sz(1);
		wI	= sz(2);
		
		hIShow	= min(hAMax./(handles.zoom/100),hI);
		wIShow	= min(wAMax./(handles.zoom/100),wI);
		
		if hAMax/wAMax > hIShow/wIShow
			hA	= wAMax*(hIShow/wIShow);
			wA	= wAMax;
		else
			hA	= hAMax;
			wA	= hAMax*(wIShow/hIShow);
		end
		
		hAZ	= hA/(handles.zoom/100);
		wAZ	= wA/(handles.zoom/100);
		
		tCMin	= hAZ/2;
		tCMax	= hI - tCMin;
		
		lCMin	= wAZ/2;
		lCMax	= wI - lCMin;
		
		handles.pos	= [max(tCMin,min(tCMax,y)) max(lCMin,min(lCMax,x))];
	%set the sliders
		set(handles.sldV,'Value',tCMin+tCMax-handles.pos(1));
		set(handles.sldH,'Value',handles.pos(2));
%------------------------------------------------------------------------------%
function handles = ShowImage(handles);
	if isempty(handles.im)
		cla(handles.axImage);
		return;
	end
	
	%get the sizes
		p	= get(handles.figMain,'Position');
		pH	= get(handles.sldH,'Position');
		pV	= get(handles.sldV,'Position');
		sz	= size(handles.im);
		
		hAMax	= p(4) - pH(4);
		wAMax	= p(3) - pV(3);
		
		hI	= sz(1);
		wI	= sz(2);
		
		if isempty(handles.pos)
			handles.pos	= [hI wI]/2;
		end
		if isempty(handles.zoom)
			handles	= SetZoom(handles,100*min(hAMax/hI,wAMax/wI));
		end
	%current zoom
		handles	= SetZoom(handles,handles.zoom);
		
		hIZ	= hI*handles.zoom/100;
		wIZ	= wI*handles.zoom/100;
		
		hIShow	= min(hAMax./(handles.zoom/100),hI);
		wIShow	= min(wAMax./(handles.zoom/100),wI);
	%set the axes size
		if hAMax/wAMax > hIShow/wIShow
			hA	= wAMax*(hIShow/wIShow);
			wA	= wAMax;
		else
			hA	= hAMax;
			wA	= hAMax*(wIShow/hIShow);
		end
		
		hAZ	= hA/(handles.zoom/100);
		wAZ	= wA/(handles.zoom/100);
		
		lA	= (wAMax - wA)/2;
		bA	= (hAMax - hA)/2;
		
		set(handles.axImage,'Position',[lA bA+pH(4) wA hA]);
	%current position
		handles	= SetPosition(handles,handles.pos(1),handles.pos(2));
	%show the image
		H	= round(hAZ);
		W	= round(wAZ);
		T	= round(handles.pos(1) - hAZ/2);
		L	= round(handles.pos(2) - wAZ/2);
		
		imShow	= handles.im(T + (1:H),L + (1:W),:);
		
		image(imShow,'parent',handles.axImage);
		
		set(handles.axImage,'XTick',[]);
		set(handles.axImage,'YTick',[]);
%------------------------------------------------------------------------------%
