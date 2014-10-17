function str = StringTime(x,varargin)
% StringTime
% 
% Description:	format a number as a time string
% 
% Syntax:	str = StringTime(x,<options>) 
% 
% In:
% 	x	- a number representing an amount of time
%	<options>:
%		round:	(2) number of decimal places to round to 
%		unit:	(<none>) the units to display
%		plural:	(<units>+s) the units if plural
% 
% Out:
% 	str	- the time string
% 
% Updated: 2010-10-30
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'round'		, 2		, ...
		'unit'		, ''	, ...
		'plural'	, ''	  ...
		);
if isempty(opt.plural) && ~isempty(opt.unit)
	opt.plural	= [opt.unit 's'];
end

strUnit	= conditional(isempty(opt.unit),'',[' ' plural(x,opt.unit,opt.plural)]);

str	= [num2str(roundn(x,-opt.round)) strUnit];
