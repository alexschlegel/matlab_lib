function p_Remap(inp,strButton)
% p_Remap
% 
% Description:	recalculate the simplified definition of a button
% 
% Syntax:	p_Remap(inp,strButton)
% 
% In:
% 	inp			- the Input object
%	strButton	- the button that should be remapped
% 
% Updated: 2011-12-21
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

p_Map(inp,strButton,PTBIFO.input.(inp.type).button.(strButton).def.good,PTBIFO.input.(inp.type).button.(strButton).def.bad);
