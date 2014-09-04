function p_Update(sch)
% p_Update
% 
% Description:	add new tasks, mark and remove expired tasks
% 
% Syntax:	p_Update(sch)
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
tNow	= Group.Now;

if ~sch.root.info.scheduler.updating
	sch.root.info.scheduler.updating	= true;
	
	%add new tasks
		nAdd	= size(sch.root.info.scheduler.queue.add,2);
		
		if nAdd>0
			sch.root.info.scheduler.task(end+(1:nAdd))	= cell2struct(sch.root.info.scheduler.queue.add,sch.TASK_FIELD,1);
			sch.root.info.scheduler.queue.add(:,1:nAdd)	= [];
		end
	
	if sch.root.info.scheduler.lock_remove==0 && ~isempty(sch.root.info.scheduler.task)
	%remove old tasks
		%find newly finished tasks
			bCheck	= ~logical(bitget([sch.root.info.scheduler.task.mode],sch.MODE_FINISHED));
			
			bExpired	= tNow >= [sch.root.info.scheduler.task(bCheck).tSetEnd];
			bAborted	= logical(bitget([sch.root.info.scheduler.task(bCheck).mode],sch.MODE_ABORTED));
			bRemoved	= logical(bitget([sch.root.info.scheduler.task(bCheck).mode],sch.MODE_REMOVE));
			bEAR		= bExpired | bAborted | bRemoved;
			
			bFinished			= bCheck;
			bFinished(bCheck)	= bEAR;
			
		if any(bFinished)
		%remove tasks marked for removal or finished without results
			bNoResult		= bEAR;
			bNoResult(bEAR)	= [sch.root.info.scheduler.task(bFinished).nOut]==0;
			
			bRemove			= bFinished;
			bRemove(bCheck)	= ~bAborted & bNoResult;
			
			bMark	= bFinished & ~bRemove;
			if any(bMark)
			%just mark the ones with results
				mNew									= num2cell(bitset([sch.root.info.scheduler.task(bMark).mode],sch.MODE_FINISHED));
				[sch.root.info.scheduler.task(bMark).mode]	= deal(mNew{:});
			end
			
			if any(bRemove)
			%remove the others
				if sch.root.info.scheduler.lock_remove==0
					sch.root.info.scheduler.task(bRemove)	= [];
				end
			end
		end
	end
	
	sch.root.info.scheduler.updating	= false;
end
