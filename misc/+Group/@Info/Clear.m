function Clear(ifo)
% Group.Info.Clear
% 
% Description:	clear the info struct
% 
% Syntax:	ifo.Clear()
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if ~ifo.root.IsProp('info')
	addprop(ifo.root,'info');
end

ifo.Set({},struct);
