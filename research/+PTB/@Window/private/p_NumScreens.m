function n = p_NumScreens()
% p_NumScreens
% 
% Description:	get the number of screens
% 
% Syntax:	n = p_NumScreens()
% 
% Updated: 2011-12-10
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
s	= Screen('Screens');
n	= numel(s);

if ispc && n>1
	n	= 	n-1;
end
