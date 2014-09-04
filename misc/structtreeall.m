function s = structtreeall(s,varargin)
% structtreeall
% 
% Description:	amend a struct tree to include "all" elements that store all
%				values found downstream of each node
% 
% Syntax:	s = structtreeall(s,<options>)
% 
% In:
% 	s	- a struct tree
%	<options>:
%		unique:		(true) true to only include unique values in the all arrays
%		numeric:	(<if all elements are scalar>) true to convert the all
%					arrays to numeric arrays
%		ignore_any:	(true) ignore struct elements named "any"
% 
% Out:
% 	s	- the amended struct tree
% 
% Updated: 2011-02-05
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'unique'		, true	, ...
		'numeric'		, []	, ...
		'ignore_any'	, true	  ...
		);

%get each subfield's values
	cField	= setdiff(fieldnames(s),'all');
	if opt.ignore_any
		cField	= setdiff(cField,'any');
	end
	nField	= numel(cField);
	
	cAll	= [];
	for kF=1:nField
		if isstruct(s.(cField{kF}))
			s.(cField{kF})	= structtreeall(s.(cField{kF}),'unique',opt.unique,'numeric',opt.numeric);
			cAll			= [cAll; s.(cField{kF}).all];
		else
			if notfalse(opt.numeric) || (isempty(opt.numeric) && isscalar(s.(cField{kF})))
				cAll	= [cAll; s.(cField{kF})];
			else
				cAll	= [cAll; {s.(cField{kF})}];
			end
		end
	end
%set the all element
	if opt.unique
		cAll	= unique(cAll);
	end
	
	s.all	= cAll;
