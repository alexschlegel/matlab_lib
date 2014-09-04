function cButton = ButtonNames(inp)
% PTB.Device.Input.ButtonNames
% 
% Description:	get the names of all defined buttons
% 
% Syntax:	cButton = inp.ButtonNames()
% 
% Updated: 2011-12-21
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

cButton	= fieldnames(PTBIFO.input.(inp.type).button);
