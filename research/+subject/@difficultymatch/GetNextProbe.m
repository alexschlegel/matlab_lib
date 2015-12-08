function d = GetNextProbe(obj,varargin)
% subject.difficultymatch.GetNextProbe
% 
% Description:	use a stair stepping procedure to calculate the next probe value
%				for a task
% 
% Syntax: d = obj.GetNextProbe([kTask]=1)
%
% In:
%	[kTask]	- the next task to probe
%
% Out:
%	d	- the next probe difficulty
% 
% Updated:	2015-12-07
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
kTask	= ParseArgs(varargin,1);

%just return the previously calculated d if it exists
	if ~isnan(obj.dNext(kTask))
		d	= obj.dNext(kTask);
		return;
	end

%get the task history
	sHistory	= obj.GetTaskHistory(kTask);
	nProbe		= numel(sHistory.d);

%determine the new difficulty position
	if nProbe>0
		%new speed
			if nProbe>1 && sHistory.result(end) == sHistory.result(end-1)
				obj.speed(kTask)	= obj.speed(kTask) + obj.acceleration(kTask);
			else
				obj.speed(kTask)	= obj.acceleration(kTask);
			end
		
		%direction of movement
			bLast	= sHistory.result(end);
			sgn		= conditional(bLast,1,-1);
		
		%calculate the new target performance that would lead to the original
		%target performance if achieved for the remainder of the experiment,
		%i.e.:
		%	(fTargetAlready.*nProbe + fTargetNew*nProbeRemain)/nTotal = obj.target
			fTargetAlready	= mean(sHistory.result);
			nProbeRemain	= obj.n - nProbe;
			
			fTarget	= (obj.target*obj.n - fTargetAlready*nProbe)/nProbeRemain;
			
			%don't let the target stray more than half way to the edge from the
			%original target, to make sure things don't get too crazy
				fTargetMax	= obj.target + (1 - obj.target)/2;
				fTargetMin	= obj.target/2;
				
				fTarget	= max(fTargetMin,min(fTargetMax,fTarget));
		
		%bias the direction so we the probes gravitate around our target result.
		%we want left and right movements to cancel out on average when the
		%subject is performing according to the target, i.e.:
		%	t*bias1 = (1-t)*bias2
		%and to keep the bias==1 on average.  therefore:
		%	bias1 = 1/(2t)
		%	bias2 = 1/(2(1-t))
			bias	= conditional(bLast,1/(2*fTarget),1/(2*(1-fTarget)));
		
		%new position
			obj.position(kTask)	= min(1,max(0,obj.position(kTask) + sgn*bias*obj.speed(kTask)));
	end

%record the newly calculated d
	[d,obj.dNext(kTask)]	= deal(obj.position(kTask));
