function x = ConvertUnit(x,strFrom,strTo)
% ConvertUnit
% 
% Description:	convert an array of values from one unit to another
% 
% Syntax:	x = ConvertUnit(x,strFrom,strTo)
% 
% In:
% 	x		- an array
%	strFrom	- the input unit
%	strTo	- the output unit
% 
% Out:
% 	x	- the array in output units
% 
% Notes:	supported units (along with M/K/c/m/u- or mega/kilo/centi/milli/micro-):
%				length:		meter, m, inch, in, foot, ft, yard, yd, mile, mi
%				time:		second, s, minute, hour, day, week
%				voltage:	Volt, V
% 
% Updated: 2014-02-08
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
persistent ifo;

if isempty(ifo)
	%unit value in terms of common space 
		ifo.unit	= {'second',	'minute',	'hour',	'day',	'week',	'volt',	'meter',	'inch',		'foot',		'yard',		'mile'};
		ifo.unitn	= [1			60			3600	86400	86400*7	1		1			2.54/100	12*2.54/100	36*2.54/100	5280*12*2.54/100];
	
	ifo.unitabb		= {'s',	'V',	'm',	'in',		'ft',		'yd',		'mi'};
	ifo.unitabbn	= [1 	1		1		2.54/100	12*2.54/100	36*2.54/100	5280*12*2.54/100];
	
	ifo.mult		= {'mega',	'kilo',	'centi',	'milli',	'micro'};
	ifo.multn		= [1e6		1e3		1e-2		1e-3		1e-6];
	ifo.multabb		= {'M',	'K',	'k',	'c',	'm',	'u'};
	ifo.multabbn	= [1e6	1e3		1e3		1e-2	1e-3	1e-6];
	
	ifo.re.full		= ['^(?<mult>(' join(ifo.mult,')|(') '))?(?<unit>(' join(ifo.unit,')|(') '))$'];
	ifo.re.abb		= ['^(?<mult>(' join(ifo.multabb,')|(') '))?(?<unit>(' join(ifo.unitabb,')|(') '))$']; 
end	

%break up the unit and the multiplier
	[strUnitFrom,strTypeFrom,strMultFrom]	= SplitUnit(strFrom);
	[strUnitTo,strTypeTo,strMultTo]			= SplitUnit(strTo);
%get the conversion to the common space
	mTo		= ConvertCommon(strUnitFrom,strTypeFrom,strMultFrom);
%get the conversion from the common space
	mFrom	= ConvertCommon(strUnitTo,strTypeTo,strMultTo);
%convert
	x	= mTo/mFrom*x;

%------------------------------------------------------------------------------%
function [strUnit,strType,strMult] = SplitUnit(str)
	res	= regexp(str,ifo.re.full,'names');
	if ~isempty(res)
		strUnit	= res.unit;
		strMult	= res.mult;
		strType	= '';
	else
		res	= regexp(str,ifo.re.abb,'names');
		if ~isempty(res)
			strUnit	= res.unit;
			strMult	= res.mult;
			strType	= 'abb';
		else
			error(['"' tostring(str) '" is an unrecognized unit.']);
		end
	end
end
%------------------------------------------------------------------------------%
function m = ConvertCommon(strUnit,strType,strMult)
	bUnit	= strcmp(strUnit,ifo.(['unit' strType]));
	bMult	= strcmp(strMult,ifo.(['mult' strType]));
	
	mUnit	= ifo.(['unit' strType 'n'])(bUnit);
	
	if ~any(bMult)
		mMult	= 1;
	else
		mMult	= ifo.(['mult' strType 'n'])(bMult);
	end
	
	m	= mUnit*mMult;
end
%------------------------------------------------------------------------------%

end