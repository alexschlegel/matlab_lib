function s = structadd(s,sNew)
% structadd
% 
% Description:	add a new element to a struct array, expanding the fieldnames if
%				required
% 
% Syntax:	s = structadd(s,sNew)
% 
% In:
%	s		- a struct array
% 	sNew	- a new struct to append to the end of the array
% 
% Out:
% 	s	- the appended struct array
% 
% Updated: 2012-12-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if isempty(s)
	s	= sNew;
else
	cFieldOld	= fieldnames(s);
	cFieldNew	= fieldnames(sNew);
	
	if ~isequal(cFieldOld,cFieldNew)
		cFieldAdd	= setdiff(cFieldNew,cFieldOld);
		nFieldAdd	= numel(cFieldAdd);
		for kF=1:nFieldAdd
			s(end).(cFieldAdd{kF})	= [];
		end
		
		cFieldAdd	= setdiff(cFieldOld,cFieldNew);
		nFieldAdd	= numel(cFieldAdd);
		for kF=1:nFieldAdd
			sNew.(cFieldAdd{kF})	= [];
		end
		
		sNew	= orderfields(sNew,s);
	end
	
	s(end+1)	= sNew;
end
