function varargout = Sequence(shw,cX,tShow,varargin)
% PTB.Show.Sequence
% 
% Description:	show a sequence of stimuli
% 
% Syntax:	[tStart,tEnd,tShow,bAbort,x1,...,xN] = shw.Sequence(cX,tShow,<options>)
% 
% In:
%	cX		- a cell of stimuli to show.  each element can be:
%				h:			the handle to a texture to show
%				str:		a string input to shw.Text
%				f:			the handle to a function that accepts an option
%							named 'window' that specifies a texture handle and
%							draws its stimulus onto that texture (e.g.
%							f('window',hT)).
%				{h,...}:	the handle to a texture along with other inputs to
%							shw.Texture
%				{strF,...}:	inputs to shw.(strF), (i.e. {'Circle','red',1}
%							executes shw.Circle('red',1))
%				{f,...}:	the handle to a function along with its inputs. the
%							function must accept an option argument 'window' that
%							specifies a texture handle and draw its stimulus onto
%							that texture (e.g. f(...,'window',hT)).
%	tShow	- a time specifying when to move on to the next stimulus, or the
%			  handle to a function that takes the current time as input and
%			  returns two booleans: the first indicates whether to abort the
%			  sequence and the second whether to move on to the next stimulus in
%			  the sequence. can also be an array/cell of times or function
%			  handles, one for each step in the sequence.  the input times
%			  depend on the tbase option.
%	<options>:
%		window:			('main') the name of the window on which to show the
%						sequence
%		tunit:			(<auto>) the unit of time.  can either be 'ms' for
%						PTB.Now time or 'tr' for the TR number. defaults based
%						on context:
%							fmri: tr
%							eeg/pyschophysics: ms
%		tbase:			('step') either 'step', 'sequence', or 'absolute' to
%						specify whether times are relative to the start of the
%						current step, the start of the sequence, or are absolute
%		prerender:		(false) true to prerender each stimulus as a texture
%						before starting the sequence.  this will take more time
%						up front and memory but reduce the amount of time it
%						takes to draw each stimulus during the sequence. note
%						that prerendering doesn't work if a stimulus depends on
%						the time arguments to render correctly.
%		postrelease:	(false) true to release textures only after the sequence
%						ends.   this will take more time after the sequence is
%						over and memory but reduce the amount of time it takes to
%						prepare each stimulus during the sequence.
%		xnow:			(<nothing>) a stimulus to show immediately, before the
%						sequence is prepared (see cX for syntax)
%		tstart:			(<immediate>) the absolute time at which to start the
%						sequence, or the handle to a function that takes the
%						current time as input and returns two booleans: the first
%						indicates whether to abort the sequence and the second
%						whether to start the sequence
%		fwait:			(<PTB.Scheduler.Wait>) a handle or cell of handles the
%						same size as cX to functions that take the current time
%						and the time of the next stimulus presentation (or NaN
%						where tShow is a function handle) as input and return at
%						least a boolean as the first output that indicates
%						whether the sequence should be aborted, and are executed
%						while the sequence is waiting to move on to the next
%						stimulus. non-empty return values beyond the first output
%						are appended to the output arguments x1 ... xN. if a cell
%						of function handles is passed then each function must
%						return the same number of outputs.  set this to false to
%						do nothing but wait 1ms.
%		max_wait:		(10) the desired maximum execution time for calls to
%						PTB.Scheduler.Wait, in ms.  this only applies where
%						functions rather than times were specified in tShow.
%		wait_priority:	(PTB.Scheduler.PRIORITY_LOW) only execute scheduler tasks
%						at or above this priority while waiting to move on to the
%						next step in the sequence  only applies if the default
%						fwait function is used.
%		fixation:		(true) true to show the fixation dot on each stimulus
%		fixation_task:	(false) true to show the fixation task.  can also be a
%						logical array the same size as the sequence indicating
%						whether the fixation_task should be shown for each
%						stimulus.
% 
% Out:
%	tStart				- the time at which the sequence started
%	tEnd				- the time at which the sequence aborted or ended
%	tShow				- the actual time at which each stimulus appeared on the
%						  screen
%	bAbort				- true if the sequence was aborted
%	xK					- a cell of all the non-empty (K+1)th outputs from the
%						  wait functions
% 
% Example:
%	%show four strings spaced every one second 
%	cX	= {'this','is','a','test'};
%	shw.Sequence(cX,1000,'tunit','ms');
%	
%	%show three textures interspersed with a blank.  the subject must press
%	%the space bar to advance after each stimulus
%	cX		= {hTBlank hT1 hTBlank hT2 hTBlank hT3 hTBlank};
%	fShow	= @(t) deal(false,ptb.Input.DownOnce('key_space'));
%	tShow	= {1000 fShow 1000 fShow 1000 fShow 1000};
%	shw.Sequence(cX,tShow);
% 
% Updated: 2012-07-05
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
%size of the sequence
	sStim	= size(cX);
	nStim	= numel(cX);
%figure out how many wait function outputs to expect
	nOutFixed	= 4;
	nOutWait	= max(0,nargout-nOutFixed);	
%parse the inputs
	opt	= ParseArgs(varargin,...
			'window'		, 'main'								, ...
			'tunit'			, []									, ...
			'tbase'			, 'step'								, ...
			'prerender'		, false									, ...
			'postrelease'	, false									, ...
			'xnow'			, []									, ...
			'tstart'		, []									, ...
			'fwait'			, []									, ...
			'max_wait'		, 10									, ...
			'wait_priority'	, shw.parent.Scheduler.PRIORITY_LOW	, ...
			'fixation'		, true									, ...
			'fixation_task'	, false									  ...
			);
	
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
	
	%determine whether we should show the fixation task for each stimulus
		opt.fixation_task	= repto(opt.fixation_task,sStim);
		bFixation			= any(opt.fixation_task);
	
%keep track of the textures we open
	hTOpened	= [];
	kTOpened	= [];
	nOpened		= 0;

%blank the screen
	shw.Blank('fixation',false);
%should we show something now?
	if ~isempty(opt.xnow)
		x	= RenderOne(opt.xnow,0,0);
		
		shw.Texture(x{:});
		if opt.fixation
			shw.Fixation;
		end
		shw.parent.Window.Flip;
	end

%prepare the stimuli
	if opt.prerender
		cX	= cellfun(@(x) RenderOne(x,0,0),cX,'UniformOutput',false);
	end

%run the sequence
	kSequence	= 0;
	
	cF		= repmat({@SequenceStep},[nStim 1]);
	tShow	= reshape(tShow,[],1);
	
	%prepare the first stimulus
		tNow	= fNow();
		if isa(opt.tstart,'function_handle')
			tNext	= 0;
		else
			tNext	= unless(opt.tstart,0);
		end
		PrepNext(tNow,tNext);
	
	%get the fixation task ready to go
		if bFixation
			shw.FixationTask.Reset;
			shw.FixationTask.Go;
			shw.FixationTask.Stop;
		end
	
	[varargout{1:nargout}]	= shw.parent.Sequence.Linear(cF,tShow,...
								'tunit'			, opt.tunit			, ...
								'tbase'			, opt.tbase			, ...
								'tstart'		, opt.tstart		, ...
								'fwait'			, opt.fwait			, ...
								'max_wait'		, opt.max_wait		, ...
								'wait_priority'	, opt.wait_priority	  ...
								);
	
	%end the fixation task
		if bFixation
			shw.FixationTask.Stop;
		end
	
%close the textures we opened
	if opt.postrelease
		hTClose	= hTOpened;
		nTClose	= numel(hTClose);
		for kT=1:nTClose
			ReleaseTexture(hTClose(kT));
		end
	end

%------------------------------------------------------------------------------%
function t = SequenceStep(tNow,tNext)
% show one step of the sequence
	kSequence	= kSequence + 1;
	
	%add the fixation
		if opt.fixation
			shw.Fixation;
		end
	%flip
		t	= shw.parent.Window.Flip;
		
		if bTR
			t	= shw.parent.Scanner.TR;
		end
	%start the fixation task if specified
		if opt.fixation_task(kSequence)
			shw.FixationTask.Go;
		else
			shw.FixationTask.Stop;
		end
	%prep the next stimulus
		PrepNext(tNow,tNext);
end
%------------------------------------------------------------------------------%
function PrepNext(tNow,tNext)
%prepare the next stimulus
	kNext	= kSequence+1;
	
	if kNext<=nStim
		%render it
			if ~opt.prerender
				cX{kNext}	= RenderOne(cX{kNext},tNow,tNext);
			end
		%show it
			shw.Texture(cX{kNext}{:});
		%release the texture
			if ~opt.postrelease
				ReleaseTexture(cX{kNext}{1});
			end
	end
end
%------------------------------------------------------------------------------%
function xR = RenderOne(x,tNow,tNext)
% render one stimulus to a texture and return the inputs to PTB.Show.Texture
	bOpened	= false;
	strName	= ['showsequence_' num2str(nOpened+1)];
	
	switch class(x)
		case 'cell'
		%stimulus with custom inputs
			switch class(x{1})
				case 'char'
				%input to a Show subfunction
					bOpened	= true;
					
					xR{1}	= shw.parent.Window.OpenTexture(strName);
					shw.(x{1})(x{2:end},'window',xR{1});
				case 'function_handle'
				%custom function with inputs
					bOpened	= true;
					
					xR{1}	= shw.parent.Window.OpenTexture(strName);
					x{1}(x{2:end},'window',xR{1});
				otherwise
				%texture with custom inputs
					xR	= x;
			end
		case 'char'
		%text with no custom inputs
			bOpened	= true;
			
			xR{1}	= shw.parent.Window.OpenTexture(strName);
			shw.Text(x,'window',xR{1});
		case 'function_handle'
		%custom function with no inputs
			bOpened	= true;
			
			xR{1}	= shw.parent.Window.OpenTexture(strName);
			x('window',xR{1});
		otherwise
		%texture with no custom inputs
			xR	= {x};
	end
	
	if bOpened
		nOpened		= nOpened + 1;
		hTOpened	= [hTOpened; xR{1}];
		kTOpened	= [kTOpened; nOpened];
	end
end
%------------------------------------------------------------------------------%
function ReleaseTexture(hTexture)
	kT			= find(hTOpened==hTexture,1);
	
	if ~isempty(kT)
		kTexture	= kTOpened(kT);
		
		shw.parent.Window.CloseTexture(['showsequence_' num2str(kTexture)]);
		
		hTOpened(kT)	= [];
		kTOpened(kT)	= [];
	end
end
%------------------------------------------------------------------------------%

end
