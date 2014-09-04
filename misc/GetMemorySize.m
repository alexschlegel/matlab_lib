function B = GetMemorySize(s,varargin)
% GetMemorySize
% 
% Description:	get the size, in bytes, of a variable with the specified
%				dimensions
% 
% Syntax:	B = GetMemorySize(s,[strType]='double',[nVar]=1) OR
%			B = GetMemorySize(s,nByteElement,[nVar]=1)
% 
% In:
% 	s				- the size of the variable
%	nByteElement	- the number of bytes occupied by a single element of the
%					  matrix being created
%	[strType]		- the data type
%	[nVar]			- calculates the size of nVar copies of s
% 
% Out:
% 	B	- the size, in bytes, of the specified variable(s)
% 
% Updated:	2009-03-19
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[strType,nVar]	= ParseArgs(varargin,'double',1);

%get the size of a single element of the data type
	if ischar(strType)
		x	= cast(0,strType);
		w	= whos('x');
		b	= w.bytes;
	else
		b	= strType;
	end
	
%get the total size in memory
	B	= b*prod(s)*nVar;
