function y = I(p,xStim)
% PsychoCurve.I
% 
% Description:	calculate the amount of information revealed by a test at a
%				particular stimulus value
% 
% Syntax:	I = p.I(xStim)
% 
% In:
% 	xStim	- the stimulus value
% 
% Out:
% 	I	- the information revealed by a presentation of the stimulus
% 
% Updated: 2012-02-01
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
W	= weibull(xStim,p.t,p.b,p.xmin,p.g,p.a);
DW	= dtweibull(xStim,p.t,p.b,p.xmin,p.g,p.a);
y	= DW.^2./(W.*(1-W));

y(isnan(y) | isinf(y))	= 0;
