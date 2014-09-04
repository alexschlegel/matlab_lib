function s = StructCollapse(s,varargin)
% StructCollapse
% 
% Description:	collapse a struct array into a 1x1 struct
% 
% Syntax:	s = StructCollapse(s,<options>)
% 
% In:
% 	s	- the struct to collapse
%	<options>:
%		method:	('last') the method to use to merge existing struct elements:
%					'last':		keep the last entry
%					'first':	keep the first entry
%					'append':	append all entries
%		unique:	(false) true to only keep unique values for each merge operation
% 
% Out:
% 	s	- the merged struct
% 
% Updated: 2011-12-07
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
cS	= num2cell(s);
s	= StructMerge(cS{:},varargin{:});
