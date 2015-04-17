function varargout = MRIViewer(varargin)
% MRIViewer
% 
% Description:	view MRI and statistical data
% 
% Syntax:	MRIViewer([strPathNIfTI]=<FSL avg152T1>,<options>)
% 
% In:
% 	[strPathNIfTI]	- path to the NIfTI file to view
%	<options>:
%		stat:				(<none>) path to the NIfTI stat file to overlay
%		stat_min:			(<min of stat data>) minimum threshold for displaying
%							statistical data
%		stat_max:			(<max of stat data>) maximum threshold for displaying
%							statistical data
%		stat_palette:		(<red->yellow>) an Nx3 palette to use for the stat
%							overlay
%		stat_alpha:			(true) true to scale the statistical overlay's alpha
%							with degree of significance
%		p_norm:				([0 0 0]) the normalized data position as [lr pa is]
%							from -1->1
%		p_array:			([]) the data position as an array index
%		p_space:			([]) the data position in [lr pa is] space 
%		p_image:			([]) the data position as [lr pa is] image values
%		crosshair_l:		(3) length of crosshair lines
%		crosshair_t:		(1) crosshair thickness
%		crosshair_space:	(2) space between the crosshair center and lines
%		crosshair_c:		([0 0.5 1]) crosshair color
%		border_c:			([0.75 0.75 0.75]) color of the border between views
%		border_t:			(1) thickness of the border between views
%		h:					(600) height of the window
%		w:					(600) width of the window
%		name:				(<path to NII if file input, '' otherwise>) a title
%							for the figure
% 
% Assumptions:	assumes the data file's transformation matrix transforms to
%				[lr, pa, is] space, in mm
%
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
gui_Singleton = 1;
	gui_State = struct('gui_Name',       mfilename, ...
					   'gui_Singleton',  gui_Singleton, ...
					   'gui_OpeningFcn', @MRIViewer_OpeningFcn, ...
					   'gui_OutputFcn',  @MRIViewer_OutputFcn, ...
					   'gui_LayoutFcn',  [] , ...
					   'gui_Callback',   []);
	if nargin && ischar(varargin{1}) && ~isempty(which(varargin{1}))% && ~exist(varargin{1},'file')
		gui_State.gui_Callback = str2func(varargin{1});
	end
	
	if nargout
		[varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
	else
		gui_mainfcn(gui_State, varargin{:});
	end
%------------------------------------------------------------------------------%
function MRIViewer_OpeningFcn(hObject, eventdata, handles, varargin)
	palDef				= MakeLUT([1 0 0; 1 1 0],100);
	[strAnat,opt]		= ParseArgs(varargin,FSLPathMNIAnatomical(),...
							'stat'				, ''				, ...
							'stat_min'			, []				, ...
							'stat_max'			, []				, ...
							'stat_palette'		, palDef			, ...
							'stat_alpha'		, true				, ...
							'p_norm'			, [0 0 0]			, ...
							'p_array'			, []				, ...
							'p_space'			, []				, ...
							'p_image'			, []				, ...
							'crosshair_l'		, 3					, ...
							'crosshair_t'		, 1					, ...
							'crosshair_space'	, 2					, ...
							'crosshair_c'		, [0 0.5 1]			, ...
							'border_c'			, [0.75 0.75 0.75]	, ...
							'border_t'			, 1					, ...
							'h'					, 600				, ...
							'w'					, 600				, ...
							'name'				, ''				  ...
										);
				
	%initialize stuff
		handles	= Init(handles,opt);
	%load the data
		handles	= SetAnat(handles,'anat',strAnat,'draw',false);
	%load the stat values
		handles	= SetStat(handles,'stat',opt.stat,'min',opt.stat_min,'max',opt.stat_max,'pal',opt.stat_palette,'draw',false);
	%set the figure element positions
		handles	= SetFigurePosition(handles,'h',opt.h,'w',opt.w,'center',true);
	%set the data position
		handles	= SetDataPosition(handles,'array',opt.p_array,'space',opt.p_space,'image',opt.p_image,'norm',opt.p_norm);
	
	% Update handles structure
		guidata(hObject,handles);
		
	% UIWAIT makes MRIViewer wait for user response (see UIRESUME)
	% uiwait(handles.figMRIViewer);
%------------------------------------------------------------------------------%
function varargout = MRIViewer_OutputFcn(hObject, eventdata, handles) 
	varargout{1} = handles;
%------------------------------------------------------------------------------%

%------------------------------------------------------------------------------%
function mnuFile_Callback(hObject, eventdata, handles)
%------------------------------------------------------------------------------%
function mnuSaveSaggital_Callback(hObject, eventdata, handles)
	handles	= SaveImage(handles,'type','saggital');
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function mnuSaveAxial_Callback(hObject, eventdata, handles)
	handles	= SaveImage(handles,'type','axial');
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function mnuSaveCoronal_Callback(hObject, eventdata, handles)
	handles	= SaveImage(handles,'type','coronal');
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function mnuSaveAll_Callback(hObject, eventdata, handles)
	handles	= SaveImage(handles,'type','all');
	guidata(hObject,handles);
%------------------------------------------------------------------------------%

%------------------------------------------------------------------------------%
function figMRIViewer_ResizeFcn(hObject, eventdata, handles)
	if isfield(handles,'opt')
		handles	= SetFigurePosition(handles);
		guidata(hObject,handles);
	end
%------------------------------------------------------------------------------%

%------------------------------------------------------------------------------%
function edtPosI_Callback(hObject, eventdata, handles)
	handles	= SetDataPosition(handles,'array_i',str2num(get(hObject,'String')));
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function edtPosJ_Callback(hObject, eventdata, handles)
	handles	= SetDataPosition(handles,'array_j',str2num(get(hObject,'String')));
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function edtPosK_Callback(hObject, eventdata, handles)
	handles	= SetDataPosition(handles,'array_k',str2num(get(hObject,'String')));
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function edtPosLR_Callback(hObject, eventdata, handles)
	handles	= SetDataPosition(handles,'space_lr',str2num(get(hObject,'String')));
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function edtPosPA_Callback(hObject, eventdata, handles)
	handles	= SetDataPosition(handles,'space_pa',str2num(get(hObject,'String')));
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function edtPosIS_Callback(hObject, eventdata, handles)
	handles	= SetDataPosition(handles,'space_is',str2num(get(hObject,'String')));
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function axSaggitalOver_ButtonDownFcn(hObject, eventdata, handles)
	p	= get(hObject,'CurrentPoint');
	pa	= 2*(p(1,1)-0.5);
	is	= 2*(p(1,2)-0.5);
	
	handles	= SetDataPosition(handles,'norm_pa',pa,'norm_is',is);
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function axAxialOver_ButtonDownFcn(hObject, eventdata, handles)
	p	= get(hObject,'CurrentPoint');
	lr	= 2*(p(1,2)-0.5);
	pa	= 2*(p(1,1)-0.5);
	
	handles	= SetDataPosition(handles,'norm_lr',lr,'norm_pa',pa);
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function axCoronalOver_ButtonDownFcn(hObject, eventdata, handles)
	p	= get(hObject,'CurrentPoint');
	lr	= 2*(0.5-p(1,1));
	is	= 2*(p(1,2)-0.5);
	
	handles	= SetDataPosition(handles,'norm_lr',lr,'norm_is',is);
	guidata(hObject,handles);
%------------------------------------------------------------------------------%

%------------------------------------------------------------------------------%
function edtOverlayMin_Callback(hObject, eventdata, handles)
	handles	= SetStat(handles,'min',str2num(get(hObject,'String')));
	guidata(hObject, handles);
%------------------------------------------------------------------------------%
function edtOverlayMax_Callback(hObject, eventdata, handles)
	handles	= SetStat(handles,'max',str2num(get(hObject,'String')));
	guidata(hObject, handles);
%------------------------------------------------------------------------------%
function sldOverlayMin_Callback(hObject, eventdata, handles)
	handles	= SetStat(handles,'min',get(hObject,'Value'));
	guidata(hObject, handles);
%------------------------------------------------------------------------------%
function sldOverlayMax_Callback(hObject, eventdata, handles)
	handles	= SetStat(handles,'max',get(hObject,'Value'));
	guidata(hObject, handles);
%------------------------------------------------------------------------------%

%------------------------------------------------------------------------------%
function edtOverlayMin_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
%------------------------------------------------------------------------------%
function edtOverlayMax_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
%------------------------------------------------------------------------------%
function sldOverlayMin_CreateFcn(hObject, eventdata, handles)
	if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor',[.9 .9 .9]);
	end
%------------------------------------------------------------------------------%
function sldOverlayMax_CreateFcn(hObject, eventdata, handles)
	if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor',[.9 .9 .9]);
	end
%------------------------------------------------------------------------------%


%------------------------------------------------------------------------------%
function handles = Init(handles,opt)
%initialize stuff at the beginning of GUI creation
	%input parameters
		handles.param.crosshair.length	= opt.crosshair_l;
		handles.param.crosshair.t		= opt.crosshair_t;
		handles.param.crosshair.space	= opt.crosshair_space;
		handles.param.crosshair.c		= opt.crosshair_c;
		
		handles.param.border.c	= opt.border_c;
		handles.param.border.t	= opt.border_t;
		
		handles.name	= opt.name;
	%hide the over axes
		set(handles.axSaggitalOver,'Color','none');
		set(handles.axAxialOver,'Color','none');
		set(handles.axCoronalOver,'Color','none');
		set(handles.axSaggitalOver,'XAxisLocation','top');
		set(handles.axCoronalOver,'XAxisLocation','top');
		set(handles.axCoronalOver,'YAxisLocation','right');
%------------------------------------------------------------------------------%
function handles = SetFigurePosition(handles,varargin)
%set the position of the figure
	p	= GetElementPosition(handles.figMRIViewer);
	opt	= ParseArgs(varargin,...
			'h'			, p.h	, ...
			'w'			, p.w	, ... 
			'center'	, false	  ...
			);
	%get image sizes
		s	= abs(diff(handles.raw.anat.extent.space,1,2));
		
		sLR	= round(opt.h*s(1)/(s(1)+s(3)));
		sIS	= round(sLR*s(3)/s(1));
		sPA	= round(sLR*s(2)/s(1));
	%set the window size and position
		pFig	= MoveElement(handles.figMRIViewer,'w',sPA+sLR,'h',sIS+sLR);
		
		if opt.center
			MoveElement(handles.figMRIViewer,'center',true);
		end
	%set the axes positions
		MoveElement([handles.axSaggital handles.axSaggitalOver]	,'l',0,'t',0,'w',sPA,'h',sIS);
		MoveElement([handles.axAxial handles.axAxialOver]			,'l',0,'b',0,'w',sPA,'h',sLR);
		MoveElement([handles.axCoronal,handles.axCoronalOver]		,'r',0,'t',0,'w',sLR,'h',sIS);
	%set the element positions
		%panels against the left, full width
			[pPO,pPI]	= MoveElement([handles.panOverlay handles.panInfo],'l',sPA,'w',sLR);
		%overlay panel against the top
			pPO			= MoveElement(handles.panOverlay,'t',sIS);
		%info panel against the bottom, stretch to the overlay panel
			pPI			= MoveElement(handles.panInfo,'h',pPO.b,'b',0);
		%stretch the stat sliders full width
			pSOM		= MoveElement([handles.sldOverlayMin handles.sldOverlayMax],'r',5,'stretch',true);
		%stretch the array index position textboxes to the half point
			pEIJK		= MoveElement([handles.edtPosI handles.edtPosJ handles.edtPosK],'r',sPA/2,'stretch',true);
		%mm labels against the right
			pMM			= MoveElement([handles.txtLRmm handles.txtPAmm handles.txtISmm],'r',5);
		%space position textboxes against the mm labels, same width as others
			pLPI		= MoveElement([handles.edtPosLR handles.edtPosPA handles.edtPosIS],'w',pEIJK(1).w,'r',pMM(1).r+pMM(1).w+1);
		%space labels against the space textboxes
			pLLPI		= MoveElement([handles.txtPosLRLabel handles.txtPosPALabel handles.txtPosISLabel],'r',pLPI(1).r+pLPI(1).w+1);
		%position elements against the top
			pP1			= MoveElement([handles.txtPosILabel handles.edtPosI handles.txtPosLRLabel handles.edtPosLR handles.txtLRmm],'b',pPI.h-40);
			pP2			= MoveElement([handles.txtPosJLabel handles.edtPosJ handles.txtPosPALabel handles.edtPosPA handles.txtPAmm],'b',pP1(1).b-pP1(2).h-1);
			pP3			= MoveElement([handles.txtPosKLabel handles.edtPosK handles.txtPosISLabel handles.edtPosIS handles.txtISmm],'b',pP2(1).b-pP2(2).h-1);
		%stat elements against the bottom
			pS	= MoveElement([handles.txtStatLabel handles.txtStat],'b',5);
%------------------------------------------------------------------------------%
function handles = SetDataPosition(handles,varargin)
	%parse the arguments
		opt	= ParseArgs(varargin,...
				'norm'			, NaN(3,1)	, ...
				'norm_lr'		, NaN		, ...
				'norm_pa'		, NaN		, ...
				'norm_is'		, NaN		, ...
				'array'			, NaN(3,1)	, ...
				'array_i'		, NaN		, ...
				'array_j'		, NaN		, ...
				'array_k'		, NaN		, ...
				'space'			, NaN(3,1)	, ...
				'space_lr'		, NaN		, ...
				'space_pa'		, NaN		, ...
				'space_is'		, NaN		, ...
				'image'			, NaN(3,1)	, ...
				'image_lr'		, NaN		, ...
				'image_pa'		, NaN		, ...
				'image_is'		, NaN		, ...
				'draw'			, true		  ...
				);
				
	%get the new data position in physical space
		[opt.image,bNewImage]	= MergePoint(handles,opt.image,opt.image_lr,opt.image_pa,opt.image_is,'data','image');
		if bNewImage
			handles.p	= GetDataPosition(handles,opt.image,'in','image');
		else
			[opt.space,bNewSpace]	= MergePoint(handles,opt.space,opt.space_lr,opt.space_pa,opt.space_is,'data','space');
			if bNewSpace
				handles.p	= GetDataPosition(handles,opt.space,'in','space');
			else
				[opt.array,bNewArray]	= MergePoint(handles,opt.array,opt.array_i,opt.array_j,opt.array_k,'data','array');
				if bNewArray
					handles.p	= GetDataPosition(handles,opt.array,'in','array');
				else
					[opt.norm,bNewNorm]		= MergePoint(handles,opt.norm,opt.norm_lr,opt.norm_pa,opt.norm_is,'data','normalized');
					if bNewNorm
						handles.p	= GetDataPosition(handles,opt.norm,'in','normalized');
					end
				end
			end
		end
	%update the figure
		if opt.draw
			handles	= RefreshFigure(handles);
		end
%------------------------------------------------------------------------------%
function [p,bNew] = MergePoint(handles,p,p1,p2,p3,varargin)
	opt	= ParseArgs(varargin,...
			'data'	, 'array'	  ...
			);
	
	p	= reshape(p,[],1);
	
	if ~isnan(p1)
		p(1)	= p1;
	end
	if ~isnan(p2)
		p(2)	= p2;
	end
	if ~isnan(p3)
		p(3)	= p3;
	end
	
	bNaN	= isnan(p);
	
	bNew	= ~all(bNaN);
	
	if any(bNaN)
		pCur	= GetDataPosition(handles,[],'out',opt.data);
		p(bNaN)	= pCur(bNaN);
	end
%------------------------------------------------------------------------------%
function p = GetDataPosition(handles,varargin)
%get the current or specified data position
% In:
%	p	- 3xN array of points or 2xN for plane points
	[p,opt]	= ParseArgs(varargin,[],...
				'in'	, 'array'	, ...
				'out'	, 'array'	  ...
				);
	%get the default point
		if isempty(p)
			if ~isfield(handles,'p')
				p	= [NaN; NaN; NaN];
			else
				p	= GetDataPosition(handles,handles.p,'out',opt.in);
			end
		end
	%convert to array space
		nP	= size(p,2);
		switch opt.in
			case 'normalized'
				p	= MapValue(p,-1,1,handles.raw.anat.extent.space(:,1),handles.raw.anat.extent.space(:,2));
				p	= GetDataPosition(handles,p,'in','space');
			case 'array'
			case 'space'
				p	= round(handles.raw.anat.imat*[p; ones(1,nP)]);
				p	= p(1:3,:);
			case 'image'
				[pSag,pAx]	= GetElementPosition([handles.axSaggital handles.axAxial]);
				p			= MapValue(p,[1;1;1],[pAx.h; pAx.w; pSag.h],handles.raw.anat.extent.space(:,1),handles.raw.anat.extent.space(:,2));
				p			= GetDataPosition(handles,p,'in','space');
			case 'saggital'
				p3D			= GetDataPosition(handles,'out','image');
				[pSag,pAx]	= GetElementPosition([handles.axSaggital handles.axAxial]);
				p			= [repmat(p3D(1),[1 nP]); p(2,:); pSag.h-p(1,:)+1];
				p			= GetDataPosition(handles,p,'in','image');
			case 'axial'
				p3D			= GetDataPosition(handles,'out','image');
				[pSag,pAx]	= GetElementPosition([handles.axSaggital handles.axAxial]);
				p			= [pAx.h-p(1,:)+1; p(2,:); repmat(p3D(3),[1 nP])];
				p			= GetDataPosition(handles,p,'in','image');
			case 'coronal'
				p3D			= GetDataPosition(handles,'out','image');
				[pSag,pAx]	= GetElementPosition([handles.axSaggital handles.axAxial]);
				p			= [pAx.h-p(2,:)+1; repmat(p3D(2),[1 nP]); pSag.h-p(1,:)+1];
				p			= GetDataPosition(handles,p,'in','image');
			otherwise
				error(['"' opt.in '" is an unrecognized input space.']);
		end
	%convert to the output space
		switch opt.out
			case 'normalized'
				p	= GetDataPosition(handles,p,'out','space');
				p	= MapValue(p,handles.raw.anat.extent.space(:,1),handles.raw.anat.extent.space(:,2),-1,1);
			case 'array'
			case 'space'
				p	= handles.raw.anat.mat*[p; ones(1,nP)];
				p	= p(1:3,:);
			case 'image'
				p			= GetDataPosition(handles,p,'out','space');
				[pSag,pAx]	= GetElementPosition([handles.axSaggital handles.axAxial]);
				p			= round(MapValue(p,handles.raw.anat.extent.space(:,1),handles.raw.anat.extent.space(:,2),[1;1;1],[pAx.h; pAx.w; pSag.h]));
			case 'saggital'
				p		= GetDataPosition(handles,p,'out','image');
				pSag	= GetElementPosition(handles.axSaggital);
				p		= [pSag.h-p(3,:)+1; p(2,:)];
			case 'axial'
				p	= GetDataPosition(handles,p,'out','image');
				pAx	= GetElementPosition(handles.axAxial);
				p	= [pAx.h-p(1,:)+1; p(2,:)];
			case 'coronal'
				p			= GetDataPosition(handles,p,'out','image');
				[pSag,pAx]	= GetElementPosition([handles.axSaggital handles.axAxial]);
				p			= [pSag.h-p(3,:)+1; pAx.h-p(1,:)+1];
			otherwise
				error(['"' opt.out '" is an unrecognized output space.']);
		end
%------------------------------------------------------------------------------%
function v = GetDataValue(handles,varargin)
%get data values
% In:
%	p	- 3xN array of points or 2xN for plane points
%	pK	- 1xN array of points
	[p,p1,p2,p3,opt]	= ParseArgs(varargin,[],[],[],[],...
							'data'	, 'anat'	  ...
							);
	
	if ~isempty(GetFieldPath(handles,'raw',opt.data,'data'))
		%get the points
			p	= GetDataPosition(handles,p,p1,p2,p3);
		%get the data values
			k	= sub2ind(size(handles.raw.(opt.data).data),p(1),p(2),p(3));
			v	= handles.raw.(opt.data).data(k);
	else
		v	= [];
	end
%------------------------------------------------------------------------------%
function handles = RefreshFigure(handles)
%recalculate images based on the current position
	%set the window title
		if isempty(handles.name) && ~isempty(handles.raw.anat.path)
			set(handles.figMRIViewer,'Name',handles.raw.anat.path);
		else
			set(handles.figMRIViewer,'Name',handles.name);
		end
	%update the position info
		pIJK	= GetDataPosition(handles);
		pIPS	= GetDataPosition(handles,'out','space');
		set(handles.edtPosI,'String',num2str(pIJK(1)));
		set(handles.edtPosJ,'String',num2str(pIJK(2)));
		set(handles.edtPosK,'String',num2str(pIJK(3)));
		set(handles.edtPosLR,'String',num2str(pIPS(1)));
		set(handles.edtPosPA,'String',num2str(pIPS(2)));
		set(handles.edtPosIS,'String',num2str(pIPS(3)));
		
		vStat	= GetDataValue(handles,'data','stat');
		set(handles.txtStat,'String',num2str(vStat));
	%set the stat elements
		warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid');
		if ~isempty(handles.raw.stat.data)
			set(handles.edtOverlayMin,'String',num2str(handles.stat.min));
			set(handles.edtOverlayMax,'String',num2str(handles.stat.max));
			set(handles.sldOverlayMin,'Min',handles.raw.stat.min);
			set(handles.sldOverlayMin,'Max',handles.stat.max);
			set(handles.sldOverlayMax,'Min',handles.stat.min);
			set(handles.sldOverlayMax,'Max',handles.raw.stat.max);
			set(handles.sldOverlayMin,'Value',handles.stat.min);
			set(handles.sldOverlayMax,'Value',handles.stat.max);
		else
			set([handles.edtOverlayMin handles.edtOverlayMax handles.sldOverlayMin handles.sldOverlayMax],'Visible','off');
		end
	%get the image sizes
		[pSag,pAx,pCor]	= GetElementPosition([handles.axSaggital handles.axAxial handles.axCoronal]);
	%get the images
		handles.im.saggital	= StackImages(handles,[pSag.h pSag.w],'saggital');
		handles.im.axial	= StackImages(handles,[pAx.h pAx.w],'axial');
		handles.im.coronal	= StackImages(handles,[pCor.h pCor.w],'coronal');
	%redraw
		SetImage(handles.axSaggital,handles.im.saggital);
		SetImage(handles.axAxial,handles.im.axial);
		SetImage(handles.axCoronal,handles.im.coronal);
%------------------------------------------------------------------------------%
function im = StackImages(handles,s,strPlane,varargin)
		opt	= ParseArgs(varargin,...
				'anat'		, true	, ...
				'stat'		, true	, ...
				'crosshair'	, true	, ...
				'border'	, true	  ...
				);
	
	%get the anatomical image
		if opt.anat
			im	= GetAnatImage(handles,s,strPlane);
		else
			im	= NaN([s 3]);
		end
	%get the stat overlay
		if opt.stat
			[imStat,aStat]	= GetStatImage(handles,s,strPlane);
			im				= InsertImage(im,imStat,'alpha',aStat);
		end
	%add the cross hairs
		if opt.crosshair
			im	= AddCrossHair(handles,im,strPlane);
		end
	%insert a border
		if opt.border
			im	= imborder(im,'c',handles.param.border.c,'t',handles.param.border.t,'location','outside');
		end
%------------------------------------------------------------------------------%
function im = GetAnatImage(handles,s,strPlane)
	if ~isempty(handles.proc.anat)
		im	= GetImage(handles,handles.proc.anat,s,strPlane);
	else
		im	= NaN([s 3]);
	end
%------------------------------------------------------------------------------%
function [im,a] = GetStatImage(handles,s,strPlane)
	%get the stat image
		if ~isempty(handles.proc.stat)
			im	= GetImage(handles,handles.proc.stat,s,strPlane);
		else
			im	= NaN([s 3]);
		end
	%get the alpha image
		if ~isempty(handles.proc.a)
			a	= GetImage(handles,handles.proc.a,s,strPlane);
		else
			a	= 1;
		end
%------------------------------------------------------------------------------%
function im = AddCrossHair(handles,im,strPlane)
	%image size
		s	= size(im);
	%cross hair point
		pIm	= GetDataPosition(handles,'out',strPlane);
	%add the cross hair
		imCH	= MaskCrossHair('l',handles.param.crosshair.length,'t',handles.param.crosshair.t,'space',handles.param.crosshair.space);
		imCH	= g2rgb(imCH,'c',handles.param.crosshair.c);
		im		= InsertImage(im,imCH,pIm','tl','center');
%------------------------------------------------------------------------------
function im = GetImage(handles,d,s,strPlane,varargin)
	%get the image coordinates
		[y,x]	= Coordinates(s);
	%number of color planes
		nPlane	= size(d,4);
	%data points
		p	= GetDataPosition(handles,[y(:)'; x(:)'],'in',strPlane);
	%data indices
		nPoint	= size(p,2);
		c		= repmat(reshape(1:nPlane,1,1,[]),[1 nPoint 1]);
		p		= repmat(p,[1 1 nPlane]);
		k		= sub2ind(size(d),p(1,:,:),p(2,:,:),p(3,:,:),c(1,:,:));
	%construct the image
		im	= reshape(d(k),[s nPlane]);
%------------------------------------------------------------------------------%
function SetImage(h,im)
	image(im,'Parent',h);
	set(h,'XTick',[]);
	set(h,'YTick',[]);
	box(h,'off');
	set(h,'Visible','off');
%------------------------------------------------------------------------------%
function handles = SaveImage(handles,varargin)
	[strPathOut,opt]	= ParseArgs(varargin,[],...
							'type'	, 'all'	  ...
							);
	
	%get the image file
		strDescription	= 'view';
		switch lower(opt.type)
			case {'saggital','axial','coronal'}
				strDescription	= [opt.type ' ' strDescription];
		end
		
		strPathOut	= PromptFilePut(strPathOut,{'*.jpg;*.bmp','*.*'},['Save the current ' strDescription ' to file...'],{'Image Files','All Files'});
	
	%save the image
		if ~isempty(strPathOut)
			[pSag,pAx,pCor]	= GetElementPosition([handles.axSaggital handles.axAxial handles.axCoronal]);
			
			%get the images
					if ischar(opt.type)
						switch lower(opt.type)
							case 'all'
								opt.type	= {'saggital','axial','coronal'};
							otherwise
								opt.type	= ForceCell(opt.type);
						end
					end
					nType	= numel(opt.type);
					
					im	= [];
					for kT=1:nType
						switch opt.type{kT}
							case 'saggital'
								s	= [pSag.h pSag.w];
							case 'axial'
								s	= [pAx.h pAx.w];
							case 'coronal'
								s	= [pCor.h pCor.w];
						end
						sR	= s*600/s(1);
						
						im	= [im imresize(StackImages(handles,s,opt.type{kT}),sR,'bicubic')];
				end
			%save
				rgbWrite(im,strPathOut);
		end
%------------------------------------------------------------------------------%
function handles = SetAnat(handles,varargin)
	opt	= ParseArgs(varargin,...
			'anat'	, GetFieldPath(handles,'raw','anat')	, ...
			'draw'	, true									  ...
			);
	
	%load the data
		handles.raw.anat	= LoadData(opt.anat);
	%normalize
		prcMin				= handles.raw.anat.prc(1);
		prcMax				= handles.raw.anat.prc(2);
		handles.proc.anat	= MapValue(handles.raw.anat.data,prcMin,prcMax,0,1);
	%make it RGB
		handles.proc.anat	= g2rgb(handles.proc.anat);
	%redraw
		if opt.draw
			handles	= RefreshFigure(handles);
		end
%------------------------------------------------------------------------------%
function handles = SetStat(handles,varargin);
	opt	= ParseArgs(varargin,...
			'stat'	, GetFieldPath(handles,'raw','stat')	, ...
			'min'	, GetFieldPath(handles,'stat','min')	, ...
			'max'	, GetFieldPath(handles,'stat','max')	, ...
			'pal'	, GetFieldPath(handles,'stat','pal')	, ...
			'draw'	, true				  ...
			);
	
	%load the data
		handles.raw.stat		= LoadData(opt.stat);
	%set the new stat values
		if isempty(opt.min)
			opt.min	= handles.raw.stat.min;
		end
		if isempty(opt.max)
			opt.max	= handles.raw.stat.max;
		end

		handles.stat.min	= constrain(opt.min,handles.raw.stat.min,opt.max);
		handles.stat.max	= constrain(opt.max,opt.min,handles.raw.stat.max);
	%set the new palette
		handles.stat.pal	= opt.pal;
	%get the stat image/alpha
		[handles.proc.stat,handles.proc.a]	= deal(MapValue(handles.raw.stat.data,handles.stat.min,handles.stat.max,0,1));
		handles.proc.stat					= g2rgb(handles.proc.stat,'pal',handles.stat.pal);
	%redraw
		if opt.draw
			handles	= RefreshFigure(handles);
		end
%------------------------------------------------------------------------------%
function d	= LoadData(dIn)
	%get the data and transform matrix
		switch class(dIn)
			case 'char'	%path to data
				strPath	= dIn;
				
				switch lower(PathGetExt(dIn,'favor','nii.gz'))
					case {'nii','nii.gz'}
						d	= NIfTI.Read(dIn,'method','spm');
					otherwise
						error('Unsupported data file format.');
				end
				
				d.path	= strPath;
			case 'struct' %data struct already loaded
				if isfield(dIn,'data') && isfield(dIn,'mat') %NIfTI.Read
					d	= dIn;
				else
					error(['Unsupported data struct input.']);
				end
				
				d.path	= '';
			case 'double'
				if isempty(dIn)
					d.data	= [];
					d.mat	= [];
				else
					error('Unsupported data input.');
				end
				
				d.path	= '';
			otherwise
				error('Unsupported data input.');
		end
		
		d.data	= double(d.data);
	%get derived properties
		d.imat		= inv(d.mat);
		
		d.nd	= ndims2(d.data);
		d.s		= size2(d.data);
		d.np	= numel(d.data);
		b		= ones(d.nd~=0,d.nd~=0);
		
		d.extent.array	= [ones(d.nd,b) reshape(d.s,numel(d.s),b)];
		d.extent.space	= d.mat*[d.extent.array; b b];
		d.extent.space	= d.extent.space(b:3,:);
		d.extent.space	= [min(d.extent.space,[],2) max(d.extent.space,[],2)];
		
		d.min	= nanmin(reshape(d.data,d.np,b));
		d.max	= nanmax(reshape(d.data,d.np,b));
		d.prc	= prctileQuick(d.data,[0.5 99.5]);
