function sInfo = progress(varargin)
% progress
% 
% Description:	display a progress indicator
% 
% Syntax:	sInfo = progress(<options>)
% 
% In:
% 	<options>:
%		action:			('step') the action to take. one of the following:
%							init:	initialize the progress indicator
%							step:	step the progress indicator
%							end:	end the progress indicator
%		type:			('figure') the desired type of progress to show. one of
%						the following:
%							'figure':		show a GUI
%							'commandline':	display progress on the command line
%		name:			(<auto>) the name of the progress bar
%		total:			(<required when action is 'init'>) the last value in the
%						overall process
%		current:		(<auto>) the current value in the process
%		start:			(0) the first value in the current process
%		end:			(<total>) the last value in the current process (i.e. if
%						the current process only deals with a portion of the
%						overall process
%		step:			(1) the iteration step size
%		label:			(<name>) the label to show for the progress counter
%		status:			(<type>=='commandline') true to also show status
%						messages
%		status_offset:	(0) the offset for status messages
%		rate:			(10) the maximum refresh rate, in Hz
%		color:			('red') the color to use for the progress bar
%		width:			(400) the figure width
%		silent:			(false) true to suppress all output
% 
% Out:
% 	sInfo	- a struct of info
% 
% Note:	in most cases, input arguments are only needed on the first call to
%		progress. each subsequent call will step the progress indicator.
% 
% Example:
%	n	= 100;
%	progress('action','init','total',n,'label','doing something');
%	for k=1:n
%		progress;
%		pause(0.1);
%	end
% 
% Updated: 2015-04-17
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent ifo optDefault cOptDefault;

%current time
	tNow	= nowms;
%stack position, for status calls
	nStatus	= max(0,numel(dbstack)-1);
%initialize the output
	sInfo	= struct;

%process the input
	if isempty(optDefault)
		optDefault	= struct(...
						'action'		, 'step'	, ...
						'type'			, []		, ...
						'name'			, []		, ...
						'total'			, []		, ...
						'current'		, []		, ...
						'start'			, []		, ...
						'end'			, []		, ...
						'step'			, []		, ...
						'label'			, []		, ...
						'status'		, []		, ...
						'status_offset'	, []		, ...
						'rate'			, []		, ...
						'color'			, []		, ...
						'width'			, []		, ...
						'silent'		, []		, ...
						'opt_extra'		, struct	  ...
						);
		cOptDefault	= opt2cell(optDefault);
	end
	
	if isempty(varargin)
		opt	= optDefault;
	else
		opt	= ParseArgs(varargin,cOptDefault{:});
	
		if ~ischar(opt.action) || ~ismember(opt.action,{'init','step','end'})
			error('%s is not a valid action',opt.action);
		end
	end
	
%initialize the system
	if isempty(ifo) || ~ifo.system.initialized
		InitializeSystem;
	end

%get the indicator name
	if isempty(opt.name)
		opt.name	= GetDefaultIndicatorName;
	end

%did the user close the figure?
	if ~CheckFigure
		bDialog		= strcmp(ifo.param.type,'figure');
		bContinue	= askyesno('Progress bar closed. Continue?',...
						'dialog'	, bDialog		, ...
						'title'		, 'Continue?'	, ...
						'default'	, false			  ...
						);
		if ~bContinue
			ShutdownSystem;
			error('Aborted by user.');
		end
		
		ifo.figure.ignore	= true;
	end

%what should we do?
	switch opt.action
		case 'init'
			InitializeIndicator;
		case 'step'
			StepIndicator;
		case 'end'
			ShutdownIndicator;
	end

%update the system
	UpdateSystem;

%add some output
	sInfo.name		= opt.name;
	sInfo.ifo		= ifo;
	sInfo.opt_extra	= opt.opt_extra;


%------------------------------------------------------------------------------%
function InitializeSystem()
	%process inputs that affect all indicators
		opt	= optadd(opt,...
				'width'		, 400		, ...
				'type'		, 'figure'	, ...
				'rate'		, 10		  ...
				);
	
	%initialize the info struct
		InitializeInfoStruct;
	
	ifo.system.initialized	= true;
end
%------------------------------------------------------------------------------%
function InitializeInfoStruct()
	strType	= conditional(DisplayExists,opt.type,'commandline');
	
	ifo				= struct;
	ifo.name		= struct('caller',{{}},'name',{{}});
	ifo.param		= struct(...
						'type'		, strType		, ...
						'rate'		, opt.rate		  ...
						);
	ifo.width		= struct(...
						'figure'	, opt.width	, ...
						'spacer'	, 8			  ...
						);
	ifo.height		= struct(...
						'label'			, 21	, ...
						'bar'			, 21	, ...
						'inner_spacer'	, 0		, ...
						'outer_spacer'	, 8		  ...
						);
	ifo.system		= struct(...
						'initialized'	, false		, ...
						'changed'		, true		  ...
						);
	ifo.indicator	= struct;
	ifo.figure		= struct(...
						'handle'		, NaN	, ...
						'ignore'		, false	, ...
						'initialized'	, false	  ...
						);
	ifo.t			= struct(...
						'redraw'	, 0	  ...
						);
end
%------------------------------------------------------------------------------%
function UpdateSystem()
	if numel(fieldnames(ifo.indicator))==0
		ShutdownSystem;
	else
		%update some parameters
			if ~isempty(opt.rate)
				ifo.param.rate		= opt.rate;
			end
		
		%update the display
			UpdateDisplay;
		
		ifo.system.changed	= false;
	end
end
%------------------------------------------------------------------------------%
function ShutdownSystem()
	%shutdown the figure
		if FigureExists
			ShutdownFigure;
		end
	
	%reset the info struct
		ifo	= [];
end
%------------------------------------------------------------------------------%
function InitializeFigure()
	%mark any existing indicators as silent
		cIndicator	= fieldnames(ifo.indicator);
		nIndicator	= numel(cIndicator);
		
		for kI=1:nIndicator
			strIndicator	= cIndicator{kI};
			
			ifo.indicator.(strIndicator).silent	= true;
		end
	
	ifo.figure.handle	= figure(...
							'Color'			, 0.9*ones(1,3)	, ...
							'NumberTitle'	, 'off'			, ...
							'Name'			, ''			, ...
							'Resize'		, 'off'			, ...
							'Toolbar'		, 'none'		, ...
							'MenuBar'		, 'none'		  ...
							);
	
	ifo.figure.initialized	= true;
end
%------------------------------------------------------------------------------%
function UpdateDisplay()
	if tNow >= ifo.t.redraw || ifo.system.changed
		ifo.t.redraw	= tNow + 1000/ifo.param.rate;
		
		if UseFigure && FigureExists && ifo.system.changed
			SetFigurePosition;
		end
		
		UpdateIndicators;
		
		drawnow;
	end
end
%------------------------------------------------------------------------------%
function ShutdownFigure()
	ifo.figure.initialized	= false;
	
	close(ifo.figure.handle);
	
	drawnow;
end
%------------------------------------------------------------------------------%
function SetFigurePosition()
	%set the figure position
		hFigure	= CalculateFigureHeight;
		
		MoveElement(ifo.figure.handle,...
			'h'			, hFigure				, ...
			'w'			, ifo.width.figure		  ...
			);
		
		MoveElement(ifo.figure.handle,'center',true);
	
	%set the position of each of the indicator elements
		cIndicator	= fieldnames(ifo.indicator);
		nIndicator	= numel(cIndicator);
		
		kPos	= 0;
		for kI=1:nIndicator
			if ~ifo.indicator.(cIndicator{kI}).silent
				kPos	= kPos + 1;
				SetIndicatorPosition(cIndicator{kI},kPos);
			end
		end
end
%------------------------------------------------------------------------------%
function h = CalculateFigureHeight()
	nIndicator	= sum(structfun(@(x) ~x.silent,ifo.indicator));
	hIndicator	= ifo.height.label + ifo.height.inner_spacer + ifo.height.bar;
	h			= ifo.height.outer_spacer + nIndicator*(hIndicator + ifo.height.outer_spacer);
	hMin		= ifo.height.outer_spacer + hIndicator + ifo.height.outer_spacer;
	h			= max(hMin,h);
end
%------------------------------------------------------------------------------%
function b = CheckFigure()
	b	= FigureExists || ~UseFigure || ~ifo.figure.initialized || strcmp(opt.action,'init');
end
%------------------------------------------------------------------------------%
function b = UseFigure()
	b	= strcmp(ifo.param.type,'figure') && ~ifo.figure.ignore;
end
%------------------------------------------------------------------------------%
function b = FigureExists()
	b	= ishandle(ifo.figure.handle);
end
%------------------------------------------------------------------------------%
function b = DisplayExists()
	b	= ~isequal(get(0,'ScreenDepth'),0);
end
%------------------------------------------------------------------------------%
function InitializeIndicator()
	%process the inputs
		opt	= optadd(opt,...
				'start'			, 0			, ...
				'step'			, 1			, ...
				'label'			, opt.name	, ...
				'status_offset'	, 0			, ...
				'color'			, 'red'		, ...
				'silent'		, false		  ...
				);
		
		assert(~isempty(opt.total),'<total> option must be specified when initializing a progress indicator.');
		
		opt.current	= unless(opt.current,opt.start);
		
		if isempty(opt.status)
			opt.status	= ~strcmp(ifo.param.type,'figure');
		end
		
		opt.silent	= opt.silent || opt.total<=1;
	
	%initialize the figure
		if UseFigure && ~FigureExists && ~opt.silent
			InitializeFigure;
		end
	
	%initialize the indicator struct
		ifo.indicator.(opt.name)	= struct(...
			'tstart'		, tNow					, ...
			'changed'		, false					, ...
			'label'			, opt.label				, ...
			'total'			, opt.total				, ...
			'current'		, opt.current			, ...
			'start'			, opt.start				, ...
			'end'			, opt.end				, ...
			'step'			, opt.step				, ...
			'status'		, opt.status			, ...
			'status_offset'	, opt.status_offset		, ...
			'silent'		, opt.silent			  ...
			);
	
	%initialize the indicator figure elements
		if UseFigure && ~ifo.indicator.(opt.name).silent
			InitializeIndicatorElements(opt.name);
			SetIndicatorLabel(opt.name,opt.label);
			SetIndicatorColor(opt.name,opt.color);
		end
	
	%show a status update
		if ifo.indicator.(opt.name).status
			strStatus	= sprintf('started (%d total)',ifo.indicator.(opt.name).total);
			ShowStatus(opt.name,strStatus,0);
		end
end
%------------------------------------------------------------------------------%
function kEnd = GetIndicatorEnd(strIndicator)
	s	= ifo.indicator.(strIndicator);
	
	if isempty(s.end)
		kEnd	= s.total;
	else
		kEnd	= s.end;
	end
end
%------------------------------------------------------------------------------%
function StepIndicator()
	if isfield(ifo.indicator,opt.name)
		UpdateIndicatorParameters(opt.name);
		
		s	= ifo.indicator.(opt.name);
		
		if isempty(opt.current)
			next	= s.current + s.step;
		else
			next	= opt.current;
		end
		
		if next < GetIndicatorEnd(opt.name)
			ifo.indicator.(opt.name).changed	= next ~= s.current;
			ifo.indicator.(opt.name).current	= next;
		else
			ShutdownIndicator;
		end
	end
end
%------------------------------------------------------------------------------%
function ShutdownIndicator()
	if isfield(ifo.indicator,opt.name)
		s	= ifo.indicator.(opt.name);
		
		%show a status update
			if ifo.indicator.(opt.name).status
				tDiff		= tNow - s.tstart;
				strTime		= FormatTime(tDiff,'H:MM:SS');
				strStatus	= sprintf('finished (%s total)',strTime);
				ShowStatus(opt.name,strStatus,0);
			end
		
		%shutdown the indicator figure elements
			if UseFigure && ~s.silent
				ShutdownIndicatorElements(opt.name);
			end
		
		%remove the indicator struct
			ifo.indicator	= rmfield(ifo.indicator,opt.name);
		
		%should we keep the display open?
			if FigureExists && sum(structfun(@(x) ~x.silent,ifo.indicator))==0
				ShutdownFigure;
			end
	end
end
%------------------------------------------------------------------------------%
function UpdateIndicators()
	cIndicator	= fieldnames(ifo.indicator);
	nIndicator	= numel(cIndicator);
	
	for kI=1:nIndicator
		strIndicator	= cIndicator{kI};
		
		s	= ifo.indicator.(strIndicator);
		
		f		= (s.current - s.start) ./ (GetIndicatorEnd(strIndicator) - s.start);
		tRemain	= etd(f,s.tstart,tNow);
		
		lenTotal	= numel(num2str(s.total));
		tmpCurrent	= ['%' num2str(lenTotal) 'd'];
		strStatus	= sprintf([tmpCurrent '/%d (%5.2f%%, %s remaining)'],s.current,s.total,100*roundn(f,-4),tRemain);
		
		if s.changed
			if UseFigure && ~s.silent
				set(s.h.bar,'XData',[0;0;f;f]);
				set(s.h.info,'String',strStatus);
			end
			
			if s.status
				ShowStatus(strIndicator,strStatus,1);
			end
			
			ifo.indicator.(strIndicator).changed	= false;
		end
	end
end
%------------------------------------------------------------------------------%
function UpdateIndicatorParameters(strIndicator)
	if ~isempty(opt.label)
		SetIndicatorLabel(strIndicator,opt.label);
	end
	if ~isempty(opt.total)
		ifo.indicator.(strIndicator).total	= opt.total;
	end
	if ~isempty(opt.start)
		ifo.indicator.(strIndicator).start	= opt.start;
	end
	if ~isempty(opt.end)
		ifo.indicator.(strIndicator).end	= opt.end;
	end
	if ~isempty(opt.step)
		ifo.indicator.(strIndicator).step	= opt.step;
	end
	if ~isempty(opt.status)
		ifo.indicator.(strIndicator).status	= opt.status;
	end
	if ~isempty(opt.status_offset)
		ifo.indicator.(strIndicator).status_offset	= opt.status_offset;
	end
	if ~isempty(opt.color)
		SetIndicatorColor(strIndicator,opt.color);
	end
end
%------------------------------------------------------------------------------%
function InitializeIndicatorElements(strIndicator)
	%create the elements
		h.label	= uicontrol(ifo.figure.handle,...
					'Style'		, 'text', ...
					'String'	, ''	  ...
					);
		h.axes	= axes;
		h.bar	= patch([0;0;0;0],[0;1;1;0],[0 0 0]);
		h.info	= text(0,0.5,'');
	
	%set some element parameters
		set(h.label,'Units','pixels');
		set(h.label,'FontSize',10);
		set(h.label,'BackgroundColor',get(ifo.figure.handle,'Color'));
		set(h.label,'FontWeight','bold');
		
		set(h.axes,'Units','pixels');
		set(h.axes,'XTick',[]);
		set(h.axes,'YTick',[]);
		set(h.axes,'Box','on');
		set(h.axes,'XLim',[0 1]);
		set(h.axes,'YLim',[0 1]);
	
	ifo.indicator.(strIndicator).h	= h;
	
	ifo.system.changed	= true;
end
%------------------------------------------------------------------------------%
function ShutdownIndicatorElements(strIndicator)
	h	= ifo.indicator.(strIndicator).h;
	
	delete(h.label);
	delete(h.axes);
	
	ifo.system.changed	= true;
end
%------------------------------------------------------------------------------%
function SetIndicatorLabel(strIndicator,strLabel)
	ifo.indicator.(strIndicator).label	= strLabel;
	
	if ~ifo.indicator.(strIndicator).silent
		set(ifo.indicator.(strIndicator).h.label,'String',strLabel);
	end
end
%------------------------------------------------------------------------------%
function SetIndicatorColor(strIndicator,col)
	ifo.indicator.(strIndicator).color	= col;
	
	if ~ifo.indicator.(strIndicator).silent
		set(ifo.indicator.(strIndicator).h.bar,'FaceColor',str2rgb(col));
	end
end
%------------------------------------------------------------------------------%
function SetIndicatorPosition(strIndicator,kIndicator)
	h	= ifo.indicator.(strIndicator).h;
	
	wElement	= ifo.width.figure - 2*ifo.width.spacer;
	hIndicator	= ifo.height.label + ifo.height.inner_spacer + ifo.height.bar;
	tLabel		= ifo.height.outer_spacer + (kIndicator-1)*(hIndicator + ifo.height.outer_spacer);
	tBar		= tLabel + ifo.height.label + ifo.height.inner_spacer;
	
	%set the label position
		MoveElement(h.label,...
			'l'	, ifo.width.spacer	, ...
			't'	, tLabel			, ...
			'w'	, wElement			, ...
			'h'	, ifo.height.label	  ...
			);
	%set the bar position
		MoveElement(h.axes,...
			'l'	, ifo.width.spacer	, ...
			't'	, tBar				, ...
			'w'	, wElement			, ...
			'h'	, ifo.height.bar	  ...
			);
end
%------------------------------------------------------------------------------%
function ShowStatus(strIndicator,strStatus,nLevel)
	strLabel	= ifo.indicator.(strIndicator).label;
	nOffset		= ifo.indicator.(strIndicator).status_offset;
	nIndent		= nStatus + nLevel;
	
	strStatus	= sprintf('%s: %s',strLabel,strStatus); 
	status(strStatus,nIndent,'time',tNow,'noffset',nOffset,'silent',ifo.indicator.(strIndicator).silent);
end
%------------------------------------------------------------------------------%
function strName = GetDefaultIndicatorName()
	sStack	= dbstack(2);
	
	if isempty(sStack)
		strName	= 'MATLABRoot';
	else
		strCaller	= join({sStack.name},'_');
		kCaller		= find(strcmp(ifo.name.caller,strCaller));
		
		if ~isempty(kCaller)
			strName	= ifo.name.name{kCaller};
		else
			%make a valid field name
				strName	= str2fieldname(strCaller);
		
			%make sure we're not too long
				if numel(strName)>63
					strName	= sprintf('%s_%s',strName(1:54),str2hash(strName(55:end),'output','string'));
				end
			
			%add a record of the name
				ifo.name.caller{end+1}	= strCaller;
				ifo.name.name{end+1}	= strName;
		end
	end
end
%------------------------------------------------------------------------------%

end
