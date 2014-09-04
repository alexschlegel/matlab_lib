function p_Update(sch)
% p_Update
% 
% Description:	add new tasks, mark and remove expired tasks
% 
% Syntax:	p_Update(sch)
% 
% Updated: 2011-12-20
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

tNow	= PTB.Now;

if ~PTBIFO.scheduler.updating
	PTBIFO.scheduler.updating	= true;
	
	%add new tasks
		nAdd	= size(PTBIFO.scheduler.queue.add,2);
		
		if nAdd>0
			PTBIFO.scheduler.task(end+(1:nAdd))	= cell2struct(PTBIFO.scheduler.queue.add,sch.TASK_FIELD,1);
			PTBIFO.scheduler.queue.add(:,1:nAdd)	= [];
		end
	
	if PTBIFO.scheduler.lock_remove==0 && ~isempty(PTBIFO.scheduler.task)
	%remove old tasks
		%find newly finished tasks
			bCheck	= ~logical(bitget([PTBIFO.scheduler.task.mode],sch.MODE_FINISHED));
			
			bExpired	= tNow >= [PTBIFO.scheduler.task(bCheck).tSetEnd];
			bAborted	= logical(bitget([PTBIFO.scheduler.task(bCheck).mode],sch.MODE_ABORTED));
			bRemoved	= logical(bitget([PTBIFO.scheduler.task(bCheck).mode],sch.MODE_REMOVE));
			bEAR		= bExpired | bAborted | bRemoved;
			
			bFinished			= bCheck;
			bFinished(bCheck)	= bEAR;
			
		if any(bFinished)
		%remove tasks marked for removal or finished without results
			bNoResult		= bEAR;
			bNoResult(bEAR)	= [PTBIFO.scheduler.task(bFinished).nOut]==0;
			
			bRemove			= bFinished;
			bRemove(bCheck)	= ~bAborted & bNoResult;
			
			bMark	= bFinished & ~bRemove;
			if any(bMark)
			%just mark the ones with results
				mNew									= num2cell(bitset([PTBIFO.scheduler.task(bMark).mode],sch.MODE_FINISHED));
				[PTBIFO.scheduler.task(bMark).mode]	= deal(mNew{:});
			end
			
			if any(bRemove)
			%remove the others
				if PTBIFO.scheduler.lock_remove==0
					PTBIFO.scheduler.task(bRemove)	= [];
				end
			end
		end
	end
	
	PTBIFO.scheduler.updating	= false;
end
