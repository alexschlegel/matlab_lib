function varargout = Loop(shw,x,rate,varargin)
% PTB.Show.Loop
% 
% Description:	show a stimulus loop
% 
% Syntax:	[tStart,tEnd,tLoop,bAbort,x1,...,xN] = shw.Loop(x,rate,<options>)
% 
% In:
%	x		- the stimulus to show.  can be:
%				h:			the handle to a texture.  the texture is drawn onto
%							the onscreen window immediately after flipping the
%							previous stimulus.
%				{h,...}:	the handle to a texture along with other inputs to
%							shw.Texture
%				f:			the handle to a function that takes the current time
%							and the time at which the next stimulus will be shown
%							(or NaN if rate is a function handle) as inputs and
%							draws the stimulus on the main window
%				{f,...}:	the handle to a function as above, along with
%							additional inputs after the first two
%	rate	- the number of times the stimulus should be updated per second, or
%			  a function that takes the current time as input and returns two
%			  booleans: the first indicates whether to abort the loop and the
%			  second whether to update the stimulus. the input time depends on
%			  the tbase option.
%	<options>:
%		window:			('main') the name of the window on which to show the
%						sequence
%		tunit:			(<auto>) the unit of time.  can either be 'ms' for
%						PTB.Now time or 'tr' for the TR number. defaults based on
%						context:
%							fmri: tr
%							eeg/pyschophysics: ms
%		tbase:			('sequence') either 'step', 'sequence', or 'absolute' to
%						specify whether times are relative to the start of the
%						current loop step, the start of the sequence, or are
%						absolute
%		xnow:			(<nothing>) a stimulus to show immediately, before the
%						sequence is prepared (see cX in PTB.Show.Sequence for
%						syntax)
%		tstart:			(<immediate>) the absolute time at which to start the
%						loop, or the handle to a function that takes the current
%						time as input and returns two booleans: the first
%						indicates whether to abort the loop and the second
%						whether to start the loop
%		tend:			(<never>) the absolute time at which to end the loop, or
%						the handle to a function that takes the current time as
%						input and returns two booleans:  the first indicates
%						whether to abort the loop and the second whether to end
%						the loop
%		fwait:			(<PTB.Scheduler.Wait>) the handle to a function that
%						takes the current time and the time of the next stimulus
%						presentation (or NaN if rate is a function handle) as
%						input and returns at least a boolean as the first output
%						that indicates whether the loop should be aborted, and is
%						executed while the loop is waiting to move on to the next
%						stimulus. non-empty return values beyond the first output
%						are appended to the output arguments x1 ... xN.  set this
%						to false to do nothing but wait 1ms.
%		max_wait:		(10) the desired maximum execution time for calls to
%						PTB.Scheduler.Wait, in ms.  this only applies where
%						functions rather than times were specified in tShow.
%		wait_priority:	(PTB.Scheduler.PRIORITY_LOW) only execute scheduler tasks
%						at or above this priority while waiting to move on to the
%						next step in the sequence. only applies if the default
%						fwait function is used.
%		return:			('rate') one of the following, to specify the tLoop
%						output value:
%							'rate':		the actual average display rate
%							't':		an array of actual flip times
%							'manual':	x must be a function that returns a
%										logical value to indicate whether the flip
%										time for that stimulus should be recorded
%		fixation:		(true) true to show the fixation dot on each stimulus
%		fixation_task:	(false) true to show the fixation task
% 
% Out:
%	tStart				- the time at which the loop started
%	tEnd				- the time at which the loop aborted or ended
%	tLoop				- the actual average display rate or the actual time at
%						  which each stimulus appeared on the screen, depending
%						  on the return option
%	bAbort				- true if the loop was aborted
%	xK					- a cell of all the non-empty (K+1)th outputs from the
%						  wait function
% 
% Updated: 2012-03-10
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

%possible time functions
	persistent fNowMS fNowTR;
			
	if isempty(fNowMS)
		fNowMS			= @PTB.Now;
		fNowTR			= @() shw.parent.Scanner.TR();
	end
%figure out how many wait function outputs to expect
	nOutFixed	= 4;
	nOutWait	= max(0,nargout-nOutFixed);	
%parse the inputs
	opt	= ParseArgs(varargin,...
			'window'		, 'main'								, ...
			'tunit'			, []									, ...
			'tbase'			, 'sequence'							, ...
			'xnow'			, []									, ...
			'tstart'		, []									, ...
			'tend'			, Inf									, ...
			'fwait'			, []									, ...
			'max_wait'		, 10									, ...
			'wait_priority'	, shw.parent.Scheduler.PRIORITY_LOW	, ...
			'return'		, 'rate'								, ...
			'fixation'		, true									, ...
			'fixation_task'	, false									  ...
			);
	
	opt.return	= CheckInput(opt.return,'return',{'rate','t','manual'});
	bManual		= isequal(opt.return,'manual');
	
	%parse the time unit and function
		%time unit
			if isempty(opt.tunit)
				opt.tunit	= switch2(PTBIFO.experiment.context,...
								'fmri'			, 'tr'	, ...
								'eeg'			, 'ms'	, ...
								'psychophysics'	, 'ms'	  ...
								);
			end
			opt.tunit	= CheckInput(opt.tunit,'tunit',{'ms','tr'});
			bTR			= isequal(opt.tunit,'tr');
		%current time function
			fNow	= switch2(opt.tunit,...
						'ms'	, fNowMS	, ...
						'tr'	, fNowTR	  ...
						);
	
%blank the screen
	shw.Blank('fixation',false);
%should we show something now?
	if ~isempty(opt.xnow)
		ShowOne(opt.xnow,0,0);
		
		if opt.fixation
			shw.Fixation;
		end
		
		shw.parent.Window.Flip;
	end

%run the sequence
	%prepare the first stimulus
		tNow	= fNow();
		
		switch opt.tbase
			case 'step'
				tNext	= 0;
			case 'sequence'
				tNext	= 0;
			case 'absolute'
				if isa(opt.tstart,'function_handle')
					tNext	= tNow;
				else
					tNext	= unless(opt.tstart,tNow);
				end
		end
		
		bReport	= PrepNext(tNow,tNext);
	
	%start the fixation task
		if opt.fixation_task
			shw.FixationTask.Go;
		end
	
	[varargout{1:nargout}]	= shw.parent.Sequence.Loop(@LoopStep,rate,...
								'tunit'			, opt.tunit			, ...
								'tbase'			, opt.tbase			, ...
								'tstart'		, opt.tstart		, ...
								'tend'			, opt.tend			, ...
								'fwait'			, opt.fwait			, ...
								'max_wait'		, opt.max_wait		, ...
								'wait_priority'	, opt.wait_priority	, ...
								'return'		, opt.return		  ...
								);
	
	%end the fixation task
		if opt.fixation_task
			shw.FixationTask.Stop;
		end

%------------------------------------------------------------------------------%
function [t,tReport] = LoopStep(tNow,tNext)
%show one step of the loop
	%add the fixation
		if opt.fixation
			shw.Fixation;
		end
	%flip
		t	= shw.parent.Window.Flip;
		
		if bTR
			t	= shw.parent.Scanner.TR;
		end
		
		tReport	= conditional(bReport,t,[]);
	%prep the next stimulus
		bReport	= PrepNext(tNow,tNext);
end
%------------------------------------------------------------------------------%
function bReport = PrepNext(tNow,tNext)
%prepare the next stimulus
	bReport	= ShowOne(x,tNow,tNext);
end
%------------------------------------------------------------------------------%
function bReport = ShowOne(x,tNow,tNext)
% show one stimulus on the main window
	bReport	= false;
	
	switch class(x)
		case 'cell'
		%stimulus with custom inputs
			switch class(x{1})
				case 'char'
				%input to a Show subfunction
					shw.(x{1})(x{2:end});
				case 'function_handle'
				%custom function with inputs
					if bManual
						bReport	= x{1}(tNow,tNext,x{2:end});
					else
						x{1}(tNow,tNext,x{2:end});
					end
				otherwise
				%texture with custom inputs
					shw.Texture(x{:});
			end
		case 'char'
		%text with no custom inputs
			shw.Text(x);
		case 'function_handle'
		%custom function with no inputs
			if bManual
				bReport	= x(tNow,tNext);
			else
				x(tNow,tNext);
			end
		otherwise
		%texture with no custom inputs
			shw.Texture(x);
	end
end
%------------------------------------------------------------------------------%

end
