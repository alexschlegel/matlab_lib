function p_Check(sch,priority,tEndMax)
% p_Check
% 
% Description:	check for tasks to be executed
% 
% Syntax:	p_Check(sch,priority,tEndMax)
%
% In:
%	sch			- the Scheduler object
%	priority	- only execute tasks with priority at or above this level
%	tEndMax		- try to end no later than this time
% 
% Updated: 2011-12-20
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

tNow	= PTB.Now;

if ~PTBIFO.scheduler.checking
	PTBIFO.scheduler.checking	= true;

	%stop and remove expired tasks
		p_Update(sch);
	
	p_GetRemoveLock(sch);
	
	if ~isempty(PTBIFO.scheduler.task)
	%find the functions at or above the specified priority
		bExecute	= [PTBIFO.scheduler.task.priority] >= priority;
		
		if any(bExecute)
		%which ones need to be executed
			bFinished			= logical(bitget([PTBIFO.scheduler.task(bExecute).mode],sch.MODE_FINISHED));
			bPaused				= logical(bitget([PTBIFO.scheduler.task(bExecute).mode],sch.MODE_PAUSED));
			bDue				= [PTBIFO.scheduler.task(bExecute).tNext] <= tNow;
			bExecute(bExecute)	= ~bFinished & ~bPaused & bDue;
			
			if any(bExecute)
			%execute until we're out of time
				kExecute	= find(bExecute);
				nExecute	= numel(kExecute);
				
				%execute shorter tasks first
					[te,kOrder]	= sort([PTBIFO.scheduler.task(kExecute).tEstimate]);
					kExecute	= kExecute(kOrder);
				%execute higher priority tasks first
					[p,kOrder]	= sort([PTBIFO.scheduler.task(kExecute).priority],'descend');
					kExecute	= kExecute(kOrder);
				
				for k=1:nExecute
					kE	= kExecute(k);
					
					tNow	= PTB.Now;
					
					if tNow>=tEndMax
						break;
					end
					
					if (PTBIFO.scheduler.task(kE).priority==sch.PRIORITY_CRITICAL) || (tNow+PTBIFO.scheduler.task(kE).tEstimate <= tEndMax)
						%execute it
							try
								%PTBIFO.scheduler.task
								[bAbort,PTBIFO.scheduler.task(kE).output{:}]	= PTBIFO.scheduler.task(kE).function(PTBIFO.scheduler.task(kE).arguments{:});
							catch me
								bAbort		= true;
								
								sch.AddLog(['error in ' PTBIFO.scheduler.task(kE).name ': ' me.message],tNow,true);
								
								if PTBIFO.experiment.debug>0
									keyboard;
								end 
							end
							
							PTBIFO.scheduler.task(kE).tLast	= tNow;
						
						if bAbort
						%mark the abort bit
							PTBIFO.scheduler.task(kE).mode		= bitset(PTBIFO.scheduler.task(kE).mode,sch.MODE_ABORTED);
						else
							if bitget(PTBIFO.scheduler.task(kE).mode,sch.MODE_RUNONCE)
							%only run once, mark it for cleanup
								sch.Remove(kE);
							else
							%get the task start time
								if PTBIFO.scheduler.task(kE).tSetStart==-1
									PTBIFO.scheduler.task(kE).tSetStart	= tNow;
								end
								if PTBIFO.scheduler.task(kE).tStart==-1
									PTBIFO.scheduler.task(kE).tStart	= tNow;
								end
							%update the estimated duration
								tAfter		= PTB.Now;
								nExecutions	= PTBIFO.scheduler.task(kE).executions+1;
								
								PTBIFO.scheduler.task(kE).tEstimate	= ((tAfter-tNow) + (nExecutions-1)*PTBIFO.scheduler.task(kE).tEstimate)/nExecutions;
								PTBIFO.scheduler.task(kE).executions	= nExecutions;
							%get the next execution time
								nIntervals							= floor((tNow-PTBIFO.scheduler.task(kE).tSetStart)./PTBIFO.scheduler.task(kE).interval);
								PTBIFO.scheduler.task(kE).tNext	= PTBIFO.scheduler.task(kE).tSetStart + (nIntervals+1)*PTBIFO.scheduler.task(kE).interval;
							end
						end
					end
				end
			end
		end
	end
	
	p_ReleaseRemoveLock(sch);
	
	PTBIFO.scheduler.checking	= false;
end
