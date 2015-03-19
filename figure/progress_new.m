function s = progress(varargin)
% progress
% 
% Description:	display a progress indicator
% 
% Syntax:	s = progress(<options>)
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
%		status:			(true) true to also show status messages
%		status_offset:	(0) the offset for status messages
%		rate:			(10) the maximum refresh rate, in Hz
%		color:			('red') the color to use for the progress bar
%		width:			(400) the figure width
%		silent:			(false) true to suppress all output
% 
% Out:
% 	s	- a struct of info
% 
% Note:	in most cases, input arguments are only needed on the first call to
%		progress. each subsequent call will step the progress indicator
% 
% Example:
%	n	= 100;
%	progress('action','init','total',n,'label','doing something');
%	for k=1:n
%		progress;
%	end
% 
% Updated: 2015-03-19
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent ifo;

%current time
	tNow	= nowms;
%initialize the output
	s		= struct;

%process the input
	opt	= ParseArgs(varargin,...
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
			'silent'		, false		  ...
			);
	
	if isempty(opt.name)
		opt.name	= GetDefaultIndicatorName;
	end

%initialize or update the system
	UpdateSystem;

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
	opt.action	= CheckInput(opt.action,'action',{'init','step','end'});
	switch opt.action
		case 'init'
			InitIndicator;
		case 'step'
			StepIndicator;
		case 'end'
			ShutdownIndicator;
	end

%add some output
	s.name		= opt.name;
	s.ifo		= ifo;
	s.opt_extra	= opt.opt_extra;


%------------------------------------------------------------------------------%
function InitializeInfoStruct
	strType	= conditional(DisplayExists,unless(opt.type,'figure'),'commandline');
	
	ifo				= struct;
	ifo.param		= struct(...
						'type'	, strType	, ...
						'rate'	, []		  ...
						);
	ifo.system		= struct(...
						'initialized'	, false	  ...
						);
	ifo.indicator	= struct;
	ifo.figure		= struct(...
						'handle'	, []	, ...
						'width'		, []	, ...
						'changed'	, true	, ...
						'ignore'	, false	  ...
						);
	ifo.t			= struct(...
						'redraw'	, 0	  ...
						);
end
%------------------------------------------------------------------------------%
function InitializeSystem
	%process inputs that affect all indicators
		opt	= optadd(opt,...
				'type'		, 'figure'	, ...
				'rate'		, 10		, ...
				'silent'	, false		  ...
				);
	
	%initialize the info struct
		InitializeInfoStruct;
		
	%initialize the figure
		if strcmp(ifo.param.type,'figure')
			UpdateFigure;
		end
	
	ifo.system.initialized	= true;
end
%------------------------------------------------------------------------------%
function UpdateSystem()
	if isempty(ifo) || ~ifo.system.initialized
		InitializeSystem;
	end
	
	if ~isempty(opt.rate)
		ifo.param.rate		= opt.rate;
	end
	if ~isempty(opt.silent)
		ifo.param.silent	= opt.silent;
	end
	
	%***
end
%------------------------------------------------------------------------------%
function ShutdownSystem
	if strcmp(ifo.param.type,'figure')
		ShutdownFigure;
	end
	
	InitializeInfoStruct;
end
%------------------------------------------------------------------------------%
function InitializeFigure
	opt	= optadd(opt,...
			'width'	, unless(ifo.figure.width,400)	  ...
			);
	
	ifo.figure.handle	= openfig('blank.fig');
	set(ifo.figure.handle,'visible','on');
end
%------------------------------------------------------------------------------%
function UpdateFigure
	if ~ifo.figure.ignore
		if ~FigureExists
			InitializeFigure;
		end
		
		if ~isempty(opt.width)
			ifo.figure.width	= opt.width;
			
			UpdateFigurePosition;
		end
	end
end
%------------------------------------------------------------------------------%
function ShutdownFigure
	if FigureExists
		close(ifo.figure.handle);
	end
end
%------------------------------------------------------------------------------%
function b = CheckFigure
	b	= ~strcmp(ifo.param.type,'figure') || ifo.figure.ignore || FigureExists;
end
%------------------------------------------------------------------------------%
function UpdateFigurePosition
	MoveElement(ifo.figure.handle,'w',ifo.figure.width,'l',0);
% 	MoveElement(ifo.figure.handle,...
% 				'w'			, ifo.figure.width	, ...
% 				'center'	, true				  ...
% 				);
end
%------------------------------------------------------------------------------%
function b = FigureExists
	b	= notfalse(ishandle(ifo.figure.handle));
end
%------------------------------------------------------------------------------%
function b = DisplayExists
	b	= ~isequal(get(0,'ScreenDepth'),0);
end
%------------------------------------------------------------------------------%
function InitIndicator 
	
end
%------------------------------------------------------------------------------%
function StepIndicator 
	
end
%------------------------------------------------------------------------------%
function ShutdownIndicator 
	
end
%------------------------------------------------------------------------------%
function strName = GetDefaultIndicatorName
	strName	= caller(2,'all',true);	%get the stack path
	
	if isempty(strName)
		strName	= 'MATLABRoot';
	else
		strName	= str2fieldname(strName);	%make a valid field name
	
		%make sure we're not too long
		if numel(strName)>63
			strName	= sprintf('%s_%s',strName(1:54),str2hash(strName(55:end),'output','string'));
		end
	end
end
%------------------------------------------------------------------------------%

end
