function varargout = Loop(seq,f,rate,varargin)
% PTB.Sequence.Loop
% 
% Description:	loop execution of a function
% 
% Syntax:	[tStart,tEnd,tLoop,bAbort,x1,...,xN] = seq.Loop(f,rate,<options>)
% 
% In:
%	f		- the handle to a function that takes the current time and the time
%			  of the next loop execution (or NaN if rate is a function handle)
%			  as input and returns the absolute time to associate with the
%			  current loop step or NaN to use this loop function's own version
%			  of the time.  the input times depend on the tbase option. if the
%			  return option is 'manual', the function must return a second output
%			  that, when non-empty, will be appended to the tLoop return array
%	rate	- the number of times the loop function should execute per second, or
%			  a function that takes the current time as input and returns two
%			  booleans: the first indicates whether to abort the loop and the
%			  second whether to move on to the next loop execution. the input
%			  time depends on the tbase option.
%	<options>:
%		tunit:			(<auto>) the unit of time.  can either be 'ms' for
%						PTB.Now time or 'tr' for the TR number. defaults based on
%						context:
%							fmri: tr
%							eeg/pyschophysics: ms
%		tbase:			('sequence') either 'step', 'sequence', or 'absolute' to
%						specify whether times are relative to the start of the
%						current loop step, the start of the sequence, or are
%						absolute
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
%						takes the same inputs as f and returns at least a boolean
%						as the first output that indicates whether the loop
%						should be aborted, and is executed while the loop is
%						waiting to move on to the next step. non-empty return
%						values beyond the first output are appended to the output
%						arguments x1 ... xN.  set this to false to do nothing but
%						wait 1ms.
%		max_wait:		(10) the desired maximum execution time for calls to
%						PTB.Scheduler.Wait, in ms.  this only applies if a
%						function rather than a time was specified in rate.
%		wait_priority:	(PTB.Scheduler.PRIORITY_LOW) only execute scheduler tasks
%						at or above this priority while waiting to move on to the
%						next step in the loop.  only applies if the default fwait
%						function is used.
%		return:			('rate') one of the following, to specify the tLoop
%						output value:
%							'rate':		the actual average execution rate
%							't':		an array of actual loop function execution
%										times
%							'manual':	the non-empty second outputs from f will
%										be appended in tLoop
% 
% Out:
%	tStart	- the time at which the loop started
%	tEnd	- the time at which the loop aborted or ended
%	tLoop	- the actual average rate of loop execution or the time associated
%			  with each loop step, depending on the value of the return option
%	bAbort	- true if the loop was aborted
%	xK		- a cell of all the non-empty (K+1)th outputs from the wait function
% 
% Notes:	pauses the Scheduler timer while the loop is running
% 
% Updated: 2012-03-10
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

%possible time functions
	persistent fNowMS fNowTR fMS2MS fTR2MS fMS2TR fAbs2RelStep fAbs2RelSeq fAbs2RelAbs fRel2AbsStep fRel2AbsSeq fRel2AbsAbs;
	
	if isempty(fNowMS)
		fNowMS			= @PTB.Now;
		fNowTR			= @() seq.parent.Scanner.TR();
		
		fMS2MS			= @(t) t;
		fTR2MS			= @(t) seq.parent.Scanner.TR2ms(t);
		fMS2TR			= @(t) seq.parent.Scanner.ms2TR(t);
		
		fAbs2RelStep	= @(tStart,tStep,t) t - tStep;
		fAbs2RelSeq		= @(tStart,tStep,t) t - tStart;
		fAbs2RelAbs		= @(tStart,tStep,t) t;
		
		fRel2AbsStep	= @(tStart,tStep,t) tStep + t;
		fRel2AbsSeq		= @(tStart,tStep,t) tStart + t;
		fRel2AbsAbs		= @(tStart,tStep,t) t;
	end

%figure out how many wait function outputs to expect
	nOutFixed	= 4;
	nOutWait	= max(0,nargout-nOutFixed);
%initialize the outputs
	[tStart,tLoop,tEnd,bAbort]	= deal(NaN);
	
	cOutWait	= repmat({{}},[nOutWait 1]);
%parse the inputs
	opt	= ParseArgs(varargin,...
			'tunit'			, []									, ...
			'tbase'			, 'sequence'							, ...
			'tstart'		, []									, ...
			'tend'			, Inf									, ...
			'fwait'			, @WaitDefault							, ...
			'max_wait'		, 10									, ...
			'wait_priority'	, seq.parent.Scheduler.PRIORITY_LOW	, ...
			'return'		, 'rate'								  ...
			);
			
			opt.return	= CheckInput(opt.return,'return',{'rate','t','manual'});
			bManual		= isequal(opt.return,'manual');
	
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
		%conversion from PTB.Now function
			MS2T	= switch2(opt.tunit,...
						'ms'	, fMS2MS	, ...
						'tr'	, fMS2TR	  ...
						);
		%function for getting the relative time in the loop based on tbase
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
	
	%format the end function
		if ~isa(opt.tend,'function_handle')
			opt.tend	= @(t) TimeCompare(t,opt.tend);
		end
	
	bRateFunction 	= isa(rate,'function_handle');
	if ~bRateFunction
		switch opt.tunit
			case 'ms'
				tPer	= 1000/rate;
			case 'tr'
				tPer	= (1000/seq.parent.Info.Get('scanner',{'tr','per'}))/rate;
		end
	end
	bStep	= isequal(opt.tbase,'step');
	
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
		tStart			= fNow();
		[bAbort,bStart]	= opt.tstart(tStart);
		
		if bAbort
			EndLoop;
			return;
		end
	end
	
	tStart	= unless(tStart,fNow());

%do the sequence
	cOutWaitCur	= cell(nOutWait,1);
	
	switch opt.return
		case 'rate'
			tCurLast	= NaN;
			tLoop		= 0;
			nLoop		= 0;
		case 't'
			tLoop		= [];
		case 'manual'
			tLoop		= {};
	end
	
	tNext		= fAbs2Rel(tStart,tStart,tStart);
	bEnd		= false;
	
	tSetStep	= fNow();
	while ~bEnd
		tStep	= fNow();
		tNowRel	= fAbs2Rel(tStart,tStep,tStep);
		
		if bRateFunction
			tNext	= NaN;
		elseif bStep
			tNext		= tPer + (tSetStep - tStep);
			tSetStep	= tSetStep + tPer;
		else
			tNext	= tNext + tPer;
		end
		
		%execute the sequence function
			if bManual
				[tCur,x]	= f(tNowRel,tNext);
			else
				tCur		= f(tNowRel,tNext);
			end
			
			tCur		= unless(tCur,tStep,NaN);
			
			switch opt.return
				case 'rate'
				%update the mean time between executions
					if isnan(tCurLast)
						tCurLast	= tCur;
					else
						tDiffCur	= tCur - tCurLast;
						tCurLast	= tCur;
					
						nLoop	= nLoop + 1;
						tLoop	= (tDiffCur + (nLoop-1)*tLoop)/nLoop;
					end
				case 't'
				%append the execution time
					tLoop(end+1)	= tCur;
				case 'manual'
					if ~isempty(x)
						tLoop{end+1}	= x;
					end
			end
		%wait until we should move on
			bNext	= false;
			while ~bNext
			%test whether we should end the loop
				tEnd			= fNow();
				[bAbort,bEnd]	= opt.tend(tEnd);
				
				if bAbort
					EndLoop;
					return;
				end
				if bEnd
					break;
				end
			%execute the loop step test function
				tNowRel			= fAbs2Rel(tStart,tStep,fNow());
				if bRateFunction
					[bAbort,bNext]	= rate(tNowRel);
				else
					[bAbort,bNext]	= TimeCompare(tNowRel,tNext);
				end
				
				if bAbort
					EndLoop;
					return;
				end
			%execute the wait function
				if ~bNext
					if notfalse(opt.fwait)
						tNow	= fNow();
						tNowRel	= fAbs2Rel(tStart,tStep,tNow);
					
						[bAbort,cOutWaitCur{1:nOutWait}]	= opt.fwait(tNowRel,tNext);
						
						%append the wait function outputs
							bOutput				= ~cellfun(@isempty,cOutWaitCur);
							cOutWait(bOutput)	= cellfun(@(c,x) [c;{x}],cOutWait(bOutput),cOutWaitCur(bOutput),'UniformOutput',false);
						
						%test for abort
							if bAbort
								EndLoop;
								return;
							end
					else
						WaitSecs(0.001);
					end
				end
			end
	end

%done!
	EndLoop;

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
		tNextAbs	= T2MS(fRel2Abs(tStart,tCur,tNowRel)) + opt.max_wait;
	else
	%the next step is occurring at a specific time
		tNextAbs	= T2MS(fRel2Abs(tStart,tCur,tNextRel));
	end
	
	WaitSecs(0.001);
	
	seq.parent.Scheduler.Wait(opt.wait_priority,tNextAbs);
end
%------------------------------------------------------------------------------%
function EndLoop()
%end the sequence
	%resume the scheduler
		if bPauseScheduler
			seq.parent.Scheduler.Resume;
		end
	
	if isequal(opt.return,'rate')
	%calculate the mean rate
		switch opt.tunit
			case 'ms'
				tLoop	= 1000/tLoop;
			case 'tr'
				tLoop	= (1000/seq.parent.Info.Get('scanner',{'tr','per'}))/tLoop;
		end
	end
	
	varargout	= [{tStart}; {tEnd}; {reshape(tLoop,[],1)}; {bAbort}; cOutWait];
end
%------------------------------------------------------------------------------%

end
