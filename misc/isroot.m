function b = isroot
% isroot
% 
% Description:	check to see if MATLAB was started by root
% 
% Syntax:	b = isroot
% 
% Updated: 2012-03-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
b	= isequal(getenv('USERNAME'),'root');
