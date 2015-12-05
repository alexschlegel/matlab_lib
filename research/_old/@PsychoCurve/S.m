function y = S(p,xStim,bResponse)
% PsychoCurve.S
% 
% Description:	calculate the difference between a subject's response and that
%				predicted by their psychometric curve
% 
% Syntax:	S = p.S(xStim,bResponse)
% 
% In:
% 	xStim		- the stimulus value
%	bResponse	- the subject's response to the stimulus
% 
% Out:
% 	S	- a measure of the difference between the subject's response to the
%		  the stimulus and their response as predicted by their psychometric
%		  curve estimate
% 
% Updated: 2012-02-01
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
W	= weibull(xStim,p.t,p.b,p.xmin,p.g,p.a);
DW	= dtweibull(xStim,p.t,p.b,p.xmin,p.g,p.a);
y	= (bResponse - W).*DW./(W.*(1-W));

y(isnan(y) | isinf(y))	= 0;
