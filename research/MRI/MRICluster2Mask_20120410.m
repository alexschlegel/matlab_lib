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
% Updated: 2012-04-02
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
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
	[handles.strPathStat,handles.strPathAnat,handles.strPathMask]	= ParseArgs(varargin,[],FSLPathMNIAnatomical('type','MNI152_T1_2mm_brain'),[]);
	
	handles.output = hObject;
	
	mxFile	= 38;
	
	handles.kCluster	= 0;
	
	%add the axes that will accept user clicks
		handles.axClick	= axes;
		linkaxes([handles.axImage handles.axClick]);
		
		set(handles.axClick,'Color','none');
		set(handles.axClick,'Units','pixels');
		set(handles.axClick,'Position',get(handles.axImage,'Position'));
		set(handles.axClick,'xTick',[]);
		set(handles.axClick,'yTick',[]);
		hold(handles.axClick,'on');
	
		set(handles.axClick,'ButtonDownFcn','MRICluster2Mask(''ClickImage'',gcbo,[],guidata(gcbo));');
	
	set(handles.txtAnatomyPath,'String',StringCutoff(handles.strPathAnat,mxFile,'left'));
	set(handles.txtStatisticPath,'String',StringCutoff(handles.strPathStat,mxFile,'left'));
	
	handles.anat	= NIfTIRead(handles.strPathAnat);
	handles.stat	= NIfTIRead(handles.strPathStat);
	
	handles.anat.data	= 1+uint8(round(254*normalize(handles.anat.data)));
	handles				= SetStatThresh(handles,'>',0);
	
	handles.lut	=	[
						MakeLUT([0 0 0; 1 1 1],256)
						MakeLUT([1 0 0; 1 1 0],256)
						MakeLUT([0 0.8 0; 0 1 1],256)
					];
	colormap(handles.axImage,handles.lut);
	
	handles.txtSlice	= [];
	handles				= SetPlane(handles,12);
	
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


%------------------------------------------------------------------------------%
function popPlane_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns popPlane contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popPlane
	plane	= switch2(get(hObject,'Value'),...
				1	, 12	, ...
				2	, 23	, ...
				3	, 13	  ...
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
	
	handles = SetStatThresh(handles,strType,handles.thresh);
	handles = ShowImage(handles);
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function edtThreshold_Callback(hObject, eventdata, handles)
	handles = SetStatThresh(handles,handles.threshType,str2num(get(hObject,'String')));
	handles = ShowImage(handles);
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%


%------------------------------------------------------------------------------%
function butOK_Callback(hObject, eventdata, handles)
	if ~SaveMask(handles)
		handles.strPathMask	= '';
		guidata(hObject,handles);
	end
	
	uiresume(handles.figMain);
	
	close(handles.figMain);
%------------------------------------------------------------------------------%
function butCancel_Callback(hObject, eventdata, handles)
	handles.strPathMask	= '';
	guidata(hObject,handles);
	
	uiresume(handles.figMain);
	
	close(handles.figMain);
%------------------------------------------------------------------------------%
function sldImage_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
	handles	= SetPosition(handles,round(get(hObject,'Value')));
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%


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


%------------------------------------------------------------------------------%
function handles = SetStatThresh(handles,strType,thresh)
	handles.threshType	= strType;
	handles.thresh		= thresh;
	
	handles.stat.thresholded	= handles.stat.data;
	
	switch strType
		case '>'
			handles.stat.b	= handles.stat.thresholded>thresh;
			kPop			= 1;
		case '>='
			handles.stat.b	= handles.stat.thresholded>=thresh;
			kPop			= 2;
		case '='
			handles.stat.b	= handles.stat.thresholded==thresh;
			kPop			= 3;
		case '<='
			handles.stat.b	= handles.stat.thresholded<=thresh;
			kPop			= 4;
		case '<'
			handles.stat.b	= handles.stat.thresholded<thresh;
			kPop			= 5;
	end
	
	handles.stat.thresholded(~handles.stat.b)	= 0;
	handles.stat.thresholded(handles.stat.b)		= abs(handles.stat.thresholded(handles.stat.b));
	
	mn	= min(handles.stat.thresholded(handles.stat.b));
	mx	= max(handles.stat.thresholded(handles.stat.b));
	
	handles.stat.thresholded(handles.stat.b)	= round(MapValue(handles.stat.thresholded(handles.stat.b),mn,mx,257,511));
	
	handles	= CalculateClusters(handles);
	
	set(handles.popThreshold,'Value',kPop);
	set(handles.edtThreshold,'String',num2str(thresh));
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
	
	handles.kCluster	= 0;
	
	set(handles.txtClusters,'String',strClusters);
%------------------------------------------------------------------------------%
function handles = SetPlane(handles,plane)
	switch plane
		case 12
			handles.kSlice	= 3;
			handles.kY		= 1;
			handles.kX		= 2;
		case 13
			handles.kSlice	= 2;
			handles.kY		= 1;
			handles.kX		= 3;
		case 23
			handles.kSlice	= 1;
			handles.kY		= 2;
			handles.kX		= 3;
	end
	
	handles.sSlice	= size(handles.anat.data,handles.kSlice);
	handles.sY		= size(handles.anat.data,handles.kY);
	handles.sX		= size(handles.anat.data,handles.kX);
	
	handles.plane	= plane;
	
	set(handles.sldImage,'max',handles.sSlice,'sliderstep',[1/handles.sSlice 10/handles.sSlice]);
	
	handles	= SetPosition(handles,round(handles.sSlice/2));
%------------------------------------------------------------------------------%
function handles = SetPosition(handles,pos)
	kSlice	= switch2(handles.plane,...
				12	, 3	, ...
				13	, 2	, ...
				23	, 1	  ...
				);
	sSlice	= size(handles.anat.data,kSlice);
	
	handles.pos	= round(max(1,min(sSlice,pos)));
	set(handles.sldImage,'Value',handles.pos);
	
	handles	= ShowImage(handles);
%------------------------------------------------------------------------------%
function handles = ShowImage(handles)
	switch handles.plane
		case 12
			imAnat		= squeeze(handles.anat.data(:,:,handles.pos));
			imStat		= squeeze(handles.stat.thresholded(:,:,handles.pos));
			bStat		= squeeze(handles.stat.b(:,:,handles.pos));
			imCluster	= squeeze(handles.L(:,:,handles.pos));
		case 13
			imAnat		= squeeze(handles.anat.data(:,handles.pos,:));
			imStat		= squeeze(handles.stat.thresholded(:,handles.pos,:));
			bStat		= squeeze(handles.stat.b(:,handles.pos,:));
			imCluster	= squeeze(handles.L(:,handles.pos,:));
		case 23
			imAnat		= squeeze(handles.anat.data(handles.pos,:,:));
			imStat		= squeeze(handles.stat.thresholded(handles.pos,:,:));
			bStat		= squeeze(handles.stat.b(handles.pos,:,:));
			imCluster	= squeeze(handles.L(handles.pos,:,:));
	end
	
	im			= uint16(imAnat);
	im(bStat)	= imStat(bStat);
	
	if handles.kCluster~=0
		bCluster		= imCluster==handles.kCluster;
		im(bCluster)	= im(bCluster) + 256;
	end
	
	image(im,'parent',handles.axImage);
	
	if isempty(handles.txtSlice)
		handles.txtSlice	= text(2,2,num2str(handles.pos),'Color',[1 1 0],'VerticalAlignment','bottom');
	else
		set(handles.txtSlice,'String',num2str(handles.pos));
	end
%------------------------------------------------------------------------------%
function ClickImage(hObject,eventdata,handles)
	%get the mouse position
		mPos	= get(handles.axClick,'CurrentPoint');
		mType	= get(handles.figMain,'SelectionType');
	
	switch mType
		case {'normal','open'}
			pX	= max(1,min(handles.sX,round(mPos(1,1))));
			pY	= max(1,min(handles.sY,round(handles.sY - mPos(1,2) + 1)));
			
			cPoint					= cell(3,1);
			cPoint{handles.kX}		= pX;
			cPoint{handles.kY}		= pY;
			cPoint{handles.kSlice}	= handles.pos;
			kPoint					= sub2ind(size(handles.L),cPoint{:});
			
			handles.kCluster	= handles.L(kPoint);
			
			if handles.kCluster~=0
				strClusters	= join({
								['index: ' num2str(handles.kCluster)]
								['volume: ' num2str(handles.props(handles.kCluster).Area)]
								['centroid: (' join(num2cell(round(handles.props(handles.kCluster).Centroid)),', ') ')']
								},10);
				
				set(handles.txtCurrent,'String',strClusters);
			else
				set(handles.txtCurrent,'String','');
			end
	end
	
	handles = ShowImage(handles);
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function b = SaveMask(handles)
	b	= false;
	
	if handles.kCluster~=0
		nii			= handles.anat;
		nii.data	= handles.L==handles.kCluster;
		
		handles.strPathMask	= unless(handles.strPathMask,PathAddSuffix(handles.strPathStat,['-mask_cluster' num2str(handles.kCluster)],'favor','nii.gz'));
		NIfTIWrite(nii,handles.strPathMask);
		
		b	= true;
	end
%------------------------------------------------------------------------------%
