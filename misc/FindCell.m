function varargout = FindCell(c,v,varargin)
% FindCell
% 
% Description:	find the elements of cell c that equal v
% 
% Syntax:	k = FindCell(c,v,[nLimit]=<all>,[strLimitDir]='first') OR
%			[k1,...,kN] = FindCell(c,v,[nLimit]=<all>,[strLimitDir]='first')
% 
% In:
% 	c				- a k1 x ... x kN cell
%	v				- the value to check for
%	[nLimit]		- find at most this number of elements
%	[strLimitDir]	- either 'first' or 'last' to find the first or last
%					  elements that match
% 
% Out:
% 	k	- the 1D indices of elements of c that equal v
%	kK	- a vector of Kth coordinates of the elements of c that equal v
% 
% Updated:	2010-11-24
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[nLimit,strLimitDir]	= ParseArgs(varargin,inf,'first');

n	= numel(c);
s	= size(c);

switch lower(strLimitDir)
	case 'first'
		kStep	= 1:n;
	case 'last'
		kStep	= n:-1:1;
	otherwise
		error(['"' tostring(strLimitDir) '" is an invalid value for strLimitDir.']);
end

b		= false(s);
nFound	= 0;
for k=kStep
	if nFound>=nLimit
		break;
	end
	if isequalwithequalnans(c{k},v)
		nFound	= nFound+1;
		b(k)	= true;
	end
end

k	= find(b);

if nargout>1
	[varargout{1:nargout}]	= ind2sub(s,k);
else
	varargout{1}	= k;
end
