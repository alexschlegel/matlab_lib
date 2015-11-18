function x = validate_coordinate_type(obj,x,xy)
% stimulus.image.scribble.validate_coordinate_type
% 
% Description:	validate a coordinate type value
% 
% Syntax: x = obj.validate_coordinate_type(x,xy)
% 
% In:
%	x	- the coordinate type
%	xy	- either 'x' or 'y' to specify which coordinate type we are validating
%
% Out:
%	x	- the validated coordinate type
% 
% Updated:	2015-11-17
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
strName	= sprintf('%s_type',xy);

switch class(x)
	case 'function_handle'
		n	= nargin(x);
		assert(n==1 || n==-2,'%s function must take one required argument',strName);
	case 'char'
		x	= CheckInput(x,strName,{'random','step','increase','decrease'});
	otherwise
		error('%s cannot be of class "%s"',strName,class(x));
end
