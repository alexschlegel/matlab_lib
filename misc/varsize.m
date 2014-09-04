function s = varsize(x)
% varsize
% 
% Description:	return the size, in bytes, of variable x
% 
% Syntax:	s = varsize(x)
% 
% Updated: 2010-11-24
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
s	= whos('x');
s	= s.bytes;
