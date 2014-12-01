function str = naturalangle(a,varargin)
% naturalangle
% 
% Description:	construct a string representation of an angle
% 
% Syntax:	str = naturalangle(a,<options>)
% 
% In:
% 	a	- the angle, in degrees
%	<options>:
%		orientation:	(false) true to construct the string as an orientation
%		compact:		(false) true to construct a compact string
% 
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'orientation'	, false	, ...
		'compact'		, false	  ...
		);

a	= fixangle(a);

switch a
	case 0
		str	= '';
	case 180
		str	= [num2str(abs(a)) 176];
	otherwise
		if opt.compact
			direction	= conditional(a>0,' CW',' CCW');
		else
			direction	= conditional(a>0,' clockwise',' counterclockwise');
		end
		
		orient	= conditional(opt.orientation,' rotated','');
		str		= [num2str(abs(a)) 176 direction orient];
end
