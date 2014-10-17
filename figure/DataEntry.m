function x = DataEntry(cName,varargin)
% DataEntry
% 
% Description:	gui to enter data
% 
% Syntax:	x = DataEntry(cName,<options>)
% 
% In:
% 	cName	- a cell of the names of data to enter
%	<options>:
%		title:		(<auto>) the title of the figure
%		default:	(<none>) a cell of default values
%		width:		(<auto>) the figure width
%		output:		('cell') either 'cell' or 'struct' to specify how to format
%					the data
%		em:			(<none>) a logical array specifying which data items to
%					emphasize
% 
% Out:
% 	x	- the entered data, or an empty array if the user canceled
% 
% Updated: 2012-07-30
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%format the input
	opt	= ParseArgs(varargin,...
			'title'		, 'Enter Data'	, ...
			'default'	, []			, ...
			'width'		, []			, ...
			'output'	, 'cell'		, ...
			'em'		, []			  ...
			);
	
	cName	= ForceCell(cName);
	nItem	= numel(cName);
	
	if isempty(opt.default)
		opt.default	= repmat({''},[nItem 1]);
	else
		opt.default	= reshape(cellfun(@(x) tostring(x),ForceCell(opt.default),'UniformOutput',false),[],1);
	end
	
	opt.default	= [opt.default; repmat(opt.default(end),[nItem-numel(opt.default) 1])];
	bEval		= cellfun(@ischar,opt.default);
	
	opt.output	= CheckInput(opt.output,'output',{'cell','struct'});
	
	opt.em	= unless(opt.em,false(nItem,1));
	
if isempty(cName)
	x	= [];
	return;
end

%initialize the figure
	h	= InitializeFigure;
%add the data entry elements
	AddEntryElements;
%resize everything
	hItem	= 0;
	nPer	= 0;
	
	ResizeElements;
%set the starting position
	SetPosition(1);
%set focus on the first edit box
	uicontrol(h.hEdit(1));
%wait until the user closes the figure
	x	= [];
	uiwait(h.hF);
%process the data
	if ~isempty(x)
		bEmpty				= cellfun(@isempty,x);
		x(bEval & ~bEmpty)	= cellfun(@eval,x(bEval & ~bEmpty),'UniformOutput',false);
		
		switch opt.output
			case 'cell'
			%nothing to do
			case 'struct'
				cStructName	= cellfun(@str2fieldname,reshape(cName,[],1),'UniformOutput',false);
				x			= cellfun(@(x) {x},x,'UniformOutput',false);
				
				cStruct	= [cStructName'; x'];
				x		= struct(cStruct{:});
		end
	end

%------------------------------------------------------------------------------%
function h = InitializeFigure
	%open the figure;
		h.hF	= figure('Units','pixels','Name',opt.title,'NumberTitle','off');
		set(h.hF,'MenuBar','none','Toolbar','none');
	%add the OK/Cancel buttons
		h.hOK		= uicontrol(h.hF,'Style','pushbutton','String','OK','Units','pixels','Callback',@DE_OK);
		h.hCancel	= uicontrol(h.hF,'Style','pushbutton','String','Cancel','Units','pixels','Callback',@DE_Cancel);
	%add the scroll bar
		h.hScroll	= uicontrol(h.hF,'Style','slider','Units','pixels','Callback',@DE_Scroll);
end
%------------------------------------------------------------------------------%
function AddEntryElements
	[h.hLabel,h.hEdit]	= deal(zeros(nItem,1));
	
	colB	= get(h.hF,'Color');
	
	for kI=1:nItem
		h.hLabel(kI)	= uicontrol(h.hF,'Style','text','String',[tostring(cName{kI}) ':'],'Units','pixels','Background',colB);
		
		e	= get(h.hLabel(kI),'Extent');
		p	= get(h.hLabel(kI),'Position');
		set(h.hLabel(kI),'Position',[p(1:2) e(3) p(4)]);
		
		colBack	= conditional(opt.em(kI),[1 0.5 0.5],[1 1 1]);
		
		h.hEdit(kI)		= uicontrol(h.hF,'Style','edit','String',opt.default{kI},'Units','pixels','Background',colBack,'HorizontalAlignment','left');
	end
end
%------------------------------------------------------------------------------%
function ResizeElements
	wScroll		= 18;
	hPad		= 4;
	wMinEdit	= 100;
	
	pOK		= get(h.hOK,'Position');
	pCancel	= get(h.hCancel,'Position');
	pScroll	= get(h.hScroll,'Position');
	
	%get the maximum text width
		wLabel	= max(arrayfun(@(h) subsref(get(h,'Position'),struct('type','()','subs',{{3}})),h.hLabel));
	%get the needed figure height
		hButton	= pOK(4);
		
		hLabel	= max(arrayfun(@(h) subsref(get(h,'Position'),struct('type','()','subs',{{4}})),h.hLabel));
		hEdit	= max(arrayfun(@(h) subsref(get(h,'Position'),struct('type','()','subs',{{4}})),h.hEdit));
		hItem	= max(hLabel,hEdit) + hPad;
		
		hNeeded	= hItem*nItem+hButton;
	%set the figure position
		hNo		= 150;
		mp		= get(0,'MonitorPositions');
		hMP		= mp(1,4);
		wMP		= mp(1,3);
		hMax	= hMP - hNo;
		
		hFig	= min(hMax,hNeeded);
		wFig	= unless(opt.width,max(wMP/2,wLabel+wMinEdit+wScroll));
		
		nPer	= floor((hFig-hButton)/hItem);
		
		set(h.hF,'Position',[wMP-wFig hMP-hFig wFig hFig]);
	%set the static item positions
		set(h.hOK,'Position',[wFig-pOK(3) 0 pOK(3:4)]);
		set(h.hCancel,'Position',[wFig-pOK(3)-pCancel(3) 0 pCancel(3:4)]);
		set(h.hScroll,'Position',[wFig-wScroll pOK(4) wScroll hFig-pOK(4)]);
	%set the item horizontal positions
		for kI=1:nItem
			pLabel	= get(h.hLabel(kI),'Position');
			set(h.hLabel(kI),'Position',[wLabel-pLabel(3) 0 pLabel(3:4)]);
			
			pEdit	= get(h.hEdit(kI),'Position');
			set(h.hEdit(kI),'Position',[wLabel 0 wFig-wScroll-wLabel pEdit(4)]);
		end
	%set the scroll parameters
		if nItem-nPer>0
			sMin	= 1;
			sMax	= max(1,nItem-nPer+1);
			
			sldS	= 1/(sMax-1);
			sldB	= min(1,nPer/(sMax-1));
			
			set(h.hScroll,'Min',sMin,'Max',sMax,'SliderStep',[sldS sldB],'Value',1);
		else
			set(h.hScroll,'Visible','off');
		end
end
%------------------------------------------------------------------------------%
function SetPosition(kItem)
	pFig	= get(h.hF,'Position');
	hFig	= pFig(4);
	
	for kI=1:kItem-1
		MoveItem(kI,-1);
	end
	for kI=kItem:kItem+nPer-1
		MoveItem(kI,hFig-(kI-kItem+1)*hItem);
	end
	for kI=kItem+nPer:nItem
		MoveItem(kI,-1);
	end
	
	set(h.hScroll,'Value',nItem-nPer-kItem+2);
end
%------------------------------------------------------------------------------%
function MoveItem(k,t)
	if t<0
		set(h.hLabel(k),'Visible','off');
		set(h.hEdit(k),'Visible','off');
	else
		pLabel	= get(h.hLabel(k),'Position');
		pEdit	= get(h.hEdit(k),'Position');
		
		set(h.hLabel(k),'Position',[pLabel(1) t pLabel(3:4)],'Visible','on');
		set(h.hEdit(k),'Position',[pEdit(1) t pEdit(3:4)],'Visible','on');
	end
end
%------------------------------------------------------------------------------%

%------------------------------------------------------------------------------%
function DE_Scroll(hObject,event)
	SetPosition(nItem-nPer-round(get(hObject,'Value'))+2);
end
%------------------------------------------------------------------------------%
function DE_OK(hObject,event)
	x	= cell(nItem,1);
	
	for kI=1:nItem
		x{kI}	= get(h.hEdit(kI),'String');
	end
	
	close(h.hF);
end
%------------------------------------------------------------------------------%
function DE_Cancel(hObject,event)
	close(h.hF);
end
%------------------------------------------------------------------------------%


end
