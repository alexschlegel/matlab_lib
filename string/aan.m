function a = aan(str)
% aan
% 
% Description:	quick and dirty way to determine if a string should be preceded
%				by 'a' or 'an'
% 
% Syntax:	a = aan(str)
% 
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
a	= conditional(numel(str)==0 || ~ismember(str(1),'aeiou'),'a','an');
