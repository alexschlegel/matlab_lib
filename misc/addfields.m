function s = addfields(s,cField)
% addfields
% 
% Description:	add fields to a struct
% 
% Syntax:	s = addfields(s,cField)
% 
% In:
% 	s		- a struct array
%	cField	- the fields to add
% 
% Out:
% 	s	- the struct with the fields added 
% 
% Updated: 2012-07-09
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nField	= numel(cField);

for kF=1:nField
	if ~isfield(s,cField{kF});
		s(end).(cField{kF})	= [];
	end
end
