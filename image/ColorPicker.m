function varargout = ColorPicker(varargin)
% ColorPicker
% 
% Description:	choose an RGB color from a color palette
% 
% Syntax:	c = ColorPicker([c]=<black>)
% 
% In:
% 	[c]	- the color to select initially in the GUI.  either uint8 0->255 or
%		  double 0->1
% 
% Out:
% 	c	- the 1x3 color selected by the user, or false if the user canceled
% 
% Updated:	2008-12-17
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ColorPicker_OpeningFcn, ...
                   'gui_OutputFcn',  @ColorPicker_OutputFcn, ...
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
function ColorPicker_OpeningFcn(hObject, eventdata, handles, varargin)
	handles.c		= ParseArgs(varargin,[0.5 0.5 0.5]);
	handles.c		= reshape(handles.c,1,[]);
	
	%convert to a double if necessary
		[handles.c,handles.bConverted]	= im2double(handles.c);
	
	%we'll deal in hsl space
		handles.c	= rgb2hsl(handles.c);
	
	%change the tab order
		h		= [handles.edtLuminance handles.edtSaturation handles.edtHue handles.edtBlue handles.edtGreen handles.edtRed];
		uistack(h,'top');
	
	handles.output	= false;
	
	handles	= InitColorBoxes(handles);
	handles	= UpdateEdits(handles);
	handles	= UpdateColors(handles);
	
	%set clicking callbacks
		set(handles.figMain,'WindowButtonDownFcn','ColorPicker(''cp_buttondown'',gcbo,[],guidata(gcbo));');
		set(handles.figMain,'WindowButtonUpFcn','ColorPicker(''cp_buttonup'',gcbo,[],guidata(gcbo));');
		set(handles.figMain,'WindowButtonMotionFcn','ColorPicker(''cp_mousemove'',gcbo,[],guidata(gcbo));');
	
	set(handles.figMain,'name','Choose a Color');
	
	% Update handles structure
		guidata(hObject, handles);
	
	% UIWAIT makes ColorPicker wait for user response (see UIRESUME)
		uiwait(handles.figMain);
%------------------------------------------------------------------------------%
function c = ColorPicker_OutputFcn(hObject, eventdata, handles) 
	c	= handles.output;
	delete(hObject);
%------------------------------------------------------------------------------%


%------------------------------------------------------------------------------%
function cp_closerequest(hObject,eventdata,handles)
	uiresume(hObject);
%------------------------------------------------------------------------------%
function cp_editchange(hObject,eventdata,handles)
	handles	= UpdateEdits(handles,true);
	handles	= UpdateColors(handles);
	
	guidata(hObject, handles);
%------------------------------------------------------------------------------%
function cp_mousemove(hObject,eventdata,handles)
	if GetFieldPath(handles,'buttonState')
		handles	= ProcessMouse(handles);
	end
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function cp_buttondown(hObject,eventdata,handles)
	handles.buttonState	= true;
	
	handles	= ProcessMouse(handles);
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function cp_buttonup(hObject,eventdata,handles)
	handles.buttonState	= false;
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%

%------------------------------------------------------------------------------%
function handles = ProcessMouse(handles)
	%check saturation
		h		= handles.h.saturation;
		w		= handles.w.saturation;
		mPos	= get(handles.axSaturation,'CurrentPoint');
		t		= mPos(1,2);
		l		= mPos(1,1);
		
		tMin	= -8;
		tMax	= h+8;
		lMin	= -8;
		lMax	= w+8;
		
		bSaturation	= t>=tMin && t<=tMax && l>=lMin && l<=lMax;
		if bSaturation
			hNew		= min(1,max(0,(l-1)/(w-1)));
			sNew		= min(1,max(0,(h-t)/(h-1)));
			handles.c	= [hNew sNew handles.c(3)];
		end
		
	%check brightness
		if ~bSaturation
			h		= handles.h.brightness;
			w		= handles.w.brightness;
			mPos	= get(handles.axBrightness,'CurrentPoint');
			t		= mPos(1,2);
			l		= mPos(1,1);
			
			tMin	= -8;
			tMax	= h+8;
			lMin	= 0;
			lMax	= w+8;
			bBrightness	= t>=tMin && t<=tMax && l>=lMin && l<=lMax;
			if bBrightness
				lNew		= min(1,max(0,(h-t)/(h-1)));
				handles.c	= [handles.c(1:2) lNew];
			end
		end
	
	if bSaturation || bBrightness
		handles	= UpdateEdits(handles);
		handles	= UpdateColors(handles);
	end
%------------------------------------------------------------------------------%


%------------------------------------------------------------------------------%
function butOK_Callback(hObject, eventdata, handles)
	%convert back to rgb space and uint8 if necessary
		handles.output	= hsl2rgb(handles.c);
		if handles.bConverted
			handles.output	= im2uint8(handles.c);
		end
	
	guidata(hObject,handles);
	
	cp_closerequest(handles.figMain,eventdata,handles);
%------------------------------------------------------------------------------%
function butCancel_Callback(hObject, eventdata, handles)
	cp_closerequest(handles.figMain,eventdata,handles);
%------------------------------------------------------------------------------%


%------------------------------------------------------------------------------%
function edtBlue_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end
%------------------------------------------------------------------------------%
function edtGreen_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end
%------------------------------------------------------------------------------%
function edtRed_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end
%------------------------------------------------------------------------------%
function edtLuminance_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end
%------------------------------------------------------------------------------%
function edtSaturation_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end
%------------------------------------------------------------------------------%
function edtHue_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end
%------------------------------------------------------------------------------%


%------------------------------------------------------------------------------%
function handles = UpdateEdits(handles,varargin)
% UpdateEdits(handles,[bUseEditValue]=false);
%update edits based on user input
	bUseEditValue	= ParseArgs(varargin,false);
	
	h		= [handles.edtRed handles.edtGreen handles.edtBlue handles.edtHue handles.edtSaturation handles.edtLuminance];
	edtVal	= zeros(1,6,'uint8');
	
	%get the new color
		if bUseEditValue
			for k=1:6
				edtVal(k)	= FixEdit(h(k));
			end
			
			cRGB	= rgb2hsl(im2double(edtVal(1:3)));
			cHSL	= im2double(edtVal(4:6));
			
			if ~isequal(cRGB,handles.c)
				handles.c	= cRGB;
			elseif ~isequal(cHSL,handles.c)
				handles.c	= cHSL;
			end
		end
		
	%update the edits with the new color
		edtVal(1:3)	= round(255*hsl2rgb(handles.c));
		edtVal(4:6)	= round(255*handles.c);
		for k=1:6
			set(h(k),'String',num2str(edtVal(k)));
		end
%------------------------------------------------------------------------------%
function val = FixEdit(h)
	strVal	= get(h,'String');
	
	%delete non-number characters
		strVal	= strVal(strVal>47 & strVal<58);
	%make sure we're within the 0->255 bounds
		val	= str2num(strVal);
		val	= min(255,max(0,val));
%------------------------------------------------------------------------------%
function handles = UpdateColors(handles,varargin)
% UpdateColors(handles,[bUseColorValue]=false);
%update color boxes based on user input
	bUseColorValue	= ParseArgs(varargin,false);
	
	DrawColorBoxes(handles);
%------------------------------------------------------------------------------%


%------------------------------------------------------------------------------%
function handles = DrawColorBoxes(handles)
	%saturation box
		im	= AddSaturationCrossHair(handles.im.saturation,handles);
		set(handles.hIm.saturation,'CData',im);
		
	%brightness box
		im	= GetBrightnessBox(handles.c,handles.h.brightness,handles.w.brightness);
		im	= AddBrightnessCrossHair(im,handles);
		set(handles.hIm.brightness,'CData',im);
		
	%color box
		c	= hsl2rgb(handles.c);
		im	= repmat(reshape(c,1,1,3),[handles.h.color handles.w.color 1]);
		set(handles.hIm.color,'CData',im);
		
%------------------------------------------------------------------------------%
function im = AddBrightnessCrossHair(im,handles)
	t	= GetBrightnessPosition(handles);
	
	hsl			= rgb2hsl(im(t,:,:));
	hsl(:,:,1)	= mod(hsl(:,1)+0.5,1);
	hsl(:,:,2)	= 1;
	hsl(:,:,3)	= sqrt((1 - hsl(:,:,3))/2);
	
	im(t,:,:)	= hsl2rgb(hsl);
%------------------------------------------------------------------------------%
function im = AddSaturationCrossHair(im,handles)
	[t,l]	= GetSaturationPosition(handles);
	
	h	= handles.h.saturation;
	w	= handles.w.saturation;
	
	n		= 8;
	nOff	= 2;
	kT		= [repmat(t,[1 n]) 	(1:n)+(t-n-nOff)	repmat(t,[1 n]) (1:n)+(t+nOff)]';
	kL		= [(1:n)+(l-n-nOff)	repmat(l,[1 n])		(1:n)+(l+nOff)	repmat(l,[1 n])]';
	
	bBadT	= kT<1 | kT>h;
	bBadL	= kL<1 | kL>w;
	bKeep	= ~bBadT & ~bBadL;
	kT		= kT(bKeep);
	kL		= kL(bKeep);
	kRGB	= ones(size(kL));
	
	kR	= sub2ind([h w 3],kT,kL,kRGB);
	kG	= sub2ind([h w 3],kT,kL,2*kRGB);
	kB	= sub2ind([h w 3],kT,kL,3*kRGB);
	
	hsl			= rgb2hsl([im(kR) im(kG) im(kB)]);
	hsl(:,1)	= mod(hsl(:,1)+0.5,1);
	hsl(:,2)	= 1;
	hsl(:,3)	= 0.5;
	rgb			= hsl2rgb(hsl);
	
	im(kR)	= rgb(:,1);
	im(kG)	= rgb(:,2);
	im(kB)	= rgb(:,3);
%------------------------------------------------------------------------------%
function handles = InitColorBoxes(handles)
	%saturation box
		p	= get(handles.axSaturation,'Position');
		handles.h.saturation	= p(4);
		handles.w.saturation	= p(3);
		
		handles.im.saturation	= GetSaturationBox(handles.h.saturation,handles.w.saturation);
		handles.hIm.saturation	= image(handles.im.saturation,'Parent',handles.axSaturation);
		
		set(handles.axSaturation,'XTick',[]);
		set(handles.axSaturation,'YTick',[]);
		
	%brightness box
		p	= get(handles.axBrightness,'Position');
		handles.h.brightness	= p(4);
		handles.w.brightness	= p(3);
		
		handles.im.brightness	= GetBrightnessBox(handles.c,handles.h.brightness,handles.w.brightness);
		handles.hIm.brightness	= image(handles.im.brightness,'Parent',handles.axBrightness);
		
		set(handles.axBrightness,'XTick',[]);
		set(handles.axBrightness,'YTick',[]);
		
	%color box
		p	= get(handles.axColor,'Position');
		handles.h.color			= p(4);
		handles.w.color			= p(3);
		
		handles.im.color		= zeros(handles.h.color,handles.w.color,3);
		handles.hIm.color		= image(handles.im.color,'Parent',handles.axColor);
		
		set(handles.axColor,'XTick',[]);
		set(handles.axColor,'YTick',[]);
%------------------------------------------------------------------------------%
function im = GetSaturationBox(h,w)
	%hue
		imH	= repmat(GetInterval(0,1,w),[h 1]);
	%saturation
		imS	= repmat(GetInterval(1,0,h)',[1 w]);
	%luminance
		imL	= repmat(0.5,[h w]);
	
	im	= hsl2rgb(cat(3,imH,imS,imL));
	
%------------------------------------------------------------------------------%
function im = GetBrightnessBox(c,h,w)
	imH	= repmat(c(1),[h w]);
	imS	= repmat(c(2),[h w]);
	imL	= repmat(GetInterval(1,0,h)',[1 w]);
	
	im	= hsl2rgb(cat(3,imH,imS,imL));
%------------------------------------------------------------------------------%

%------------------------------------------------------------------------------%
function t = GetBrightnessPosition(handles)
	h	= handles.h.brightness;
	
	t	= round((h-1)*(1-handles.c(3)))+1;
%------------------------------------------------------------------------------%
function [t,l] = GetSaturationPosition(handles)
	h	= handles.h.saturation;
	w	= handles.w.saturation;
	
	t	= round((h-1)*(1-handles.c(2)))+1;
	l	= round((w-1)*handles.c(1))+1;
%------------------------------------------------------------------------------%
