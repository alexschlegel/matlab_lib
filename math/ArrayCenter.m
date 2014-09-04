function varargout = ArrayCenter(x)
% ArrayCenter
% 
% Description:	get the center coordinate of an array
% 
% Syntax:	p           = ArrayCenter(x) OR
%			[k1,...,kN] = ArrayCenter(x)
% 
% In:
% 	x	- an N-dimensional array
% 
% Out:
% 	p	- an N x 1 vector specifying the coordinates of the point at the center
%		  of the array
%	kK	- the Kth coordinate of the center of the array
% 
% Updated: 2012-03-29
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
p	= reshape(size(x)/2,[],1) + 0.5;

if nargout>1
	varargout	= num2cell(p);
else
	varargout	= {p};
end
