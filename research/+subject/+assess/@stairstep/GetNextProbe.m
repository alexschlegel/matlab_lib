function d = GetNextProbe(obj)
% subject.assess.stairstep.GetNextProbe
% 
% Description:	calculate the next probe value, between 0 and 1
% 
% Syntax: d = obj.GetNextProbe()
% 
% Updated:	2015-12-02
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

nProbe	= numel(obj.history.record);

%increment the stickiness counter if we have two of the same results in a row
	if nProbe>0
		if nProbe>1 && obj.history.record(end).result == obj.history.record(end-1).result
			obj.stickinessCounter	= obj.stickinessCounter + 1;
		else
			obj.speed				= 0;
			obj.stickinessCounter	= 1;
		end
	end

%increase the step size
	if obj.stickinessCounter == obj.stickiness
		obj.speed	= obj.speed + obj.acceleration;
		
		obj.stickinessCounter	= 0;
	end

%move in the direction of the last result
	if obj.speed>0
		bLast	= obj.history.record(end).result;
		
		sgn	= conditional(bLast,1,-1);
		
		%bias the direction so we get the most probes around our target result
		%we want left and right movements to cancel out on average when the
		%subject is performing according to the target, i.e.:
		%	t*bias1 = (1-t)*bias2
		%and to keep the bias==1 on average.  therefore:
		%	bias1 = 1/(2t)
		%	bias2 = 1/(2(1-t))
			bias	= conditional(bLast,1/(2*obj.target),1/(2*(1-obj.target)));
		
		obj.position	= min(1,max(0,obj.position + sgn*bias*obj.speed));
	end

%find the difficulty that is closest to this point
	dDiff	= abs(obj.position - obj.d);
	kClose	= find(dDiff==min(dDiff),1);
	d		= obj.d(kClose);

%make sure this point isn't being probed too much
	nD				= numel(obj.d);
	nSampleTotal	= numel(obj.history.record);
	nSampleD		= obj.history.n(obj.history.d==d);
	
	if nSampleD/nSampleTotal > obj.maxweight/nD
		d	= randFrom(obj.d,...
				'exclude'	, d		, ...
				'seed'		, false	  ...
				);
	end

