function B = GetMemorySizeOfElement(vType)
% GetMemorySizeOfElement
% 
% Description:	get the number of bytes occupied by a single element of the
%				specified variable type
% 
% Syntax:	B = GetMemorySizeOfElement(vType)
% 
% In:
% 	vType	- either a string specifying a class, or a number specifying the 
%			  number of bytes occupied by the element
% 
% Out:
% 	B	- number of bytes occupied by a single element of the specified variable
%		  type
% 
% Updated:	2009-03-20
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if ischar(vType)
	x	= cast(0,vType);
	w	= whos('x');
	B	= w.bytes;
else
	B	= vType;
end
