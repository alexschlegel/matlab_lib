function Clear(p)
% PsychoCurve.Clear
% 
% Description:	clear existing response data
% 
% Syntax:	p.Clear()
% 
% Updated: 2012-02-03
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
p.xStim		= [];
p.bResponse	= [];

p_Init(p);
