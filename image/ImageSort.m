function [cImSort,kSort] = ImageSort(cIm,varargin)
% ImageSort
% 
% Description:	manually sort images via a GUI
% 
% Syntax:	[cIm,kSort] = ImageSort(cIm,<options>)
% 
% In:
% 	cIm	- a cell of images
%	<options>:
%		s:	(300) fit the images in a box s pixels square
% 
% Out:
%	cIm		- the sorted images
% 	kSort	- the sorting indices
% 
% Updated: 2012-04-28
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		's'	, 300	  ...
		);

nIm		= numel(cIm);
kSort	= (1:nIm)';

%resize the images
	sIm		= cellfun(@(im) [size(im,1) size(im,2)],cIm,'UniformOutput',false);
	sImR	= cellfun(@(s) opt.s*s/max(s),sIm,'UniformOutput',false);
	
	cImR	= cellfun(@imresize,cIm,sImR,'UniformOutput',false);
	
	cImSort		= cIm(kSort);
	cImRSort	= cImR(kSort);
%get some screen parameters
	sScreen	= get(0,'MonitorPositions');
	sScreen	= sScreen(3:4);
	
	nImagePer	= floor(sScreen(1)/opt.s);
%open the figure
	sExtra	= 50;
	sFigure	= opt.s + sExtra;
	
	h.hF	= figure;
	set(h.hF,'Position',[0 (sScreen(2)-sFigure)/2 sScreen(1) sFigure],'Name',['Image Sorter (' num2str(nIm) ' images)'],'NumberTitle','off');
%draw the controls
	hSmall	= 21;
	wButton	= 50;
	
	h.hA		= arrayfun(@(k) axes('Units','pixels','Position',[(k-1)*opt.s sExtra opt.s opt.s]),(1:nImagePer)');
	h.hSlider	= uicontrol(h.hF,'Tag','slider','Style','slider','Units','pixels','Position',[0 0 sScreen(1) hSmall],'SliderStep',[1/nIm (nImagePer-1)/nIm],'Callback',@Scroll);
	
	for kIm=1:nImagePer
		xMid	= (kIm-1/2).*opt.s;
		xLeft	= xMid - 1.5*wButton;
		xRight	= xMid - 0.5*wButton;
		xText	= xMid + 0.5*wButton;
		
		h.hLeft(kIm)	= uicontrol(h.hF,'Tag',['left' num2str(kIm)],'Style','pushbutton','Units','pixels','Position',[xLeft hSmall wButton hSmall],'String','<','Callback',@MoveLeft);
		h.hRight(kIm)	= uicontrol(h.hF,'Tag',['right' num2str(kIm)],'Style','pushbutton','Units','pixels','Position',[xRight hSmall wButton hSmall],'String','>','Callback',@MoveRight);
		h.hText(kIm)	= uicontrol(h.hF,'Tag',['edit' num2str(kIm)],'Style','edit','Units','pixels','Position',[xText hSmall wButton hSmall],'String','','Callback',@MoveByText);
	end
%show the images
	kPosition	= 0;
	SetPosition(round(nImagePer/2));
%wait
	uiwait(h.hF);

%------------------------------------------------------------------------------%
function SetPosition(kPos)
%set the center image to be kPosition
	figure(h.hF);
	
	kPosition	= kPos;
	
	kIm	= (0:nImagePer-1) + kPosition-floor(nImagePer/2);
	
	for k=1:nImagePer
		if kIm(k)>=1 && kIm(k)<=nIm
			imshow(cImRSort{kIm(k)},'parent',h.hA(k));
		else
			imshow(zeros(size(cImR{1})),'parent',h.hA(k));
		end
		
		set(h.hText(k),'String',kIm(k));
	end
	
	set(h.hSlider,'Value',MapValue(kPosition,1,nIm,0,1));
end
%------------------------------------------------------------------------------%
function MoveLeft(hObject,handles)
	kPosRel	= str2num(regexp(get(hObject,'Tag'),'\d+$','match','once'));
	kPosAbs	= kPosition - floor(nImagePer/2) + kPosRel - 1;
	
	if kPosAbs>1 && kPosAbs<=nIm
		kSort	= kSort([1:kPosAbs-2 kPosAbs kPosAbs-1 kPosAbs+1:end]);
		
		cImSort		= cIm(kSort);
		cImRSort	= cImR(kSort);
		
		SetPosition(kPosition);
	end
end
%------------------------------------------------------------------------------%
function MoveRight(hObject,handles)
	kPosRel	= str2num(regexp(get(hObject,'Tag'),'\d+$','match','once'));
	kPosAbs	= kPosition - floor(nImagePer/2) + kPosRel - 1;
	
	if kPosAbs<nIm && kPosAbs>=1
		kSort	= kSort([1:kPosAbs-1 kPosAbs+1 kPosAbs kPosAbs+2:end]);
		
		cImSort		= cIm(kSort);
		cImRSort	= cImR(kSort);
		
		SetPosition(kPosition);
	end
end
%------------------------------------------------------------------------------%
function MoveByText(hObject,handles)
	kPosRel	= str2num(regexp(get(hObject,'Tag'),'\d+$','match','once'));
	kPosAbs	= kPosition - floor(nImagePer/2) + kPosRel - 1;
	
	try
		kPosNew	= str2num(get(hObject,'String'));
	catch me
		status('Invalid entry');
		return;
	end
	
	if kPosAbs<=nIm && kPosAbs>=1 && kPosNew>=1 && kPosNew<=nIm
		if kPosAbs<kPosNew
			offset	= 0;
			kSort	= kSort([1:kPosAbs-1 kPosAbs+1:kPosNew kPosAbs kPosNew+1:end]);
		else
			offset	= 1;
			kSort	= kSort([1:kPosNew-1 kPosAbs kPosNew:kPosAbs-1 kPosAbs+1:end]);
		end
		
		cImSort		= cIm(kSort);
		cImRSort	= cImR(kSort);
		
		SetPosition(kPosition+offset);
	end
end
%------------------------------------------------------------------------------%
function Scroll(hObject,handles)
	SetPosition(round(MapValue(get(hObject,'Value'),0,1,1,nIm)));
end
%------------------------------------------------------------------------------%

end
