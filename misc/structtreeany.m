function s = structtreeany(s,varargin)
% structtreeany
% 
% Description:	amend a struct tree to include "any" elements that store struct
%				trees representing the merging of all elements at each level of
%				the tree hierarchy
% 
% Syntax:	s = structtreeany(s,<options>)
% 
% In:
% 	s	- a struct tree
%	<options>:
%		unique:		(true) true to only include unique values in the all arrays
%		ignore_all:	(true) true to ignore struct elements named 'all'
% 
% Out:
% 	s	- the amended struct tree
% 
% Updated: 2011-02-06
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'unique'		, true	, ...
		'ignore_all'	, true	  ...
		);

%get the any tree for the current level
	%get the substructs
		if isfield(s,'any')
			if opt.ignore_all
				cAll	= struct2cell(rmfield(s,{'all','any'}));
			else
				cAll	= struct2cell(rmfield(s,'any'));
			end
		else
			cAll	= struct2cell(s);
		end
	%remove non-structs
		cAll(cellfun(@(x) ~isa(x,'struct'),cAll))	= [];
	%merge the substructs
		s.any	= StructMerge(cAll{:},'method','append','unique',opt.unique);
%do the same for each substruct
	cField	= fieldnames(s);
	nField	= numel(cField);
	
	for kF=1:nField
		if isa(s.(cField{kF}),'struct')
			s.(cField{kF})	= structtreeany(s.(cField{kF}),'unique',opt.unique);
		end
	end
