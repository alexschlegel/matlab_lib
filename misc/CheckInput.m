function x = CheckInput(x,strName,cValue,varargin)
% CheckInput
% 
% Description:	check to make sure a valid input was passed 
% 
% Syntax:	x = CheckInput(x,strName,cValue,<options>)
% 
% In:
% 	x		- the input
%	strName	- a descriptive name for the input
%	cValue	- a an array or cell of acceptable values
%	<options>:
%		casei:	(true) true if matching should be case-insensitive.  if true, the
%				output value is lower case.
%		tol:	(2*eps) the tolerance for checking against numeric arrays
%		f_disp:	(<do nothing>) the handle to a function that converts elements
%				of cValue into a string suitable for display
% 
% Out:
% 	x	- the formatted input
% 
% Updated: 2013-07-28
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%speed 'er up
	opt	= ParseArgs(varargin,...
			'casei'		, true	, ...
			'tol'		, 2*eps	, ...
			'f_disp'	, []	  ...
			);

if opt.casei && ischar(x)
	x	= lower(x);
end

if iscell(cValue)
	bCharValid		= cellfun(@ischar,cValue);
	bAllCharValid	= all(bCharValid);
	bCharInput		= ischar(x);
	
	if opt.casei
		cValue(bCharValid)	= cellfun(@lower,cValue(bCharValid),'uni',false);
	end
	
	bError	= (bAllCharValid && (~bCharInput || ~ismember(x,cValue))) || ~IsMemberCell({x},cValue);
elseif isnumeric(cValue)
	bError	= ~isscalar(x) || ~any(abs(x - cValue)<opt.tol);
elseif islogical(cValue)
	bError	= ~isscalar(x) || ~islogical(x) || ~any(x==cValue);
else
	try
		x		= CheckInput(x,strName,{cValue},varargin{:});
		bError	= false;
	catch me
		throw(me);
		return;
	end
end

if bError
	if ischar(x)
		strX	= ['''' x ''''];
	else
		strX	= tostring(x,16);
	end
	
	if ~isempty(opt.f_disp)
		if ~iscell(cValue)
			cValue	= num2cell(cValue);
		end
		
		cValueDisp	= cellfun(@opt.f_disp,cValue,'uni',false);
	else
		cValueDisp	= cValue;
		
		if iscell(cValueDisp) && ~bAllCharValid
			cValueDisp	= UniqueCell(cValueDisp);
		else
			cValueDisp	= unique(cValueDisp);
		end
	end
	
	strValid	= ['Valid values are: ' join(cValueDisp,', ') '.'];
	
	error([strX ' is an invalid ' strName '.  ' strValid]);
end
