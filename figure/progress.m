function varargout = progress(varargin)
% progress
% 
% Description:	display a progress bar.
% 
% Syntax:	[strName,nStatus,optExtra] = progress(n,<options>) OR
%			[strName,nStatus,optExtra] = progress([p]=<last p + one step>,<options>) OR
%			[strName,nStatus,optExtra] = progress(strOperation)
% 
% In:
%	n				- the number of iterations in the current process
% 	p				- the current iteration value
%	strOperation	- one of the following strings:
%						'close':	close and reset the progress figure
%						'end':		end the current progress counter
%	<options>:
%		type:		('figure') the type of progress to show.  this automatically
%					becomes 'commandline' if MATLAB is not in a graphic                                                            
%					environment:
%						'figure':		show a GUI
%						'commandline':	display progress on the command line
%		log:		(<true if type is commandline>) true to log the progress to
%					a file in the user's home directory
%		n:			(<last n>) number of iterations in the current process
%		pstart:		(0) the first value in the process
%		pend:		(pstart+n) the last value in the process
%		ptotal:		(pend) the last value in the overall process
%		name:		(<auto>) the name of the progress bar
%		label:		(<name>) label for the progress counter
%		status:		(true) true to also show a status
%		noffset:	(0) status n offset
%		rate:		(10) maximum refresh rate (Hz)
%		color:		([1 0 0]) the color to use for the progress bar
%		width:		(400) width of the figure
%		silent:		(false) true to suppress the progress bar
% 
% Out:
%	strName		- the name of the progress bar
%	nStatus		- the status offset if a status was shown
%	optExtra	- an options struct of options that were specified by the user
%				  but not by this function
%
% Note:	on the first call to progress, call using the first syntax.
% 
% Updated:	2015-03-11
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%current time
	tNow	= nowms;
%initialize the output
	[strName,nStatus]	= deal([]);

%parse the input
	[v,opt]	= ParseArgs(varargin,[],...
				'debug'		, false				, ...
				'type'		, []				, ...
				'log'		, []				, ...
				'n'			, []				, ...
				'p'			, []				, ...
				'pstart'	, 0					, ...
				'pend'		, []				, ...
				'ptotal'	, []				, ...
				'name'		, GetDefaultName	, ...
				'label'		, []				, ...
				'status'	, true				, ...
				'noffset'	, 0					, ...
				'rate'		, 10				, ...
				'color'		, [1 0 0]			, ...
				'width'		, 400				, ...
				'silent'	, []				  ...
				);
	
	bEmptyLabel	= isempty(opt.label);
	if bEmptyLabel
		opt.label	= opt.name;
	end
	opt.name	= str2fieldname(opt.name);
	opt.color	= im2double(opt.color);

%struct to store info between calls to progress
	persistent ifo;
	if opt.debug
		varargout	= {ifo};
		return;
	end
	if ~IsInited
		InitAll;
	end

%should we log to a file?
	opt.log	= unless(opt.log,strcmp(ifo.type,'commandline'));
	
%did the user close the figure?
	if ~CheckFigure
		bDialog		= strcmp(ifo.type,'figure');
		bContinue	= askyesno('Progress bar close. Continue?',...
						'dialog'	, bDialog		, ...
						'title'		, 'Continue?'	, ...
						'default'	, false			  ...
						);
		if ~bContinue
			ClearAll;
			error('Aborted by user.');
		end
		
		ifo.bSkipFigure	= true;
	end

%perform an action depending on the call syntax used
	if isa(v,'char')	%operation string passed
		switch lower(v)
			case 'close'
				ClearAll;
			case 'end'
				ClearProgress(opt.name);
			otherwise
				error(sprintf('"%s" is not a valid operation.',v));
		end
	elseif ~IsProgress(opt.name) %first call to progress
		opt.n	= conditional(isempty(v),opt.n,v);
		
		InitProgress(opt.name);
	else %step an existing progress
		opt.p	= conditional(isempty(v),opt.p,v);
		
		StepProgress(opt.name);
	end

%redraw
	if ~notfalse(opt.silent)
		Redraw;
	end

%process output
	if nargout
		varargout	= {opt.name, nStatus, opt.opt_extra};
	end


%------------------------------------------------------------------------------%
function Redraw
	if IsInited
		cProgress	= fieldnames(ifo.progress);
		nProgress	= numel(cProgress);
		
		if nProgress==0
			ClearAll;
		elseif tNow>=ifo.tRedraw + 1000/opt.rate
			ifo.tRedraw	= tNow;
			
			bFigure	= strcmp(ifo.type,'figure');
			if bFigure && ~ifo.bSkipFigure
				%make sure the figure elements exist
					for kP=1:nProgress
						if ~ifo.progress.(cProgress{kP}).silent && ~ifo.progress.(cProgress{kP}).bElementInit
							InitProgressElement(cProgress{kP});
						end
					end
				%reposition everything if necessary
					if StructureChanged
						pxPadEdge	= 10;
						pxPadInner	= 0;
						pxPadInter	= 8;
						hLabel		= 21;
						hBar		= 21;
						hProgress	= hLabel+pxPadInner+hBar+pxPadInter;
						
						nProgressShow	= sum(structfun(@(x) ~x.silent,ifo.progress));
						
						pFigure	= MoveElement(ifo.h,'h',nProgressShow*hProgress+2*pxPadEdge,'t',ifo.pFigure.t,'l',ifo.pFigure.l);
						
						kPShow	= 0;
						for kP=1:nProgress
							if ~ifo.progress.(cProgress{kP}).silent
								kPShow	= kPShow+1;
								
								pLabel	= MoveElement(ifo.progress.(cProgress{kP}).hLabel,'l',pxPadEdge,'w',pFigure.w-2*pxPadEdge,'h',hLabel,'t',(kPShow-1)*hProgress+pxPadEdge);
								pAxes	= MoveElement(ifo.progress.(cProgress{kP}).hAxes,'l',pxPadEdge,'w',pFigure.w-2*pxPadEdge,'h',hBar,'t',pLabel.t+pLabel.h+pxPadInner);
							end
						end
					end
				%update progress bars
					for kP=1:nProgress
						if ~ifo.progress.(cProgress{kP}).silent
							f		= ProgressFraction(cProgress{kP});
							
							set(ifo.progress.(cProgress{kP}).hPatch,'XData',[0;0;f;f]);
							set(ifo.progress.(cProgress{kP}).hInfo,'String',ProgressStatus(cProgress{kP}));
						end
					end
				%draw!
					drawnow;
			end
			
			%also show a status message?
				if IsProgress(opt.name) && Changed
					bSilent	= bFigure || ifo.progress.(opt.name).silent;
					nStatus	= status(ProgressStatus(opt.name),...
								'noffset'	, opt.noffset-2						, ...
								'logpath'	, ifo.progress.(opt.name).logpath	, ...
								'silent'	, bSilent							  ...
								);
				end
		end
	end
end
%------------------------------------------------------------------------------%
function bJustFine = CheckFigure
% check to see if the figure is open when it should be.  if it hasn't been
% opened yet and should, then the figure is opened
	bJustFine	= true;
	
	if ~ifo.bSkipFigure
		if ~IsFigureInited
			InitFigure;
		else
			bJustFine	= IsFigureOpen;
		end
	end
end
%------------------------------------------------------------------------------%
function b = IsFigureOpen
	b	= notfalse(ishandle(ifo.h));
end
%------------------------------------------------------------------------------%
function b = IsFigureInited
	b	= ifo.bSkipFigure || ~isempty(ifo.h);
end
%------------------------------------------------------------------------------%
function InitFigure
	ifo.h	= openfig('blank.fig');
	
	MoveElement(ifo.h,'w',opt.width,'center',true);
	
	ifo.pFigure				= GetElementPosition(ifo.h);
	ifo.bStructureChanged	= true;
end
%------------------------------------------------------------------------------%
function ClearFigure
	if IsFigureOpen
		close(ifo.h);
	end
	
	ifo.bStructureChanged	= true;
end
%------------------------------------------------------------------------------%
function ClearAll()
	%close the figure
		ClearFigure;
	%clear the info
		ifo	= [];
end
%------------------------------------------------------------------------------%
function InitAll()
	opt.type	= conditional(DisplayExists,unless(opt.type,'figure'),'commandline');
	
	ifo	= struct(...
					'bStructureChanged'	, true		, ...
					'bChanged'			, true		, ...
					'bSkipFigure'		, true		, ...
					'type'				, opt.type	, ...
					'progress'			, struct	, ...
					'tRedraw'			, 0			, ...
					'h'					, []		  ...
				);
end
%------------------------------------------------------------------------------%
function b = IsInited
	b	= ~isempty(ifo);
end
%------------------------------------------------------------------------------%
function b = IsProgress(strName)
	b	= isfield(ifo.progress,strName);
end
%------------------------------------------------------------------------------%
function ClearProgress(strName)
	if IsProgress(strName)
		%set a status message
			if ifo.progress.(strName).status
				tDiff		= tNow - ifo.progress.(strName).tstart;
				strTime		= FormatTime(tDiff,'H:MM:SS');
				strStatus	= sprintf('%s: finished (%s total)',ifo.progress.(strName).label,strTime);
				nStatus		= status(strStatus,...
								'noffset'	, opt.noffset-3						, ...
								'logpath'	, ifo.progress.(strName).logpath	, ...
								'silent'	, ifo.progress.(strName).silent		  ...
								);
			end
		%clear the figure elements
			if isequal(ifo.type,'figure')
				cElement	= {'hLabel','hAxes'};
				nElement	= numel(cElement);
				
				for kE=1:nElement
					if notfalse(ishandle(GetFieldPath(ifo.progress,strName,cElement{kE})))
						delete(ifo.progress.(strName).(cElement{kE}));
					end
				end
			end
		%clear the progress info
			ifo.progress	= rmfield(ifo.progress,strName);
	end
	
	ifo.bChanged			= true;
	ifo.bStructureChanged	= true;
end
%------------------------------------------------------------------------------%
function InitProgress(strName)
	bValid		= notfalse(opt.n>0);
	
	if bValid
		bMultiple		= notfalse(opt.n>1);
		bSilent			= notfalse(opt.silent) || ~bMultiple;
		
		%fill in empties
			opt.pend	= unless(opt.pend,opt.pstart + opt.n);
			opt.ptotal	= unless(opt.ptotal,opt.pend);
		%get the log path
			if opt.log
				strPathLog	= PathUnsplit('~',sprintf('progress_%s',strName),'log');
				if FileExists(strPathLog)
					delete(strPathLog);
				end
			else
				strPathLog	= [];
			end
		%initialize the progress struct
			ifo.progress.(opt.name)	= struct(...
										'bElementInit'	, false							, ...
										'pstart'		, opt.pstart					, ...
										'pend'			, opt.pend						, ...
										'ptotal'		, opt.ptotal					, ...
										'pstep'			, (opt.pend-opt.pstart)/opt.n	, ...
										'p'				, opt.pstart					, ...
										'pLast'			, opt.pstart					, ...
										'tstart'		, tNow							, ...
										'tsample'		, []							, ...
										'fsample'		, []							, ...
										'fhsample'		, []							, ...
										'nhsample'		, []							, ...
										'label'			, opt.label						, ...
										'tLast'			, 0								, ...
										'color'			, opt.color						, ...
										'status'		, opt.status					, ...
										'logpath'		, strPathLog					, ...
										'silent'		, bSilent						  ...
									);
		%display a status message as the progress starts
			if ifo.progress.(opt.name).status
				strStatus	= sprintf('%s: started (%d total)',opt.label,opt.n);
				nStatus		= status(strStatus,...
								'noffset'	, opt.noffset-2	, ...
								'logpath'	, strPathLog	, ...
								'silent'	, opt.silent	  ...
								);
			end
		%initialize the figure elements
			if ~bSilent
				InitProgressElement(strName);
			end
		
		ifo.bChanged			= ~bSilent;
		ifo.bStructureChanged	= ~bSilent;
	end
end
%------------------------------------------------------------------------------%
function InitProgressElement(strName)
	if isequal(ifo.type,'figure')
		ifo.bSkipFigure	= false;
		CheckFigure;
		
		figure(ifo.h);
		
		%insert the figure elements
			ifo.progress.(strName).hLabel	= uicontrol(ifo.h,'Style','text','String',ifo.progress.(strName).label);
			ifo.progress.(strName).hAxes	= axes;
			ifo.progress.(strName).hPatch	= patch([0;0;0;0],[0;1;1;0],opt.color);
			ifo.progress.(strName).hInfo	= text(0,0.5,'');
		%set up the elements
			set(ifo.progress.(strName).hLabel,'Units','pixels');
			set(ifo.progress.(strName).hLabel,'FontSize',10);
			set(ifo.progress.(strName).hLabel,'BackgroundColor',get(ifo.h,'Color'));
			set(ifo.progress.(strName).hLabel,'FontWeight','bold');
			
			set(ifo.progress.(strName).hAxes,'Units','pixels');
			set(ifo.progress.(strName).hAxes,'XTick',[]);
			set(ifo.progress.(strName).hAxes,'YTick',[]);
			set(ifo.progress.(strName).hAxes,'Box','on');
			set(ifo.progress.(strName).hAxes,'XLim',[0 1]);
			set(ifo.progress.(strName).hAxes,'YLim',[0 1]);
			
		ifo.progress.(strName).bElementInit	= true;
	end
	
	ifo.bChanged			= true;
	ifo.bStructureChanged	= true;
end
%------------------------------------------------------------------------------%
function StepProgress(strName)
	%update progress endpoint + current point
		pEndOld		= ifo.progress.(strName).pend;
		pTotalOld	= ifo.progress.(strName).ptotal;
		pOld		= ifo.progress.(strName).p;
		
		if ~isempty(opt.n)
			ifo.progress.(strName).pend		= ifo.progress.(strName).pstart + opt.n*ifo.progress.(strName).pstep;
			ifo.progress.(strName).ptotal	= ifo.progress.(strName).pend;
		end
		
		ifo.progress.(strName).p		= conditional(isempty(opt.p),ifo.progress.(strName).p + ifo.progress.(strName).pstep,opt.p);
		
		if ifo.progress.(strName).pend~=pEndOld || ifo.progress.(strName).ptotal~=pTotalOld || ifo.progress.(strName).p~=pOld
			ifo.bChanged	= true;
		end
	%did the label change?
		if ~bEmptyLabel && isfield(ifo.progress.(strName),'hLabel')
			ifo.progress.(strName).label	= opt.label;
			
			set(ifo.progress.(strName).hLabel, 'String', opt.label);
		end
	%are we finished?
		if ProgressFraction(strName)>=1
			ClearProgress(strName);
		end
end
%------------------------------------------------------------------------------%
function strStatus = ProgressStatus(strName)
	pCur	= ifo.progress.(strName).p;
	pTotal	= ifo.progress.(strName).ptotal;
	tStart	= ifo.progress.(strName).tstart;
	
	f	= ProgressFraction(strName);
	
	s											= ifo.progress.(strName);
	[s.fsample,s.tsample,s.fhsample,s.nhsample]	= SignalStep(f,tNow,50,s.fsample,s.tsample,s.fhsample,s.nhsample);
	ifo.progress.(strName).fsample				= s.fsample;
	ifo.progress.(strName).tsample				= s.tsample;
	ifo.progress.(strName).fhsample				= s.fhsample;
	ifo.progress.(strName).nhsample				= s.nhsample;
	
	tRemaining		= etd(s.fsample,tStart,s.tsample);
	strFraction		= [num2str(pCur) '/' num2str(pTotal)];
	strPercentage	= [sprintf('%0.2f',100*roundn(f,-4)) '%'];
	strRemaining	= [tRemaining ' remaining'];
	strStatus		= [strFraction ' (' strPercentage ') (' strRemaining ')'];
	
	if isequal(ifo.type,'commandline')
		strStatus	= [ifo.progress.(strName).label ': ' strStatus];
	end
end
%------------------------------------------------------------------------------%
function f = ProgressFraction(strName)
	pCur	= ifo.progress.(strName).p;
	pStart	= ifo.progress.(strName).pstart;
	pEnd	= ifo.progress.(strName).pend;
	f		= (pCur-pStart)./(pEnd-pStart);
end
%------------------------------------------------------------------------------%
function strName = GetDefaultName()
% get the default name for the current progress indicator
	strName	= caller(2,'all',true);	%get the stack patch
	strName	= str2fieldname(strName);	%make a valid field name
	strName	= left(strName,63);			%make sure we're not too long
	strName	= conditional(isempty(strName),'MATLABRoot',strName);
end
%------------------------------------------------------------------------------%
function b = DisplayExists
	b	= ~isequal(get(0,'ScreenDepth'),0);
end
%------------------------------------------------------------------------------%
function b = StructureChanged
	b	= ifo.bStructureChanged;
	
	if b
		ifo.bStructureChanged	= false;
	end
end
%------------------------------------------------------------------------------%
function b = Changed
	b	= ifo.bChanged;
	
	if b
		ifo.bChanged	= false;
	end
end
%------------------------------------------------------------------------------%


end
