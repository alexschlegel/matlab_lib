function s = StructMerge(varargin)
% StructMerge
% 
% Description:	merge multiple structs into one, keeping later fields in case of
%				conflict
% 
% Syntax:	s = StructMerge(s1,...,sN)
% 
% In:
% 	sK	- the Kth struct to merge
% 
% Out:
% 	s	- the merged struct
% 
% Updated: 2015-03-22
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if nargin==0
	s	= struct;
	return;
else
	s	= varargin{end};
end

for kS=nargin-1:-1:1
	sCur		= varargin{kS};
	cField		= fieldnames(sCur);
	cFieldAdd	= cField(~isfield(s,cField));
	nFieldAdd	= numel(cFieldAdd);
	
	for kF=1:nFieldAdd
		strField		= cFieldAdd{kF};
		s.(strField)	= sCur.(strField);
	end
end
