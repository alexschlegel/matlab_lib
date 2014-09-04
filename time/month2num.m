function n = month2num(strMonth)
% month2num
% 
% Description:	convert a month string to a month number
% 
% Syntax:	n = month2num(strMonth)
% 
% In:
% 	strMonth	- a string representing the month (e.g. 'January', 'apr.', etc.)
% 
% Out:
% 	n	- the month as a number, with January->1
% 
% Updated: 2010-04-13
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

strMonth	= strrep(strMonth,'.','');

if ischar(strMonth)
	switch lower(strMonth)
		case {'january','jan'}
			n	= 1;
		case {'february','feb'}
			n	= 2;
		case {'march','mar'}
			n	= 3;
		case {'april','apr'}
			n	= 4;
		case {'may'}
			n	= 5;
		case {'june','jun'}
			n	= 6;
		case {'july','jul'}
			n	= 7;
		case {'august','aug'}
			n	= 8;
		case {'september','sept','sep'}
			n	= 9;
		case {'october','oct'}
			n	= 10;
		case {'november','nov'}
			n	= 11;
		case {'december','dec'}
			n	= 12;
		otherwise
			error(['"' strMonth '" is unrecognized.']);
	end
elseif ismember(strMonth,1:12)
	n	= strMonth;
else
	error('Unrecognized input');
end