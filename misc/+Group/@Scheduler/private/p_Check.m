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
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
tNow	= Group.Now;

if ~sch.root.info.scheduler.checking
	sch.root.info.scheduler.checking	= true;

	%stop and remove expired tasks
		p_Update(sch);
	
	p_GetRemoveLock(sch);
	
	if ~isempty(sch.root.info.scheduler.task)
	%find the functions at or above the specified priority
		bExecute	= [sch.root.info.scheduler.task.priority] >= priority;
		
		if any(bExecute)
		%which ones need to be executed
			bFinished			= logical(bitget([sch.root.info.scheduler.task(bExecute).mode],sch.MODE_FINISHED));
			bPaused				= logical(bitget([sch.root.info.scheduler.task(bExecute).mode],sch.MODE_PAUSED));
			bDue				= [sch.root.info.scheduler.task(bExecute).tNext] <= tNow;
			bExecute(bExecute)	= ~bFinished & ~bPaused & bDue;
			
			if any(bExecute)
			%execute until we're out of time
				kExecute	= find(bExecute);
				nExecute	= numel(kExecute);
				
				%execute shorter tasks first
					[te,kOrder]	= sort([sch.root.info.scheduler.task(kExecute).tEstimate]);
					kExecute	= kExecute(kOrder);
				%execute higher priority tasks first
					[p,kOrder]	= sort([sch.root.info.scheduler.task(kExecute).priority],'descend');
					kExecute	= kExecute(kOrder);
				
				for k=1:nExecute
					kE	= kExecute(k);
					
					tNow	= Group.Now;
					
					if tNow>=tEndMax
						break;
					end
					
					if (sch.root.info.scheduler.task(kE).priority==sch.PRIORITY_CRITICAL) || (tNow+sch.root.info.scheduler.task(kE).tEstimate <= tEndMax)
						%execute it
							try
								[bAbort,sch.root.info.scheduler.task(kE).output{:}]	= sch.root.info.scheduler.task(kE).function(sch.root.info.scheduler.task(kE).arguments{:});
							catch me
								bAbort		= true;
								
								sch.Log.Append(['error in ' sch.root.info.scheduler.task(kE).name ': ' me.message],tNow,true);
								
								if sch.root.info.debug>0
									keyboard;
								end 
							end
							
							sch.root.info.scheduler.task(kE).tLast	= tNow;
						
						if bAbort
						%mark the abort bit
							sch.root.info.scheduler.task(kE).mode		= bitset(sch.root.info.scheduler.task(kE).mode,sch.MODE_ABORTED);
						else
							if bitget(sch.root.info.scheduler.task(kE).mode,sch.MODE_RUNONCE)
							%only run once, mark it for cleanup
								sch.Remove(kE);
							else
							%get the task start time
								if sch.root.info.scheduler.task(kE).tSetStart==-1
									sch.root.info.scheduler.task(kE).tSetStart	= tNow;
								end
								if sch.root.info.scheduler.task(kE).tStart==-1
									sch.root.info.scheduler.task(kE).tStart	= tNow;
								end
							%update the estimated duration
								tAfter		= Group.Now;
								nExecutions	= sch.root.info.scheduler.task(kE).executions+1;
								
								sch.root.info.scheduler.task(kE).tEstimate	= ((tAfter-tNow) + (nExecutions-1)*sch.root.info.scheduler.task(kE).tEstimate)/nExecutions;
								sch.root.info.scheduler.task(kE).executions	= nExecutions;
							%get the next execution time
								nIntervals								= floor((tNow-sch.root.info.scheduler.task(kE).tSetStart)./sch.root.info.scheduler.task(kE).interval);
								sch.root.info.scheduler.task(kE).tNext	= sch.root.info.scheduler.task(kE).tSetStart + (nIntervals+1)*sch.root.info.scheduler.task(kE).interval;
							end
						end
					end
				end
			end
		end
	end
	
	p_ReleaseRemoveLock(sch);
	
	sch.root.info.scheduler.checking	= false;
end
