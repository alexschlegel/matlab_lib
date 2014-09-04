function x = FlipArray(x,varargin)
% FlipArray
% 
% Description:	transform an array via a series of flips and rotations
% 
% Syntax:	y = FlipArray(x,f1,[f2],...,[fN])
% 
% In:
% 	x	- the array
%	fK	- one of the following strings:
%			'CW':	rotate clockwise
%			'CCW':	rotate counter-clockwise
%			'H':	flip horizontally
%			'V':	flip vertically
% 
% Out:
% 	y	- the transformed array
% 
% Assumptions:	assumes x is at most two-dimensional
%
% Updated:	2008-01-23
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

for k=1:nargin-1
	fK	= varargin{k};
	
	switch upper(fK)
		case 'CW'
			x	= FlipArray(x','H');
		case 'CCW'
			x	= FlipArray(x','V');
		case 'H'
			x	= x(:,end:-1:1);
		case 'V'
			x	= x(end:-1:1,:);
		otherwise
			status(['Warning: "' fK '" is not recognized (skipping)']);
	end
end
