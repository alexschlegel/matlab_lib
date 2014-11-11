function str = StringMoney(x,varargin)
% StringMoney
% 
% Description:	format a number as a money amount
% 
% Syntax:	str = StringMoney(x,<options>) 
% 
% In:
% 	x	- a number representing an amount of money
%	<options>:
%		type:		('usd') a quick way to set the rest of the options.  one of
%					the following:
%						usd: 	display as US dollars
%						cent:	display as cents
%		round:		number of decimal places to round to 
%		unit:		the units to display
%		plural:		the units if plural
%		position:	either 'pre' or 'post' to specify where to place the units
%		sign:		(false) true to show the sign even if positive
% 
% Out:
% 	str	- the money string
% 
% Updated: 2013-09-25
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'type'		, 'usd'	, ...
		'round'		, []	, ...
		'unit'		, []	, ...
		'plural'	, []	, ...
		'position'	, []	, ...
		'sign'		, false	  ...
		);
switch opt.type
	case 'usd'
		optDefault	= struct('round',2,'unit','$','plural','$','position','pre');
	case 'cent'
		optDefault	= struct('round',0,'unit',' cent','plural',' cents','position','post');
	otherwise
		error(['"' tostring(opt.type) '" is not a valid currency type.']);
end

opt			= StructMerge(optDefault,opt);
opt.plural	= unless(opt.plural,opt.unit);

strUnit		= plural(x,opt.unit,opt.plural);

sx			= sign(x);
ax			= abs(x);
strAmount	= sprintf(['%0.' num2str(opt.round) 'f'],roundn(ax,-opt.round));

strSign	= conditional(sx>=0,conditional(opt.sign,'+',''),'-');

switch lower(opt.position)
	case 'pre'
		str	= [strSign strUnit strAmount];
	case 'post'
		str	= [strSign strAmount strUnit];
	otherwise
		error(['"' tostring(opt.position) '" is not a valid position.']);
end
