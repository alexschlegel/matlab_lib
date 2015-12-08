function d = GetNextProbe(obj,s)
% subject.assess.stairstep.GetNextProbe
% 
% Description:	use a stair stepping procedure to calculate the next probe value
%				for a task
% 
% Syntax: d = obj.GetNextProbe(s)
%
% In:
%	s	- a struct of info about the task to probe (see GetTaskInfo)
%
% Out:
%	d	- the next probe difficulty
% 
% Updated:	2015-12-04
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nProbe	= numel(s.history.d);

%increment the stickiness counter if we have two of the same results in a row
	if nProbe>0
		if nProbe>1 && s.history.result(end) == s.history.result(end-1)
			obj.stickinessCounter(s.task)	= obj.stickinessCounter(s.task) + 1;
		else
			obj.speed(s.task)				= 0;
			obj.stickinessCounter(s.task)	= 1;
		end
	end

%increase the step size
	if obj.stickinessCounter(s.task) == obj.stickiness
		obj.speed(s.task)	= obj.speed(s.task) + obj.acceleration;
		
		obj.stickinessCounter(s.task)	= 0;
	end

%move in the direction of the last result
	if obj.speed(s.task)>0
		bLast	= s.history.result(end);
		
		sgn	= conditional(bLast,1,-1);
		
		%bias the direction so we get the most probes around our target result
		%we want left and right movements to cancel out on average when the
		%subject is performing according to the target, i.e.:
		%	t*bias1 = (1-t)*bias2
		%and to keep the bias==1 on average.  therefore:
		%	bias1 = 1/(2t)
		%	bias2 = 1/(2(1-t))
			bias	= conditional(bLast,1/(2*s.estimate.target),1/(2*(1-s.estimate.target)));
		
		obj.position(s.task)	= min(1,max(0,obj.position(s.task) + sgn*bias*obj.speed(s.task)));
	end

%find the difficulty that is closest to this point
	dDiff	= abs(obj.position(s.task) - obj.d);
	kClose	= find(dDiff==min(dDiff),1);
	d		= obj.d(kClose);

%make sure this point isn't being probed too much
	nD				= numel(obj.d);
	nSampleD		= s.performance.n(s.performance.d==d);
	
	if nSampleD/nProbe > obj.maxweight/nD
		d	= randFrom(obj.d,...
				'exclude'	, d		, ...
				'seed'		, false	  ...
				);
	end
