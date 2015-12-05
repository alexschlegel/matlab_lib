function p_CalcF(p)
% p_CalcF
% 
% Description:	calculate the fraction of true responses for each x value
% 
% Syntax:	p_CalcF(p)
% 
% Updated: 2012-02-01
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if numel(p.xStim)==numel(p.bResponse)
	nX			= numel(p.x);
	[p.f,p.n]	= deal(NaN(nX,1));
	
	for kX=1:nX
		bX		= p.xStim==p.x(kX);
		p.n(kX)	= sum(bX);
		p.f(kX)	= sum(p.bResponse(bX))/p.n(kX);
	end
end
