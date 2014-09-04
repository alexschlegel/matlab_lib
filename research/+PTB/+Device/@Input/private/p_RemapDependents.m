function p_RemapDependents(inp,strButton)
% p_RemapDependents
% 
% Description:	recalculate the simplified definitions of all buttons that
%				include the button strButton in their nested definitions
% 
% Syntax:	p_RemapDependents(inp,strButton)
% 
% In:
% 	inp			- the Input object
%	strButton	- the button whose dependents should be remapped
% 
% Updated: 2011-12-21
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

cDependent	= PTBIFO.input.(inp.type).button.(strButton).dependents;
nDependent	= numel(cDependent);
cellfun(@(x) p_Remap(inp,x),cDependent);
