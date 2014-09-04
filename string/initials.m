function strInit = initials(strName)
% initials
% 
% Description:	get the initials of a person based on his/her full name
% 
% Syntax:	strInit = initials(strName)
% 
% Updated: 2012-02-22
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
strName	= regexprep(strName,'[^A-Za-z ]','');

kSpace	= find(strName==' ',1);

strInit	= lower([strName(1) strName(kSpace+1)]);
