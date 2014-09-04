function bAbort = p_FixationTaskStep(ft)
% p_FixationTaskStep
% 
% Description:	perform one step of the fixation task
% 
% Syntax:	bAbort = p_FixationTaskStep(ft)
% 
% Updated: 2011-12-16
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

tNow	= PTB.Now;

%what are we doing
	switch PTBIFO.fixation_task.stage
		case 0
		%we're not doing anything.  should we start the task?
			%check for response
				[bResponse,bAbort,tResponse]	= p_ProcessResponse(ft);
				
				if bAbort
					return;
				end
			
			%get the amount of time that has passed since our last call
				tInterval					= tNow - PTBIFO.fixation_task.tLast;
				PTBIFO.fixation_task.tLast	= tNow;
			%get the probability that an event occurring on average at the rate
			%of the fixation task will occur during this interval (poisson
			%distribution)
				%expected number of occurrences during this interval
					lambda	= PTBIFO.fixation_task.rate*(tInterval/1000);
				%pmf of poisson distribution is exp(-lambda)*lambda^k/k!, so
				%probability of at least one occurrence is 1-pmf(0)
				% = 1-exp(-lambda)
					p	= 1 - exp(-lambda);
			%get an event with this probability
				bStartTask	= rand<=p;
			
			if bStartTask
				p_Stage1(ft);
			end
		case 1
		%we're showing the fixation color change
			%check for response
				[bResponse,bAbort,tResponse]	= p_ProcessResponse(ft);
				
				if bAbort
					return;
				end
			%check end of fixation color change
				if tNow>=PTBIFO.fixation_task.tStart+PTBIFO.fixation_task.dur
					p_Stage2(ft);
				end
		case 2
		%we're waiting for the timeout
			%check for response
				[bResponse,bAbort,tResponse]	= p_ProcessResponse(ft);
				
				if bAbort
					return;
				end
			%check for timeout
				if tNow>=PTBIFO.fixation_task.tStart+PTBIFO.fixation_task.timeout
					p_Stage0(ft);
				end
	end
