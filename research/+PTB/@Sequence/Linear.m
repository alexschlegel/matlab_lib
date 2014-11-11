function varargout = Linear(seq,cF,tSequence,varargin)
% PTB.Sequence.Linear
% 
% Description:	do a sequence of things, one after the other
% 
% Syntax:	[tStart,tEnd,tSequence,bAbort,x1,...,xN] = seq.Linear(cF,tSequence,<options>)
% 
% In:
%	cF			- a cell of handles to functions that take the current time and
%				  the time of the next step (or NaN where tSequence is a function
%				  handle) as input and return the absolute time to associate with
%				  the sequence step or NaN to use the sequence's own version of
%				  the time.  the input times depend on the tbase option.
%	tSequence	- a time specifying when to move on to the next step, or the
%				  handle to a function that takes the current time as input and
%				  returns two booleans: the first indicates whether to abort the
%				  sequence and the second whether to move on to the next step in
%				  the sequence. can also be an array/cell of times or function
%				  handles, one for each step in the sequence.  the input times
%				  depend on the tbase option.
%	<options>:
%		tunit:			(<auto>) the unit of time.  can either be 'ms' for
%						PTB.Now time or 'tr' for the TR number. defaults based on
%						context:
%							fmri: tr
%							eeg/pyschophysics: ms
%		tbase:			('step') either 'step', 'sequence', or 'absolute' to
%						specify whether times are relative to the start of the
%						current step, the start of the sequence, or are absolute
%		tstart:			(<immediate>) the absolute time at which to start the
%						sequence, or the handle to a function that takes the
%						current time as input and returns two booleans: the first
%						indicates whether to abort the sequence and the second
%						whether to start the sequence
%		fwait:			(<PTB.Scheduler.Wait>) a handle or cell of handles the
%						same size as cF to functions that take the same inputs as
%						cF and return at least a boolean as the first output that
%						indicates whether the sequence should be aborted, and are
%						executed while the sequence is waiting to move on to the
%						next step. non-empty return values beyond the first
%						output are appended to the output arguments x1 ... xN. if
%						a cell of function handles is passed then each function
%						must return the same number of outputs.  set this to
%						false to do nothing but wait 1ms.
%		max_wait:		(10) the desired maximum execution time for calls to
%						PTB.Scheduler.Wait, in ms.  this only applies where
%						functions rather than times were specified in tSequence.
%		wait_priority:	(PTB.Scheduler.PRIORITY_LOW) only execute scheduler tasks
%						at or above this priority while waiting to move on to the
%						next step in the sequence.  only applies if the default
%						fwait function is used.
% 
% Out:
%	tStart			- the time at which the sequence started
%	tEnd			- the time at which the sequence aborted or ended
%	tSequence		- the time associated with each sequence step
%	bAbort			- true if the sequence was aborted
%	xK				- a cell of all the non-empty (K+1)th outputs from the wait
%					  functions
% 
% Notes:	pauses the Scheduler timer while the sequence is running
% 
% Examples: (see PTB.Show.Sequence)
% 
% Updated: 2012-02-08
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

%possible time functions
	persistent fNowMS fNowTR fMS2MS fTR2MS fAbs2RelStep fAbs2RelSeq fAbs2RelAbs fRel2AbsStep fRel2AbsSeq fRel2AbsAbs;
			
	if isempty(fNowMS)
		fNowMS			= @PTB.Now;
		fNowTR			= @() seq.parent.Scanner.TR();
		
		fMS2MS			= @(t) t;
		fTR2MS			= @(t) seq.parent.Scanner.TR2ms(t);
		
		fAbs2RelStep	= @(tStart,tStep,t) t - tStep;
		fAbs2RelSeq		= @(tStart,tStep,t) t - tStart;
		fAbs2RelAbs		= @(tStart,tStep,t) t;
		
		fRel2AbsStep	= @(tStart,tStep,t) tStep + t;
		fRel2AbsSeq		= @(tStart,tStep,t) tStart + t;
		fRel2AbsAbs		= @(tStart,tStep,t) t;
	end

%size of the sequence
	sSequence	= size(cF);
	nSequence	= numel(cF);
%figure out how many wait function outputs to expect
	nOutFixed	= 4;
	nOutWait	= max(0,nargout-nOutFixed);
%initialize the outputs
	[tStart,tEnd,bAbort]	= deal(NaN);
	tSeq					= NaN(sSequence);
	
	cOutWait	= repmat({{}},[nOutWait 1]);
%parse the inputs
	opt	= ParseArgs(varargin,...
			'tunit'			, []									, ...
			'tbase'			, 'step'								, ...
			'tstart'		, []										, ...
			'fwait'			, @WaitDefault							, ...
			'max_wait'		, 10									, ...
			'wait_priority'	, seq.parent.Scheduler.PRIORITY_LOW	  ...
			);
	
	%parse the time unit, base, and functions
		%time unit
			if isempty(opt.tunit)
				opt.tunit	= switch2(PTBIFO.experiment.context,...
								'fmri'			, 'tr'	, ...
								'eeg'			, 'ms'	, ...
								'psychophysics'	, 'ms'	  ...
								);
			end
			opt.tunit	= CheckInput(opt.tunit,'tunit',{'ms','tr'});
		%time base
			opt.tbase	= CheckInput(opt.tbase,'tbase',{'step','sequence','absolute'});
		
		%current time function
			fNow	= switch2(opt.tunit,...
						'ms'	, fNowMS	, ...
						'tr'	, fNowTR	  ...
						);
		%conversion to PTB.Now function
			T2MS	= switch2(opt.tunit,...
						'ms'	, fMS2MS	, ...
						'tr'	, fTR2MS	  ...
						);
		%function for getting the relative time in the sequence based on tbase
			fAbs2Rel	= switch2(opt.tbase,...
							'step'		, fAbs2RelStep	, ...
							'sequence'	, fAbs2RelSeq	, ...
							'absolute'	, fAbs2RelAbs	  ...
							);
		%function for getting the absolute time from a relative time
			fRel2Abs	= switch2(opt.tbase,...
							'step'		, fRel2AbsStep	, ...
							'sequence'	, fRel2AbsSeq	, ...
							'absolute'	, fRel2AbsAbs	  ...
							);
		
	%get a wait function for each sequence step
		if ~iscell(opt.fwait)
			opt.fwait	= repmat({opt.fwait},sSequence);
		end
	%format the sequence step functions
		if numel(tSequence)==1
		%one time/function to apply to all
			tSequence	= repmat(ForceCell(tSequence),sSequence);
		end
		if ~iscell(tSequence)
		%convert to a cell
			tSequence	= num2cell(tSequence);
		end

%pause the scheduler
	bPauseScheduler	= seq.parent.Scheduler.Running;
	if bPauseScheduler
		seq.parent.Scheduler.Pause;
	end

%wait to start
	if ~isa(opt.tstart,'function_handle')
		tStart		= opt.tstart;
		opt.tstart	= @(t) TimeCompare(t,opt.tstart);
	else
		tStart		= [];
	end
	
	bStart	= false;
	while ~bStart
		tNow			= fNow();
		[bAbort,bStart]	= opt.tstart(tNow);
		
		if bAbort
			EndSequence;
			return;
		end
	end
	
	tStart	= unless(tStart,tNow);

%do the sequence
	cOutWaitCur	= cell(nOutWait,1);
	
	for kS=1:nSequence
		tStep	= fNow();
		tNowRel	= fAbs2Rel(tStart,tStep,tStep);
		
		bTFunction	= isa(tSequence{kS},'function_handle');
		tNext		= conditional(bTFunction,NaN,tSequence{kS});
		
		%execute the sequence function
			tSeq(kS)	= cF{kS}(tNowRel,tNext);
			if isnan(tSeq(kS))
			%function didn't return a time, use ours
				tSeq(kS)	= tStep;
			end
		%wait until we should move on
			bNext	= false;
			while ~bNext
				%execute the sequence step test function
					tNowRel			= fAbs2Rel(tStart,tStep,fNow());
					if bTFunction
						[bAbort,bNext]	= tSequence{kS}(tNowRel);
					else
						[bAbort,bNext]	= TimeCompare(tNowRel,tNext);
					end
				%test for abort
					if bAbort
						EndSequence;
						return;
					end
				%execute the wait function
					if ~bNext
						if notfalse(opt.fwait{kS})
							tNow	= fNow();
							tNowRel	= fAbs2Rel(tStart,tStep,tNow);
							
							[bAbort,cOutWaitCur{1:nOutWait}]	= opt.fwait{kS}(tNowRel,tNext);
							
							%append the wait function outputs
								bOutput				= ~cellfun(@isempty,cOutWaitCur);
								cOutWait(bOutput)	= cellfun(@(c,x) [c;{x}],cOutWait(bOutput),cOutWaitCur(bOutput),'UniformOutput',false);
							
							%test for abort
								if bAbort
									EndSequence;
									return;
								end
						else
							WaitSecs(0.001);
						end
					end
			end
	end

%done!
	EndSequence;

%------------------------------------------------------------------------------%
function [bAbort,bNext] = TimeCompare(t,tUntil)
%time compare function for time inputs.  just wait until the current time is at
%or beyond the target time
	bAbort	= false;
	bNext	= t>=tUntil;
end
%------------------------------------------------------------------------------%
function bAbort = WaitDefault(tNowRel,tNextRel)
%default wait function.  just execute the scheduler wait function
	bAbort	= false;
	
	if isnan(tNextRel)
	%the next step time is being determined by a custom time function
		tNextAbs	= T2MS(fRel2Abs(tStart,tSeq(kS),tNowRel)) + opt.max_wait;
	else
	%the next step is occurring at a specific time
		tNextAbs	= T2MS(fRel2Abs(tStart,tSeq(kS),tNextRel));
	end
	
	WaitSecs(0.001);
	
	seq.parent.Scheduler.Wait(opt.wait_priority,tNextAbs);
end
%------------------------------------------------------------------------------%
function EndSequence()
%end the sequence
	%resume the scheduler
		if bPauseScheduler
			seq.parent.Scheduler.Resume;
		end

	tEnd		= fNow();
	varargout	= [{tStart}; {tEnd}; {tSeq}; {bAbort}; cOutWait];
end
%------------------------------------------------------------------------------%

end
