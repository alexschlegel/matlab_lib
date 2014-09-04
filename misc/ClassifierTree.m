function b = ClassifierTree(varargin)
% ClassifierTree
% 
% Description:	construct a tree that classifies the elements of an array into
%				one state of a compound classification scheme
% 
% Syntax:	b = ClassifierTree(s1,s2,...,sN,<options>)
% 
% In:
% 	sK	- a tree struct of boolean arrays, each one the same size (across
%		  structs as well) denoting which elements of the array belong to the
%		  specified state of a single property.  For example, if the Kth struct
%		  classifies the elements based on color, then sK would have the fields
%		  "red", "blue", etc., each field being a boolean array denoting which
%		  of the array elements are in the color state represented by that
%		  field.  Except for the last branch of the tree struct, each struct
%		  must have the same tree structure.
%	<options>:
%		op:	('and') the operation to use to combine the states:
%				'and':	combine with &, forming a tree denoting which elements
%						are in all of the states at each tree node
%				'or':	combine with |, forming a tree denoting which elements
%						are in any of the states at each tree node
%				@f:		the handle to a function that compares two boolean
%						arrays and returns a boolean array the same size as each
%						of its inputs
% 
% Out:
% 	b	- the binary classifier tree.  each step of the tree contains a struct
%		  named "any" representing the ORing of each of the conditions at that
%		  step, so that, for example, if op=='and', ...any.any.red.any.any.any
%		  is a boolean array specifying which elements had the property "red".
% 
% Example:
% s1 = struct(...
% 		'firstset'	, struct('red',[1 0 0],'blue',[0 1 0],'green',[0 0 1])	, ...
% 		'secondset'	, struct('red',[0 0 1],'blue',[1 0 0],'green',[0 1 0])	  ...
% 		);
% s2 = struct(...
% 		'firstset'	, struct('rectangle',[1 1 0],'square',[1 0 0],'rhombus',[1 1 1])	, ...
% 		'secondset'	, struct('rectangle',[0 0 1],'square',[0 0 0],'rhombus',[1 0 1])	  ...
% 		);
% ct	= ClassifierTree(s1,s2,'op',@xor);
% 
% Updated: 2010-12-13
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get the start of the option specification
	kOpt	= find(~cellfun(@isstruct,varargin),1,'first');
	if isempty(kOpt)
		kOpt	= nargin+1;
	end
%parse the options
	opt	= ParseArgsOpt(varargin(kOpt:end),...
			'op'	, 'and'	  ...
			);
	switch class(opt.op)
		case 'char'
			switch opt.op
				case 'and'
					opt.op	= @and;
				case 'or'
					opt.op	= @or;
				otherwise
					error(['"' opt.op '" is not a recognized operation.']);
			end
		case 'function_handle'
		otherwise
			error(['"' class(opt.op) '" is not a valid class for the op option.']);
	end

%construct the tree
	b	= structtreefun(@(varargin) MakeTree(varargin{:}), varargin{1:kOpt-1},'offset',1);

%------------------------------------------------------------------------------%
function s = MakeTree(varargin)
	nBranch	= nargin;
	
	s		= varargin{end};
	s.any	= GetAny(s);
	for kB=nBranch-1:-1:1
		s	= AddBranch(s,varargin{kB});
	end
end
%------------------------------------------------------------------------------%
function sNew = AddBranch(sOld,b)
	cField	= fieldnames(b);
	if ~isempty(cField)
		b.any	= GetAny(b);
		sNew	= structfun2(@(x) structtreefun(@(y) opt.op(x,y),sOld), b);
	end
end
%------------------------------------------------------------------------------%
function b = GetAny(s)
	s		= struct2cell(s);
	[b,n]	= stack(s{:});
	b		= any(b,n);
end
%------------------------------------------------------------------------------%

end
