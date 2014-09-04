function p_GetFit(p)
% p_GetFit
% 
% Description:	calculate the fit curve given current parameters
% 
% Syntax:	p_GetFit(p)
% 
% Updated: 2012-02-01
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
p.ffit	= p.P(p.x);

p_CalcF(p);

if numel(p.f)==numel(p.ffit)
	p.r2	= corrcoef2(p.f,p.ffit').^2;
	p.se	= 1/sqrt(nansum(p.I(p.xStim)));
end
