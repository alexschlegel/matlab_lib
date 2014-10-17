function varargout = plottrace(varargin)
% plottrace
% 
% Description:	plot data and choose a number of points on it
% 
% Syntax:	[p,kP,handles] = plottrace(<alexplot inputs>,<options>)
% 
% In:
% 	<alexplot inputs>	- see the inputs to alexplot
%	<options>			- optionally specify the following options:
%		'npoints':	the number of points to select before automatically
%					returning (no limit)
%		'maximize':	true to maximize the plot to fit the screen (false)
%		'close':	true to close the plot after all points have been selected
%					(true)
% 
% Out:
% 	p		- an Nx2 array of the data points selected as (x,y) pairs
%	kP		- an N-length vector of the indices of the points chosen
%	handles	- the handles struct
% 
% Updated:	2009-02-25
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plottrace_OpeningFcn, ...
                   'gui_OutputFcn',  @plottrace_OutputFcn, ...
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


% --- Executes just before plottrace is made visible.
function plottrace_OpeningFcn(hObject, eventdata, handles, varargin)
	% This function has no output args, see OutputFcn.
	% hObject    handle to figure
	% eventdata  reserved - to be defined in a future version of MATLAB
	% handles    structure with handles and user data (see GUIDATA)
	% varargin   command line arguments to plottrace (see VARARGIN)
	[x,y,opt]	= ParseArgs(varargin,[],[],	'npoints',-1,...
												'maximize',false,...
												'close',true,...
												'title',' ');
	if isequal(opt.title,' ')
		varargin	= [varargin {'title' ' '}];
	end
	
	handles.opt	= opt;
	
	%get the plot data
		x	= varargin{1};
		switch class(x)
			case 'cell'
				x	= x{1};
			otherwise
		end
		handles.x	= x;
		
		y	= varargin{2};
		switch class(y)
			case 'cell'
				y	= y{1};
			otherwise
		end
		handles.y	= y;
	
	%plot the data
		handles.plotdata		= alexplot(varargin{:},'location',handles.axPlot);
		handles.plotdata.title	= get(handles.plotdata.hTitle,'String');
		if handles.opt.maximize
			[wScreen,hScreen]	= GetScreenResolution;
			set(handles.figPlotTrace,'Position',[0 0 wScreen hScreen]);
			movegui(handles.figPlotTrace,'northwest');
		end
		
	%add the axes that will accept user clicks
		handles.plotdata.hAClick	= axes;
		linkaxes([handles.plotdata.hA handles.plotdata.hAClick]);
		
		set(handles.plotdata.hAClick,'Color','none');
		set(handles.plotdata.hAClick,'Position',get(handles.plotdata.hA,'Position'));
		%set(handles.plotdata.hAClick,'XLim',get(handles.plotdata.hA,'XLim'));
		%set(handles.plotdata.hAClick,'YLim',get(handles.plotdata.hA,'YLim'));
		set(handles.plotdata.hAClick,'xTick',[]);
		set(handles.plotdata.hAClick,'yTick',[]);
		hold(handles.plotdata.hA,'on');
		
	%set callback functions
		set(handles.plotdata.hAClick,'ButtonDownFcn','plottrace(''AddPoint'',gcbo,[],guidata(gcbo));');
		set(handles.figPlotTrace,'KeyPressFcn','plottrace(''KeyPress'',gcbo,[],guidata(gcbo));');
		set(handles.figPlotTrace,'WindowButtonMotionFcn','plottrace(''MouseMove'',gcbo,[],guidata(gcbo));');
		set(handles.figPlotTrace,'CloseRequestFcn','plottrace(''CloseRequest'',gcbo,[],guidata(gcbo));');
	
	%initialize the point handles struct
		handles.plotdata.hPoint	= [];
	
	%prepare the output variable
		handles.output{1}	= zeros(0,2);
		handles.output{2}	= [];
		
	%update the plot title
		UpdateTitle(handles);
		
	%get the original plot bounds
		handles.plotdata.orig.xLim	= get(handles.plotdata.hA,'XLim');
		handles.plotdata.orig.yLim	= get(handles.plotdata.hA,'YLim');
	
	%update handles structure
		guidata(hObject, handles);
		
	% UIWAIT makes plottrace wait for user response (see UIRESUME)
		uiwait(handles.figPlotTrace);
		
% --- Outputs from this function are returned to the command line.
function varargout = plottrace_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
	varargout = [handles.output,{handles}];
	
	hold(handles.plotdata.hA,'off');

	%delete the plot
		if handles.opt.close
			delete(handles.figPlotTrace);
		end

%------------------------------------------------------------------------------%
function AddPoint(hObject, eventdata, handles, varargin)
	%get the mouse position
		mPos	= get(gca,'CurrentPoint');
		mType	= get(gcf,'SelectionType');
		
	switch mType
		case {'normal','open'}	%add a point
			%find the plot value closest to the mouse
				d			= dist([reshape(handles.x,[],1) reshape(handles.y,[],1)],mPos(1,1:2));
				[dMin,kPos]	= min(d);
				x			= handles.x(kPos);
				y			= handles.y(kPos);
			%was this point already marked?
				if ~any(handles.output{1}(:,1)==x & handles.output{1}(:,2)==y)						
					%add the point to the output vector
						handles.output{1}	= [handles.output{1}; x y];
						handles.output{2}	= [handles.output{2} kPos];
					%add the point to the plot
						handles.plotdata.hPoint	= [handles.plotdata.hPoint;plot(handles.plotdata.hA,x,y,'bx','LineWidth',10)];
				end
		case 'alt'		%remove a point
			if numel(handles.output{2})
				%find the point closest to the mouse
					d			= dist(handles.output{1},mPos(1,1:2));
					[dMin,kPos]	= min(d);
				%delete that point
					handles.output{1}(kPos,:)		= [];
					handles.output{2}(kPos)			= [];
					delete(handles.plotdata.hPoint(kPos));
					handles.plotdata.hPoint(kPos)	= [];
			end
	end
	
	UpdateTitle(handles);
	
	%update handles structure
		guidata(hObject, handles);
	
	%see if we've reached the specified number of points
		if handles.opt.npoints~=-1 && size(handles.output{1},1)>=handles.opt.npoints
			if handles.opt.close
				pause(0.5);
			end
			CloseRequest(hObject,eventdata,handles);
		end
%------------------------------------------------------------------------------%
function KeyPress(hObject, eventdata, handles, varargin)
	%get mouse and key info
		mPos	= get(gca,'CurrentPoint');
		x		= mPos(1,1);
		y		= mPos(1,2);
		chr		= get(gcf,'CurrentCharacter');
		
	%zoom factor
		zFact	= 2;
		
	switch lower(chr)
		case 'i'	%zoom in
			handles	= PlotZoom(handles,zFact,x,y);
		case 'o'	%zoom out
			handles	= PlotZoom(handles,1/zFact,x,y);
		case 'r'
			handles	= PlotReset(handles);
	end
%------------------------------------------------------------------------------%
function MouseMove(hObject, eventdata, handles, varargin)
	
%------------------------------------------------------------------------------%
function CloseRequest(hObject, eventdata, handles, varargin)
	uiresume(handles.figPlotTrace);
%------------------------------------------------------------------------------%
function UpdateTitle(handles)
	nSelected	= numel(handles.output{2});
	strInfo		= ['(mouse L/R: add/delete; key I/O: zoom in/out; key R: reset bounds; ' num2str(nSelected) ' points selected)'];
	set(handles.plotdata.hTitle,'String',[handles.plotdata.title 10 strInfo]);
%------------------------------------------------------------------------------%
function handles = PlotZoom(handles,zFact,x,y)
%zoom by zFact at (x,y)
	%get the current plot limits
		hA		= handles.plotdata.hA;
		xLim	= get(hA,'XLim');
		yLim	= get(hA,'YLim');
	%get the fractional position of the zoom point
		fX	= (x-xLim(1))/(xLim(2)-xLim(1));
		fY	= (y-yLim(1))/(yLim(2)-yLim(1));
	%get the new size of the window
		xRng	= range(xLim)/zFact;
		yRng	= range(yLim)/zFact;
	%get the new limits
		xLim	= x + [-xRng*fX xRng*(1-fX)];
		yLim	= y + [-yRng*fY yRng*(1-fY)];
	%set the limits
		set(hA,'XLim',xLim);
		set(hA,'YLim',yLim);
		
%------------------------------------------------------------------------------%
function handles = PlotReset(handles)
%reset the zoom bounds
	set(handles.plotdata.hA,'XLim',handles.plotdata.orig.xLim);
	set(handles.plotdata.hA,'YLim',handles.plotdata.orig.yLim);
%------------------------------------------------------------------------------%
