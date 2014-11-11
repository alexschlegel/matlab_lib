function strYN = b2yn(b,varargin)
% b2yn
% 
% Description:	convert a boolean value to a yes/no value
% 
% Syntax:	strYN = b2yn(b,<options>)
% 
% In:
% 	b	- a boolean value
%	<options>:
%		'type':		('long') 'long' or 'short' to specify yes/no or y/n output
%		'upper':	(false) true to return an uppercase string
% 
% Updated: 2010-02-25
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'type',		'long'	, ...
		'upper',	false	  ...
		);

switch opt.type
	case 'long'
		yn	= {'yes','no'};
	case 'short'
		yn	= {'y','n'};
	otherwise
		error(['Output type "' opt.type '" is unrecognized.']);
end
m	= mapping({true,false},yn);

strYN	= m(b);

if opt.upper
	strYN	= upper(strYN);
end
