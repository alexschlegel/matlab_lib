function pout = punion(p)
% punion
% 
% Description:	calculate the probability of occurrence of any one of a set of
%				independent events
% 
% Syntax:	p = punion(p)
% 
% In:
% 	p	- an array specifying the probability of each event
% 
% Out:
% 	p	- the probability that any one of the events will occur
% 
% Updated: 2013-11-10
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
np	= numel(p);

pout	= 0;

for k=1:np
	pout	= p(k) + pout - p(k)*pout;
end
