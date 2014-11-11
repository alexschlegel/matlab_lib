function strCaller	= caller(varargin)
% caller
% 
% Description:	return the name of the function that called the function calling
%				caller
% 
% Syntax:	strCaller	= caller([nLevel]=1,<options>)
% 
% In:
% 	[nLevel]	- return the name of the caller nLevel levels up
%	<options>:
%		all:	(false) true to return an underscore separated string of the
%				callers from the specified level up
% 
% Out:
% 	strCaller	- the function name
% 
% Updated:	2013-02-04
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
persistent nLevelDefault optDefault cOptDefault;

if isempty(optDefault)
	nLevelDefault	= 1;
	optDefault		= struct(...
						'all'	, false	  ...
						);
	cOptDefault		= opt2cell(optDefault);
end

if nargin>0
	[nLevel,opt]	= ParseArgs(varargin,nLevelDefault,cOptDefault{:});
else
	nLevel	= nLevelDefault;
	opt		= optDefault;
end

s	= dbstack;

nLevel	= nLevel + 2;

if numel(s)>=nLevel
	if opt.all
		strCaller	= join({s(nLevel:end).name},'_');
	else
		strCaller	= s(nLevel).name;
	end
else
	strCaller	= '';
end
