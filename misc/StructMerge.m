function s = StructMerge(varargin)
% StructMerge
% 
% Description:	merge two or more structs into one, keeping the fields from
%				later structs in the case of duplicates
% 
% Syntax:	s = StructMerge(s1,...,sN,<options>)
% 
% In:
% 	sK	- the Kth struct to merge
%	<options>:
%		method:			('last') the method to use to merge existing struct
%						elements:
%						'last':		keep the last entry
%						'first':	keep the first entry
%						'append':	append all entries
%		include_empty:	(true) true to skip empty elements
%		unique:			(false) true to only keep unique values for each merge
%						operation
% 
% Out:
% 	s	- the merged struct
% 
% Updated: 2011-12-07
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
kSplit	= find(cellfun(@(x) ~isa(x,'struct'),varargin),1,'first');

cS	= varargin(1:kSplit-1);
opt	= ParseArgs(varargin,...
		'method'		, 'last'	, ...
		'include_empty'	, false		, ...
		'unique'		, false		  ...
		);

switch lower(opt.method)
	case 'last'
		s	= structtreefun(@(varargin) GetLastElement(varargin),varargin{:},'omit',true);
	case 'first'
		s	= structtreefun(@(varargin) GetFirstElement(varargin),varargin{:},'omit',true);
	case 'append'
		s	= structtreefun(@(varargin) AppendElements(varargin),varargin{:},'omit',true);
	otherwise
		error(['"' tostring(opt.method) '" is not a valid merging method.']);
end

%------------------------------------------------------------------------------%
function v = GetLastElement(c) 
	if numel(c)>0
		if opt.include_empty
			v	= c{end};
		else
			kKeep	= unless(find(cellfun(@(x) ~isempty(x),c),1,'last'),numel(c));
			v		= c{kKeep};
		end
	else
		v	= [];
	end
end
%------------------------------------------------------------------------------%
function v = GetFirstElement(c) 
	if numel(c)>0
		if opt.include_empty
			v	= c{1};
		else
			kKeep	= unless(find(cellfun(@(x) ~isempty(x),c),1,'first'),1);
			v		= c{kKeep};
		end
	else
		v	= [];
	end
end
%------------------------------------------------------------------------------%
function v = AppendElements(c) 
	if numel(c)>0
		v	= append(c{:});
		if opt.unique
			v	= unique(v);
		end
	else
		v	= [];
	end
end
%------------------------------------------------------------------------------%

end
