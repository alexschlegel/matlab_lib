function varargout = PaletteConstructor(varargin)
% PaletteConstructor
% 
% Description:	GUI for constructing a palette
% 
% Syntax:	p = PaletteConstructor([p]) OR
%			p = PaletteConstructor([strPathPalette])
% 
% In:
% 	[p]					- a palette
%	[strPathPalette]	- path to a palette file
% 
% Out:
% 	p	- the constructed palette
% 
% Updated:	2009-01-06
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
	gui_Singleton	= 1;
	gui_State = struct('gui_Name',       mfilename, ...
	                   'gui_Singleton',  gui_Singleton, ...
	                   'gui_OpeningFcn', @PaletteConstructor_OpeningFcn, ...
	                   'gui_OutputFcn',  @PaletteConstructor_OutputFcn, ...
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
function PaletteConstructor_OpeningFcn(hObject, eventdata, handles, varargin)
	handles.output = hObject;
	
	%load the palette***
		handles.palette	= rand(64,3);
	
	%get size info and other parameters
		handles	= GetParameters(handles);
		
	%refresh the GUI
		handles	= RefreshGUI(handles,true);
	
	% Update handles structure
		guidata(hObject, handles);
	
	% UIWAIT makes PaletteConstructor wait for user response (see UIRESUME)
		uiwait(handles.figMain);
%------------------------------------------------------------------------------%
function varargout = PaletteConstructor_OutputFcn(hObject, eventdata, handles) 
	varargout{1} = handles.output;
	
	delete(hObject);
%------------------------------------------------------------------------------%


%------------------------------------------------------------------------------%
function CloseRequest(hObject,eventdata,handles)
	uiresume(hObject);
%------------------------------------------------------------------------------%


%------------------------------------------------------------------------------%
function mnuFile_Callback(hObject, eventdata, handles)
%------------------------------------------------------------------------------%
function mnuNew_Callback(hObject, eventdata, handles)
%------------------------------------------------------------------------------%
function mnuOpen_Callback(hObject, eventdata, handles)
%------------------------------------------------------------------------------%
function mnuLoadTestImage_Callback(hObject, eventdata, handles)
%------------------------------------------------------------------------------%
function mnuSave_Callback(hObject, eventdata, handles)
%------------------------------------------------------------------------------%
function mnuSaveAs_Callback(hObject, eventdata, handles)
%------------------------------------------------------------------------------%
function mnuExit_Callback(hObject, eventdata, handles)
%------------------------------------------------------------------------------%
function edtPalette_Callback(hObject, eventdata, handles)
	try
		handles.palette	= im2double(uint8(str2num(get(handles.edtPalette,'String'))));
	catch
	end
	
	handles	= RefreshGUI(handles);
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function sldGradient_Callback(hObject, eventdata, handles)
	handles	= RefreshGradient(handles);
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%


%------------------------------------------------------------------------------%
function handles = GetParameters(handles)
	%gradient parameters
		handles.gradient.nPer	= 8;
	
	%figMain
		p						= get(handles.figMain,'Position');
		handles.w.figMain		= p(3);
		handles.h.figMain		= p(4);
	
	%testimage
		p						= get(handles.axTestImage,'Position');
		handles.w.axTestImage	= p(3)*handles.w.figMain;
		handles.h.axTestImage	= p(4)*handles.h.figMain;
	
	%gradient
		p						= get(handles.axGradient,'Position');
		handles.w.axGradient	= p(3)*handles.w.figMain;
		handles.h.axGradient	= p(3)*handles.h.figMain;
		
%------------------------------------------------------------------------------%
function handles = RefreshGUI(handles,varargin)
	handles	= RefreshGradient(handles);
	handles	= RefreshTestImage(handles);
	handles	= RefreshPalette(handles);
%------------------------------------------------------------------------------%
	function handles = RefreshGradient(handles)
		%get the gradient
			[colG1,colG2,t]	= Palette2Gradient(handles.palette);
			nGrad			= numel(t);
		%set the gradient slider
			kStart	= get(handles.sldGradient,'Value');
			kMax	= max(1,nGrad-handles.gradient.nPer+1);
			
			if kStart>kMax
				kStart	= kMax;
				set(handles.sldGradient,'Value',kMax);
			end
			
			if kMax==1
				set(handles.sldGradient,'Enable','off');
			else
				set(handles.sldGradient,'Max',kMax);
				
				sSmall	= 1/(kMax-1);
				sBig	= handles.gradient.nPer/(kMax-1);
				
				set(handles.sldGradient,'SliderStep',[sSmall sBig]);
				set(handles.sldGradient,'Enable','on');
			end
		%get the section of the image to display
			kDisplay	= kStart:min(nGrad,kStart+handles.gradient.nPer-1);
			colG1		= colG1(kDisplay,:);
			colG2		= colG2(kDisplay,:);
			t			= t(kDisplay);
		%get the gradient image
			im	= GetGradientImage(colG1,colG2,t,handles.h.axGradient,handles.w.axGradient);
			if isempty(GetFieldPath(handles,'hIm','axGradient'))
				handles.hIm.axGradient	= image(im,'Parent',handles.axGradient);
				set(handles.axGradient,'XTick',[]);
				set(handles.axGradient,'YTick',[]);
			else
				set(handles.hIm.axGradient,'CData',im);
			end
%------------------------------------------------------------------------------%
		function im = GetGradientImage(colG1,colG2,t,h,w)
			yOffset	= 20;
			xOffset	= 20;
			
			hCol	= 0.1*h;
			hGrad	= h-hCol*2-yOffset;
			
			yMinCol1	= 1;
			yMaxCol1	= yMinCol1+hCol-1;
			yMinG		= yMaxCol1+1;
			yMaxG		= yMinG+hGrad-1;
			yMinCol2	= yMaxG+1;
			yMaxCol2	= yMinCol2+hCol-1;
			
			nGrad	= numel(t);
			
			im	= ones(h,w,3);
			
			xPer	= round((w-xOffset)/nGrad);
			for k=1:nGrad
				xMin	= xOffset+(k-1)*xPer+1;
				xMax	= xMin+xPer-1;
				
				%col1
					im(yMinCol1:yMaxCol1,xMin:xMax,:)	= repmat(reshape(colG1(k,:),1,1,3),[hCol xPer]);
				%border col1
					im([yMinCol1 yMaxCol1],xMin:xMax,:)	= 0;
					im(yMinCol1:yMaxCol1,[xMin xMax],:)	= 0;
				%col2
					im(yMinCol2:yMaxCol2,xMin:xMax,:)	= repmat(reshape(colG2(k,:),1,1,3),[hCol xPer]);
				%border col2
					im([yMinCol2 yMaxCol2],xMin:xMax,:)	= 0;
					im(yMinCol2:yMaxCol2,[xMin xMax],:)	= 0;
				%gradient
					error('20110307: Gradient2Palette is old. Fix this line.');
					pal		= Gradient2Palette(colG1(k,:),colG2(k,:),t{k});
					pal		= imresize(pal,[hGrad 3],'bicubic');
					nCol	= size(pal,1);
					imGrad	= repmat(reshape(pal,nCol,1,3),[1 xPer 1]);
					
					im(yMinG:yMaxG,xMin:xMax,:)	= imGrad;
				%border gradient
					im([yMinG yMaxG],xMin:xMax,:)	= 0;
					im(yMinG:yMaxG,[xMin xMax],:)	= 0;
			end
			
			im(im<0)	= 0;
			im(im>1)	= 1;
%------------------------------------------------------------------------------%
	function handles = RefreshTestImage(handles)
		im	= TestPattern(handles.w.axTestImage,handles.h.axTestImage,handles.palette);
		if isempty(GetFieldPath(handles,'hIm','axTestImage'))
			handles.hIm.axTestImage	= image(im,'Parent',handles.axTestImage);
			set(handles.axTestImage,'XTick',[]);
			set(handles.axTestImage,'YTick',[]);
		else
			set(handles.hIm.axTestImage,'CData',im);
		end
%------------------------------------------------------------------------------%
	function handles = RefreshPalette(handles)
		set(handles.edtPalette,'String',num2str(im2uint8(handles.palette)));
%------------------------------------------------------------------------------%


%------------------------------------------------------------------------------%
function sldGradient_CreateFcn(hObject, eventdata, handles)
	if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor',[.9 .9 .9]);
	end
%------------------------------------------------------------------------------%
function edtPalette_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end
%------------------------------------------------------------------------------%
