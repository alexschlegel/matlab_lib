function Step(obj)
% subject.assess.base.Step
% 
% Description:	run one step of the assessment
% 
% Syntax: obj.Step()
% 
% Updated:	2015-12-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%determine the next probe value
	if isempty(obj.history)
		d	= obj.ability;
	else
		d	= obj.GetNextProbe();
	end
	
	%find the closest allowed d value
		dDiff	= abs(d - obj.d);
		kClose	= find(dDiff==min(dDiff),1);
		d		= obj.d(kClose);

%probe the subject
	b	= obj.f(d);

%append the probe to the history
	obj.AppendProbe(d,b);
