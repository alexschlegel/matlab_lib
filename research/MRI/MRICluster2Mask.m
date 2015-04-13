function varargout = MRICluster2Mask(varargin)
% MRICluster2Mask
% 
% Description:	make a NIfTI mask file from a cluster in a stat image
% 
% Syntax:	strPathMask = MRICluster2Mask(strPathStat,[strPathAnat]=<MNI 2mm brain>,[strPathMask]=<auto>)
% 
% In:
% 	strPathStat	- the path to the statistic NIfTI file
%	strPathAnat	- the path to the anatomical underlay NIfTI file
%	strPathMask	- the output mask path
% 
% Out:
% 	strPathMask	- the output mask path
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
	gui_Singleton = 1;
	gui_State = struct('gui_Name',       mfilename, ...
					   'gui_Singleton',  gui_Singleton, ...
					   'gui_OpeningFcn', @MRICluster2Mask_OpeningFcn, ...
					   'gui_OutputFcn',  @MRICluster2Mask_OutputFcn, ...
					   'gui_LayoutFcn',  [] , ...
					   'gui_Callback',   []);
	if nargin && ischar(varargin{1}) && ~isempty(varargin{1}) && ~FileExists(varargin{1})
		gui_State.gui_Callback = str2func(varargin{1});
	end
	
	if nargout
		[varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
	else
		gui_mainfcn(gui_State, varargin{:});
	end


%------------------------------------------------------------------------------%
function MRICluster2Mask_OpeningFcn(hObject, eventdata, handles, varargin)
	[strPathStat,strPathAnat,strPathMask]	= ParseArgs(varargin,[],FSLPathMNIAnatomical('type','MNI152_T1_2mm_brain'),[]);
	strPathMask								= unless(strPathMask,PathAddSuffix(strPathStat,'-mask','favor','nii.gz'));
	
	handles.clickmode	= 'replace';
	handles.movemode	= 'none';
	handles.select		= dealstruct('yStart','xStart','yEnd','xEnd',[]);
	
	[handles.txtPosition,handles.txtDirLeft,handles.txtDirRight,handles.txtDirTop,handles.txtDirBottom]	= deal([]);
	
	handles.dim				= dealstruct('y','x','slice','sagittal','coronal','axial',[]);
	handles.pos				= dealstruct('y','x','slice','dim1','dim2','dim3',1);
	handles.dir				= dealstruct('y','x','slice','dim1','dim2','dim3',[]);
	handles.size			= dealstruct('y','x','slice','dim1','dim2','dim3',[]);
	handles.thresholdType	= [];
	handles.threshold		= [];
	handles.plane			= [];
	
	handles.selected	= [];
	
	
	%add the axes that will accept user clicks
		handles.axClick	= axes;
		linkaxes([handles.axImage handles.axClick]);
		
		set(handles.axClick,'Color','none');
		set(handles.axClick,'Units','pixels');
		set(handles.axClick,'Position',get(handles.axImage,'Position'));
		set(handles.axClick,'xTick',[]);
		set(handles.axClick,'yTick',[]);
		hold(handles.axClick,'on');
	
		set(handles.axClick,'ButtonDownFcn','MRICluster2Mask(''ImageDown'',gcbo,[],guidata(gcbo));');
	%set the LUTs
		lutAnat	= [0 0 0; 1 1 1];
		lutStat	= [1 0 0; 1 1 0];
		lutMask	= [0 0.8 0; 0 1 1];
		
		handles	= SetLUT(handles,lutAnat,lutStat,lutMask,false);
	%set the files
		handles	= SetAnat(handles,strPathAnat,false);
		handles	= SetStat(handles,strPathStat,false);
		handles	= SetMask(handles,strPathMask);
	%set the selection
		handles	= ClearSelection(handles,false);
	%set the threshold
		handles	= SetThreshold(handles,'>',0,false);
	%set the plane
		handles	= SetPlane(handles,'axial',false);
	%set the position
		handles	= SetPositionAbs(handles,-1,-1,-1,false);
	%draw!
		handles	= Draw(handles);
	
	guidata(hObject, handles);
	uiwait(handles.figMain);
%------------------------------------------------------------------------------%
function varargout = MRICluster2Mask_OutputFcn(hObject, eventdata, handles)
	if ~isempty(handles)
		varargout{1}	= handles.strPathMask;
	else
		varargout{1}	= '';
	end
%------------------------------------------------------------------------------%
%*------*------*------*------*------*------*------*------*------*------*------*%

%*------*------*------*------*------*------*------*------*------*------*------*%
%------------------------------------------------------------------------------%
function popPlane_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns popPlane contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popPlane
	plane	= switch2(get(hObject,'Value'),...
				1	, 'axial'		, ...
				2	, 'sagittal'	, ...
				3	, 'coronal'		  ...
				);
	
	handles	= SetPlane(handles,plane);
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function popThreshold_Callback(hObject, eventdata, handles)
	strType	= switch2(get(hObject,'Value'),...
				1	, '>'	, ...
				2	, '>='	, ...
				3	, '='	, ...
				4	, '<='	, ...
				5	, '<'	  ...
				);
	
	handles = SetThreshold(handles,strType,[]);
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function edtThreshold_Callback(hObject, eventdata, handles)
	thresh	= str2num(get(hObject,'String'));
	
	handles = SetThreshold(handles,[],thresh);
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function butOK_Callback(hObject, eventdata, handles)
	if ~SaveMask(handles)
		handles.strPathMask	= '';
		guidata(hObject,handles);
	end
	
	uiresume(handles.figMain);
	close(handles.figMain);
%------------------------------------------------------------------------------%
function butSave_Callback(hObject, eventdata, handles)
	SaveMask(handles);
%------------------------------------------------------------------------------%
function butUndo_Callback(hObject, eventdata, handles)
	handles	= RevertSelected(handles);
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function butCancel_Callback(hObject, eventdata, handles)
	handles.strPathMask	= '';
	guidata(hObject,handles);
	
	uiresume(handles.figMain);
	close(handles.figMain);
%------------------------------------------------------------------------------%
function butSelectionPlus_Callback(hObject, eventdata, handles)
	handles	= SelectionExpand(handles,1);
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function butSelectionMinus_Callback(hObject, eventdata, handles)
	handles	= SelectionContract(handles,1);
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function sldImage_Callback(hObject, eventdata, handles)
	kSlice	= round(get(hObject,'Value'));
	
	handles	= SetPositionRel(handles,[],[],kSlice);
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function edtPathAnatomy_Callback(hObject, eventdata, handles)
	set(hObject,'String',handles.strPathAnat);
%------------------------------------------------------------------------------%
function edtPathStatistic_Callback(hObject, eventdata, handles)
	set(hObject,'String',handles.strPathStat);
%------------------------------------------------------------------------------%
function edtPathMask_Callback(hObject, eventdata, handles)
	handles.strPathMask	= get(hObject,'String');
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function ImageDown(hObject, eventdata, handles)
	%get the click info
		[pY,pX]	= MousePosition(handles);
	
	switch handles.clickmode
		case 'replace'
			handles	= PointReplaceRel(handles,pY,pX,[]);
		case 'add'
			handles	= PointAddRel(handles,pY,pX,[]);
		case 'remove'
			handles	= PointRemoveRel(handles,pY,pX,[]);
		case 'move';
	end
	
	handles	= SetPositionRel(handles,pY,pX,[]);
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function KeyPress(hObject, eventdata, handles)
	handles	= SetClickMode(handles,eventdata);
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function KeyRelease(hObject, eventdata, handles)
	handles	= SetClickMode(handles,eventdata);
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function handles = SetClickMode(handles,eventdata)
	bShift		= ismember('shift',eventdata.Modifier);
	bControl	= ismember('control',eventdata.Modifier);
	bAlt		= ismember('alt',eventdata.Modifier);
	
	if bShift
		if bControl
			handles.clickmode	= 'add_select';
		else
			handles.clickmode	= 'add';
		end
	elseif bAlt
		if bControl
			handles.clickmode	= 'remove_select';
		else
			handles.clickmode	= 'remove';
		end
	elseif bControl
		handles.clickmode	= 'move';
	else
		handles.clickmode	= 'replace';
	end
%------------------------------------------------------------------------------%
function MouseMove(hObject, eventdata, handles)
	switch handles.movemode
		case 'select'
			[pY,pX]	= MousePosition(handles);
			
			handles.select.yEnd	= pY;
			handles.select.xEnd	= pX;
			
			handles	= Draw(handles);
		otherwise
	end
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function MouseDown(hObject, eventdata, handles)
	switch handles.clickmode
		case {'add_select','remove_select'}
			[handles.select.yStart,handles.select.xStart]	= MousePosition(handles);
			handles.select.yEnd								= handles.select.yStart;
			handles.select.xEnd								= handles.select.xStart;
			
			handles.movemode	= 'select';
		otherwise
			handles.movemode	= 'none';
	end
	
	handles	= Draw(handles);
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function MouseUp(hObject, eventdata, handles)
	switch handles.movemode
		case 'select'
			[pY,pX]	= MousePosition(handles);
			
			switch handles.clickmode
				case 'add_select'
					handles	= SelectionAddRel(handles,handles.select.yStart,handles.select.xStart,handles.pos.slice,pY,pX,handles.pos.slice,false);
				case 'remove_select'
					handles	= SelectionRemoveRel(handles,handles.select.yStart,handles.select.xStart,handles.pos.slice,pY,pX,handles.pos.slice,false);
			end
			
			handles.select	= dealstruct('yStart','xStart','yEnd','xEnd',[]);
		otherwise
	end
	
	handles.movemode	= 'none';
	
	handles	= Draw(handles);
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function [pY,pX] = MousePosition(handles)
	mPos	= get(handles.axClick,'CurrentPoint');
		
	sY	= handles.size.y;
	sX	= handles.size.x;
	
	pY	= max(1,min(sY,round(sY - mPos(1,2) + 1)));
	pX	= max(1,min(sX,round(mPos(1,1))));
%------------------------------------------------------------------------------%
%*------*------*------*------*------*------*------*------*------*------*------*%

%*------*------*------*------*------*------*------*------*------*------*------*%
%------------------------------------------------------------------------------%
function popPlane_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
%------------------------------------------------------------------------------%
function popThreshold_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
%------------------------------------------------------------------------------%
function edtThreshold_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
%------------------------------------------------------------------------------%
function sldImage_CreateFcn(hObject, eventdata, handles)
	% Hint: slider controls usually have a light gray background.
	if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor',[.9 .9 .9]);
	end
%------------------------------------------------------------------------------%
function edtPathAnatomy_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
%------------------------------------------------------------------------------%
function edtPathStatistic_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
%------------------------------------------------------------------------------%
function edtPathMask_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
%------------------------------------------------------------------------------%
%*------*------*------*------*------*------*------*------*------*------*------*%

%*------*------*------*------*------*------*------*------*------*------*------*%
%------------------------------------------------------------------------------%
function handles = PointReplaceRel(handles,varargin)
	[kY,kX,kSlice,bDraw]	= ParseArgs(varargin,handles.pos.y,handles.pos.x,handles.pos.slice,true);
	
	[k1,k2,k3]	= rel2abs(handles,kY,kX,kSlice);
	
	handles	= PointReplaceAbs(handles,k1,k2,k3,bDraw);
%------------------------------------------------------------------------------%
function handles = PointReplaceAbs(handles,varargin)
	[k1,k2,k3,bDraw]	= ParseArgs(varargin,handles.pos.dim1,handles.pos.dim2,handles.pos.dim3,true);
	
	kPoint	= sub2ind(size(handles.L),k1,k2,k3);
	
	kLabel	= handles.L(kPoint);
	
	if kLabel~=0
		handles	= SetSelected(handles,handles.L==kLabel,bDraw);
	else
		handles	= ClearSelection(handles,bDraw);
	end
%------------------------------------------------------------------------------%
function handles = PointAddRel(handles,varargin)
	[kY,kX,kSlice,bDraw]	= ParseArgs(varargin,handles.pos.y,handles.pos.x,handles.pos.slice,true);
	
	[k1,k2,k3]	= rel2abs(handles,kY,kX,kSlice);
	
	handles	= PointAddAbs(handles,k1,k2,k3,bDraw);
%------------------------------------------------------------------------------%
function handles = PointAddAbs(handles,varargin)
	[k1,k2,k3,bDraw]	= ParseArgs(varargin,handles.pos.dim1,handles.pos.dim2,handles.pos.dim3,true);
	
	kPoint	= sub2ind(size(handles.L),k1,k2,k3);
	
	kLabel	= handles.L(kPoint);
	
	if kLabel~=0
		handles	= SetSelected(handles,handles.selected | handles.L==kLabel,bDraw);
	end
%------------------------------------------------------------------------------%
function handles = PointRemoveRel(handles,varargin)
	[kY,kX,kSlice,bDraw]	= ParseArgs(varargin,handles.pos.y,handles.pos.x,handles.pos.slice,true);
	
	[k1,k2,k3]	= rel2abs(handles,kY,kX,kSlice);
	
	handles	= PointRemoveAbs(handles,k1,k2,k3,bDraw);
%------------------------------------------------------------------------------%
function handles = PointRemoveAbs(handles,varargin)
	[k1,k2,k3,bDraw]	= ParseArgs(varargin,handles.pos.dim1,handles.pos.dim2,handles.pos.dim3,true);
	
	kPoint	= sub2ind(size(handles.L),k1,k2,k3);
	
	kLabel	= handles.L(kPoint);
	
	if kLabel~=0
		handles	= SetSelected(handles,handles.selected & ~handles.L==kLabel,bDraw);
	end
%------------------------------------------------------------------------------%
function handles = SelectionAddRel(handles,yStart,xStart,sliceStart,yEnd,xEnd,sliceEnd,varargin)
	bDraw	= ParseArgs(varargin,true);
	
	[s1,s2,s3]	= rel2abs(handles,yStart,xStart,sliceStart);
	[e1,e2,e3]	= rel2abs(handles,yEnd,xEnd,sliceEnd);
	
	r1	= sort([s1 e1]);
	r2	= sort([s2 e2]);
	r3	= sort([s3 e3]);
	
	handles	= SelectionAddAbs(handles,r1(1),r2(1),r3(1),r1(2),r2(2),r3(2),bDraw);
%------------------------------------------------------------------------------%
function handles = SelectionAddAbs(handles,s1,s2,s3,e1,e2,e3,varargin)
	bDraw	= ParseArgs(varargin,true);
	
	b						= handles.selected;
	b(s1:e1,s2:e2,s3:e3)	= b(s1:e1,s2:e2,s3:e3) | handles.stat.b(s1:e1,s2:e2,s3:e3);
	handles					= SetSelected(handles,b,bDraw);
%------------------------------------------------------------------------------%
function handles = SelectionRemoveRel(handles,yStart,xStart,sliceStart,yEnd,xEnd,sliceEnd,varargin)
	bDraw	= ParseArgs(varargin,true);
	
	[s1,s2,s3]	= rel2abs(handles,yStart,xStart,sliceStart);
	[e1,e2,e3]	= rel2abs(handles,yEnd,xEnd,sliceEnd);
	
	r1	= sort([s1 e1]);
	r2	= sort([s2 e2]);
	r3	= sort([s3 e3]);
	
	handles	= SelectionRemoveAbs(handles,r1(1),r2(1),r3(1),r1(2),r2(2),r3(2),bDraw);
%------------------------------------------------------------------------------%
function handles = SelectionRemoveAbs(handles,s1,s2,s3,e1,e2,e3,varargin)
	bDraw	= ParseArgs(varargin,true);
	
	b						= handles.selected;
	b(s1:e1,s2:e2,s3:e3)	= false;
	handles					= SetSelected(handles,b,bDraw);
%------------------------------------------------------------------------------%
function handles = ClearSelection(handles,varargin)
	bDraw	= ParseArgs(varargin,true);
	
	handles	= SetSelected(handles,false(size(handles.stat.data)),bDraw);
%------------------------------------------------------------------------------%
function handles = SelectionExpand(handles,varargin)
	[nExpand,bDraw]	= ParseArgs(varargin,1,true);
	
	handles	= SetSelected(handles,imdilate(handles.selected,MaskBall(nExpand*ones(1,3))) & handles.stat.b,bDraw);
%------------------------------------------------------------------------------%
function handles = SelectionContract(handles,varargin)
	[nContract,bDraw]	= ParseArgs(varargin,1,true);
	
	handles	= SetSelected(handles,imerode(handles.selected,MaskBall(nContract*ones(1,3))),bDraw);
%------------------------------------------------------------------------------%
%*------*------*------*------*------*------*------*------*------*------*------*%


%*------*------*------*------*------*------*------*------*------*------*------*%
%------------------------------------------------------------------------------%
function handles = Draw(handles)
	switch handles.dim.slice
		case 1
			imAnat		= squeeze(handles.anat.data(handles.pos.dim1,:,:));
			imStat		= squeeze(handles.stat.thresholded(handles.pos.dim1,:,:));
			bStat		= squeeze(handles.stat.b(handles.pos.dim1,:,:));
			bSelected	= squeeze(handles.selected(handles.pos.dim1,:,:));
		case 2
			imAnat		= squeeze(handles.anat.data(:,handles.pos.dim2,:));
			imStat		= squeeze(handles.stat.thresholded(:,handles.pos.dim2,:));
			bStat		= squeeze(handles.stat.b(:,handles.pos.dim2,:));
			bSelected	= squeeze(handles.selected(:,handles.pos.dim2,:));
		case 3
			imAnat		= squeeze(handles.anat.data(:,:,handles.pos.dim3));
			imStat		= squeeze(handles.stat.thresholded(:,:,handles.pos.dim3));
			bStat		= squeeze(handles.stat.b(:,:,handles.pos.dim3));
			bSelected	= squeeze(handles.selected(:,:,handles.pos.dim3));
	end
	
	im				= uint16(imAnat);
	im(bStat)		= imStat(bStat);
	im(bSelected)	= im(bSelected) + 256;
	
	%reorient the image
		if handles.dim.y > handles.dim.x
			im	= im';
		end
		if handles.dir.y==-1
			im	= im(end:-1:1,:);
		end
		if handles.dir.x==-1
			im	= im(:,end:-1:1);
		end
	
	%RGBicize
		im	= ind2rgb(im,handles.lut.rendered);
	
	%add crosshairs
		imTemp	= im;
		
		imTemp(handles.pos.y,:,:)	= 1;
		imTemp(:,handles.pos.x,:)	= 1;
		
		im	= imTemp/3 + 2*im/3;
	%add the selection box
		if ~isempty(handles.select.yStart);
			imTemp	= im;
			
			rY	= sort([handles.select.yStart handles.select.yEnd]);
			rX	= sort([handles.select.xStart handles.select.xEnd]);
			rY	= rY(1):rY(2);
			rX	= rX(1):rX(2);
	
			imTemp(rY,rX,:)	= repmat(reshape([0 0.5 1],1,1,3),[numel(rY) numel(rX) 1]);
			
			im	= imTemp/3 + 2*im/3;
		end
	
	image(im,'parent',handles.axImage);
	
	%set some image info
		cPos						= {num2str(handles.pos.dim1) num2str(handles.pos.dim2) num2str(handles.pos.dim3)};
		cPos{handles.dim.slice}	= ['*' cPos{handles.dim.slice}];
		strPos	= ['(' join(cPos,', ') ')'];
		
		switch handles.dim.slice
			case handles.dim.sagittal
				strDirLeft		= 'P';
				strDirRight		= 'A';
				strDirTop		= 'S';
				strDirBottom	= 'I';
				strScrollUp		= 'L';
				strScrollDown	= 'R';
			case handles.dim.coronal
				strDirLeft		= 'R';
				strDirRight		= 'L';
				strDirTop		= 'S';
				strDirBottom	= 'I';
				strScrollUp		= 'A';
				strScrollDown	= 'P';
			case handles.dim.axial
				strDirLeft		= 'P';
				strDirRight		= 'A';
				strDirTop		= 'R';
				strDirBottom	= 'L';
				strScrollUp		= 'I';
				strScrollDown	= 'S';
		end
		
		yLim	= get(handles.axImage,'YLim');
		xLim	= get(handles.axImage,'XLim');
		yT	= yLim(2)-1;
		yM	= sum(yLim)/2;
		yB	= yLim(1)+1;
		xR	= xLim(2)-1;
		xM	= sum(xLim)/2;
		xL	= xLim(1)+1;
		
		if isempty(handles.txtPosition)
			handles.txtPosition		= text(xL,yB,strPos,'Color',[1 1 0],'HorizontalAlignment','left','VerticalAlignment','bottom');
			handles.txtDirLeft		= text(xL,yM,strDirLeft,'Color',[1 1 0],'HorizontalAlignment','left','VerticalAlignment','middle');
			handles.txtDirRight		= text(xR,yM,strDirRight,'Color',[1 1 0],'HorizontalAlignment','right','VerticalAlignment','middle');
			handles.txtDirTop		= text(xM,yT,strDirTop,'Color',[1 1 0],'HorizontalAlignment','center','VerticalAlignment','top');
			handles.txtDirBottom	= text(xM,yB,strDirBottom,'Color',[1 1 0],'HorizontalAlignment','center','VerticalAlignment','bottom');
			handles.txtScrollUp		= text(xR,yT,[strScrollUp ' ->'],'Color',[1 1 0],'HorizontalAlignment','right','VerticalAlignment','top');
			handles.txtScrollDown	= text(xR,yB,[strScrollDown ' ->'],'Color',[1 1 0],'HorizontalAlignment','right','VerticalAlignment','bottom');
		else
			set(handles.txtPosition,'String',strPos,'Position',[xL yB 0]);
			set(handles.txtDirLeft,'String',strDirLeft,'Position',[xL yM 0]);
			set(handles.txtDirRight,'String',strDirRight,'Position',[xR yM 0]);
			set(handles.txtDirTop,'String',strDirTop,'Position',[xM yT 0]);
			set(handles.txtDirBottom,'String',strDirBottom,'Position',[xM yB 0]);
			set(handles.txtScrollUp,'String',[strScrollUp ' ->'],'Position',[xR yT 0]);
			set(handles.txtScrollDown,'String',[strScrollDown ' ->'],'Position',[xR yB 0]);
		end
%------------------------------------------------------------------------------%
function handles = MaskInfo(handles)
	if any(handles.selected(:))
		handles.maskinfo.L	= unique(handles.L(handles.selected));
		
		props						= regionprops(double(handles.selected),'Area','Centroid');
		handles.maskinfo.area		= props.Area;
		handles.maskinfo.centroid	= props.Centroid;
		
		strClusters	= join({
						['cluster indices: ' join(handles.maskinfo.L,', ')]
						['volume: ' num2str(handles.maskinfo.area)]
						['centroid: (' join(num2cell(round(handles.maskinfo.centroid)),', ') ')']
						},10);
		
		set(handles.txtCurrent,'String',strClusters);
	else
		handles.maskinfo.Lu			= [];
		handles.maskinfo.area		= 0;
		handles.maskinfo.centroid	= [NaN NaN NaN];
		
		set(handles.txtCurrent,'String','');
	end
%------------------------------------------------------------------------------%
%*------*------*------*------*------*------*------*------*------*------*------*%

%*------*------*------*------*------*------*------*------*------*------*------*%
%------------------------------------------------------------------------------%
function varargout = rel2abs(handles,kY,kX,kSlice,varargin)
% [k1,k2,k3] = rel2abs(handles,kY,kX,kSlice,bReverse)
	bReverse	= ParseArgs(varargin,true);
	
	varargout{handles.dim.y}		= conditional(~bReverse | handles.dir.y==1,kY,handles.size.y-kY+1);
	varargout{handles.dim.x}		= conditional(~bReverse | handles.dir.x==1,kX,handles.size.x-kX+1);
	varargout{handles.dim.slice}	= conditional(~bReverse | handles.dir.slice==1,kSlice,handles.size.slice-kSlice+1);
%------------------------------------------------------------------------------%
function [kY,kX,kSlice] = abs2rel(handles,varargin)
% [kY,kX,kSlice] = abs2rel(handles,k1,k2,k3,bReverse)
	bReverse	= ParseArgs(varargin(4:end),true);
	
	kY		= varargin{handles.dim.y};
	kX		= varargin{handles.dim.x};
	kSlice	= varargin{handles.dim.slice};
	
	if bReverse
		if handles.dir.y==-1
			kY	= handles.size.y - kY + 1;
		end
		if handles.dir.x==-1
			kX	= handles.size.x - kX + 1;
		end
		if handles.dir.slice==-1
			kSlice	= handles.size.slice - kSlice + 1;
		end
	end
%------------------------------------------------------------------------------%
%*------*------*------*------*------*------*------*------*------*------*------*%

%*------*------*------*------*------*------*------*------*------*------*------*%
%------------------------------------------------------------------------------%
function handles = CalculateClusters(handles)
	handles.L		= bwlabeln(handles.stat.b);
	handles.props	= regionprops(handles.L,'Area','Centroid');
	
	mnA	= min([handles.props.Area]);
	mxA	= max([handles.props.Area]);
	
	nCluster	= max(handles.L(:));
	
	strClusters	= join({
					['N: ' num2str(nCluster)]
					['min volume: ' num2str(mnA)]
					['max volume: ' num2str(mxA)]
					},10);
	
	set(handles.txtClusters,'String',strClusters);
%------------------------------------------------------------------------------%
%*------*------*------*------*------*------*------*------*------*------*------*%

%*------*------*------*------*------*------*------*------*------*------*------*%
%------------------------------------------------------------------------------%
function handles = SetThreshold(handles,varargin)
	[strType,thresh,bDraw]	= ParseArgs(varargin,handles.thresholdType,handles.threshold,true);
	
	handles.thresholdType	= strType;
	handles.threshold		= thresh;
	
	handles.stat.thresholded	= handles.stat.data;
	
	if isempty(handles.thresholdType)
		return;
	end
	
	switch handles.thresholdType
		case '>'
			handles.stat.b	= handles.stat.thresholded>handles.threshold;
			kPop			= 1;
		case '>='
			handles.stat.b	= handles.stat.thresholded>=handles.threshold;
			kPop			= 2;
		case '='
			handles.stat.b	= handles.stat.thresholded==handles.threshold;
			kPop			= 3;
		case '<='
			handles.stat.b	= handles.stat.thresholded<=handles.threshold;
			kPop			= 4;
		case '<'
			handles.stat.b	= handles.stat.thresholded<handles.threshold;
			kPop			= 5;
	end
	
	handles.stat.thresholded(~handles.stat.b)	= 0;
	handles.stat.thresholded(handles.stat.b)	= abs(handles.stat.thresholded(handles.stat.b));
	
	mn	= min(handles.stat.thresholded(handles.stat.b));
	mx	= max(handles.stat.thresholded(handles.stat.b));
	
	handles.stat.thresholded(handles.stat.b)	= round(MapValue(handles.stat.thresholded(handles.stat.b),mn,mx,257,511));
	
	handles	= CalculateClusters(handles);
	handles	= FixSelected(handles,false);
	
	set(handles.popThreshold,'Value',kPop);
	set(handles.edtThreshold,'String',num2str(thresh));
	
	if bDraw
		handles	= Draw(handles);
	end
%------------------------------------------------------------------------------%
function handles = SetPlane(handles,varargin)
	[plane,bDraw]	= ParseArgs(varargin,handles.plane,true);
	
	handles.plane	= plane;
	
	switch handles.plane
		case 'axial'
			[handles.dim.y,handles.dim.x,handles.dim.slice]	= deal(handles.dim.sagittal,handles.dim.coronal,handles.dim.axial);
		case 'sagittal'
			[handles.dim.y,handles.dim.x,handles.dim.slice]	= deal(handles.dim.axial,handles.dim.coronal,handles.dim.sagittal);
		case 'coronal'
			[handles.dim.y,handles.dim.x,handles.dim.slice]	= deal(handles.dim.axial,handles.dim.sagittal,handles.dim.coronal);
	end
	
	[handles.size.y,handles.size.x,handles.size.slice]	= abs2rel(handles,handles.size.dim1,handles.size.dim2,handles.size.dim3,false);
	[handles.dir.y,handles.dir.x,handles.dir.slice]		= abs2rel(handles,handles.dir.dim1,handles.dir.dim2,handles.dir.dim3,false);
	[handles.pos.y,handles.pos.x,handles.pos.slice]		= abs2rel(handles,handles.pos.dim1,handles.pos.dim2,handles.pos.dim3);
	
	set(handles.sldImage,'max',handles.size.slice,'sliderstep',[1/handles.size.slice 10/handles.size.slice],'Value',handles.pos.slice);
	
	if bDraw                                                                                                                                
		handles	= Draw(handles);
	end
%------------------------------------------------------------------------------%
function handles = SetPositionRel(handles,varargin)
	[pY,pX,pSlice,bDraw]	= ParseArgs(varargin,handles.pos.y,handles.pos.x,handles.pos.slice,true);
	
	[p1,p2,p3]	= rel2abs(handles,pY,pX,pSlice);
	
	handles	= SetPositionAbs(handles,p1,p2,p3,bDraw);
%------------------------------------------------------------------------------%
function handles = SetPositionAbs(handles,varargin)
	[p1,p2,p3,bDraw]	= ParseArgs(varargin,handles.pos.dim1,handles.pos.dim2,handles.pos.dim3,true);
	
	p1	= unless(p1,round(handles.size.dim1/2),-1);
	p2	= unless(p2,round(handles.size.dim2/2),-1);
	p3	= unless(p3,round(handles.size.dim3/2),-1);
	
	[handles.pos.dim1,handles.pos.dim2,handles.pos.dim3]	= deal(max(1,min(handles.size.dim1,p1)),max(1,min(handles.size.dim2,p2)),max(1,min(handles.size.dim3,p3)));
	[handles.pos.y,handles.pos.x,handles.pos.slice]		= abs2rel(handles,handles.pos.dim1,handles.pos.dim2,handles.pos.dim3);
	
	set(handles.sldImage,'Value',handles.pos.slice);
	
	if bDraw
		handles	= Draw(handles);
	end
%------------------------------------------------------------------------------%
function handles = SetLUT(handles,varargin)
	[lutAnat,lutStat,lutMask,bDraw]	= ParseArgs(varargin,[],[],[],true);
	
	if ~isempty(lutAnat)
		handles.lut.anat	= lutAnat;
	end
	if ~isempty(lutStat)
		handles.lut.stat	= lutStat;
	end
	if ~isempty(lutMask)
		handles.lut.mask	= lutMask;
	end
	
	handles.lut.rendered	=	[
									MakeLUT(lutAnat,256)
									MakeLUT(lutStat,256)
									MakeLUT(lutMask,256)
								];
	
	colormap(handles.axImage,handles.lut.rendered);
	
	if bDraw
		handles	= Draw(handles);
	end
%------------------------------------------------------------------------------%
function handles = FixSelected(handles,bDraw)
	handles.selected	= handles.selected & handles.stat.b;
	
	handles	= MaskInfo(handles);
	
	if bDraw
		handles	= Draw(handles);
	end
%------------------------------------------------------------------------------%
function handles = SetSelected(handles,b,varargin)
	bDraw	= ParseArgs(varargin,true);
	
	handles.selectedUndo	= unless(handles.selected,b);
	handles.selected		= b;
	
	handles	= MaskInfo(handles);
	
	if bDraw
		handles	= Draw(handles);
	end
%------------------------------------------------------------------------------%
function handles = RevertSelected(handles,varargin)
	bDraw	= ParseArgs(varargin,true);
	
	handles	= SetSelected(handles,handles.selectedUndo,bDraw);
%------------------------------------------------------------------------------%
%*------*------*------*------*------*------*------*------*------*------*------*%

%*------*------*------*------*------*------*------*------*------*------*------*%
%------------------------------------------------------------------------------%
function handles = SetAnat(handles,strPathAnat,bDraw)
	handles.strPathAnat	= strPathAnat;
	
	set(handles.edtPathAnatomy,'String',handles.strPathAnat);
	
	handles.anat		= NIfTI.Read(handles.strPathAnat);
	handles.anat.data	= 1+uint8(round(254*normalize(double(handles.anat.data))));
	
	%get the image grid orientation
		mOrient	= NIfTI.ImageGridOrientation(handles.anat);
	%make it go r->l, p->a, s->i
		mOrient(:,1)	= -mOrient(:,1);
		mOrient(:,3)	= -mOrient(:,3);
	
	handles.dim.sagittal	= find(mOrient(:,1));
	handles.dim.coronal		= find(mOrient(:,2));
	handles.dim.axial		= find(mOrient(:,3));
	
	handles.dir.dim1	= sum(mOrient(1,:));
	handles.dir.dim2	= sum(mOrient(2,:));
	handles.dir.dim3	= sum(mOrient(3,:));
	
	[handles.size.dim1,handles.size.dim2,handles.size.dim3]	= size(handles.anat.data);
	
	if bDraw
		handles	= Draw(handles);
	end
%------------------------------------------------------------------------------%
function handles = SetStat(handles,strPathStat,bDraw)
	handles.strPathStat	= strPathStat;
	
	set(handles.edtPathStatistic,'String',handles.strPathStat);
	
	handles.stat		= NIfTI.Read(handles.strPathStat);
	handles.stat.data	= double(handles.stat.data);
	
	handles	= SetThreshold(handles,[],[],bDraw);
%------------------------------------------------------------------------------%
function handles = SetMask(handles,strPathMask)
	handles.strPathMask	= strPathMask;
	
	set(handles.edtPathMask,'String',handles.strPathMask);
%------------------------------------------------------------------------------%
function b = SaveMask(handles)
	b	= false;
	
	if any(handles.selected(:))
		nii			= handles.anat;
		nii.data	= handles.selected;
		
		NIfTI.Write(nii,handles.strPathMask);
		
		b	= true;
	end
	
	if b
		status(['Saved ' handles.strPathMask '!']);
	else
		status(['Could not save ' handles.strPathMask '!'],'warning',true);
	end
%------------------------------------------------------------------------------%
%*------*------*------*------*------*------*------*------*------*------*------*%
