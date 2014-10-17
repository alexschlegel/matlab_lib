function l = va2l(va,d,varargin)
% va2l
% 
% Description:	convert a visual angle to a length
% 
% Syntax:	l = va2l(va,d,<options>)
% 
% In:
% 	l	- the visual angle (see 'va_unit' option)
%	d	- the distance between the object and the observer (see 'distance_unit'
%		  option)
%	<options>:
%		length_unit:	(<distance_unit>) the unit of the output, can be one of
%						the supported length units in UnitConvert or 'pixel'.
%		va_unit:		('degree') the unit of the object visual angle.  can be
%						either 'degree' or 'radian'.
%		distance_unit:	('inch') the unit of the distance between observer and
%						object
%		dpi:			(<calculate>) the number of pixels per inch on the
%						display monitor
% 
% Out:
% 	l	- the length of the object in the specified units
% 
% Updated: 2011-09-11
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'length_unit'	, []		, ...
		'va_unit'		, 'degree'	, ...
		'distance_unit'	, 'inch'	, ...
		'dpi'			, []		  ...
		);
if isempty(opt.length_unit)
	opt.length_unit	= opt.distance_unit;
end
if isempty(opt.dpi)
	opt.dpi	= get(0,'ScreenPixelsPerInch');
end

%convert visual angle to radians
	switch lower(opt.va_unit)
		case 'degree'
			va	= d2r(va);
		case 'radian'
			%nothin' to do
		otherwise
			error(['"' tostring(opt.va_unit) '" is not a valid visual angle unit.']);
	end
%convert distance unit to inches if necessary
	bConvert	= ~isequal(opt.length_unit,opt.distance_unit);
	if bConvert
		if ~isequal(lower(opt.distance_unit),'pixel')
			d	= ConvertUnit(d,opt.distance_unit,'inch');
		else
			d	= opt.distance_unit./opt.dpi;
		end
	end
%convert to length
	l	= 2*d.*tan(va/2);
%convert output units
	if bConvert
		if ~isequal(lower(opt.length_unit),'pixel')
			l	= ConvertUnit(l,'inch',opt.length_unit)
		else
			l	= round(l.*opt.dpi);
		end
	end
