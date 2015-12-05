function y = P(p,xStim)
% PsychoCurve.P
% 
% Description:	the predicted response rate at a stimulus value
% 
% Syntax:	P = p.P(xStim)
% 
% In:
% 	xStim		- the stimulus value
% 
% Out:
% 	P	- the predicted fraction of the trials with stimulus value xStim for
%		  which the subject is predicted to respond true
% 
% Updated: 2012-02-01
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
y	= weibull(xStim,p.t,p.b,p.xmin,p.g,p.a);
