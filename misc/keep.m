function keep(varargin)
% KEEP
% 
% Description:	clear all variable except those that match strRegExp
% 
% Syntax:	keep(strRegExp1,strRegExp2,...)
% 
% In:
% 	strRegExpK	- a regular expression string
% 
% Side-effects:	clears any variable that doesn't match one of the passed regexps
% 
% Updated:	2007-12-06
% Copyright 2007 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
vars	= evalin('base','who');

for k=1:numel(vars)
	bMatch	= false;
	for kRE=1:nargin
		if numel(regexp(vars{k},varargin{kRE}))
			bMatch	= true;
			break;
		end
	end
	if ~bMatch
		evalin('base',['clear ' vars{k}]);
	end
end
