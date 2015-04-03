function s = StructMerge(varargin)
% StructMerge
% 
% Description:	merge multiple structs into one
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
% Updated: 2015-03-22
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	kSplit	= find(~cellfun(@isstruct,varargin),1,'first');
	
	cS	= varargin(1:kSplit-1);
	opt	= ParseArgs(varargin(kSplit:end),...
			'method'		, 'last'	, ...
			'include_empty'	, false		, ...
			'unique'		, false		  ...
			);
	
	opt.method	= CheckInput(opt.method,'merging method',{'last','first','append'});

switch lower(opt.method)
	case 'last'
		s	= structtreefun(@(varargin) GetLastElement(varargin),cS{:},'omit',true);
	case 'first'
		s	= structtreefun(@(varargin) GetFirstElement(varargin),cS{:},'omit',true);
	case 'append'
		s	= structtreefun(@(varargin) AppendElements(varargin),cS{:},'omit',true);
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
