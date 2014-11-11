function va = l2va(l,d,varargin)
% l2va
% 
% Description:	convert a length to a visual angle
% 
% Syntax:	va = l2va(l,d,<options>)
% 
% In:
% 	l	- the length (see 'length_unit' option)
%	d	- the distance between the object and the observer (see 'distance_unit'
%		  option)
%	<options>:
%		va_unit:		('degree') the unit of the output, either 'degree' or
%						'radian'
%		length_unit:	('meter') the unit of the object length.  can be one of
%						the supported length units in ConvertUnit or 'pixel'.
%		distance_unit:	(<length_unit>) the unit of the distance between
%						observer and object
%		dpi:			(<calculate>) the number of pixels per inch on the
%						display monitor
% 
% Out:
% 	va	- the visual angle of the object in the specified units
% 
% Updated: 2011-12-05
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'va_unit'		, 'degree'	, ...
		'length_unit'	, 'meter'	, ...
		'distance_unit'	, []		, ...
		'dpi'			, []		  ...
		);
if isempty(opt.distance_unit)
	opt.distance_unit	= opt.length_unit;
end
if isempty(opt.dpi)
	opt.dpi	= get(0,'ScreenPixelsPerInch');
end

%convert length units to inches if necessary
	if ~isequal(opt.length_unit,opt.distance_unit)
		if ~isequal(lower(opt.length_unit),'pixel')
			l	= ConvertUnit(l,opt.length_unit,'in');
		else
			l	= l./opt.dpi;
		end
		
		if ~isequal(lower(opt.distance_unit),'pixel')
			d	= ConvertUnit(d,opt.distance_unit,'in');
		else
			d	= d./opt.dpi;
		end
	end
%convert to visual angle, in radians
	va	= 2*atan(l./(2*d));
%convert output units
	switch lower(opt.va_unit)
		case 'degree'
			va	= r2d(va);
		case 'radian'
			%nothin' to do
		otherwise
			error(['"' tostring(opt.va_unit) '" is not a valid visual angle unit.']);
	end
