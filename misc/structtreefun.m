function varargout = structtreefun(f,varargin)
% structtreefun
% 
% Description:	evaluate a function for each member of a uniform struct tree
% 
% Syntax:	[so1,...,soM] = structtreefun(f,si1,...,siN,<options>)
% 
% In:
% 	f	- the handle to a function that takes N inputs and returns M outputs
%	siK	- the Kth input struct tree (e.g. a.b.c...)
%	<options>:
%		offset:	(0) evaluate the function on the structs this number of
%				branches from the nearest end of the struct tree
% 
% Out:
% 	siK	- the Kth output struct tree
% 
% Updated: 2015-03-22
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	if isa(f,'function_handle')
		kSplit	= unless(find(~cellfun(@isstruct,varargin),1,'first'),numel(varargin)+1);
		cS		= varargin(1:kSplit-1);
		
		opt	= ParseArgs(varargin(kSplit:end),...
				'offset'	, 0		  ...
				);
		
		opt.f	= f;
		
		opt.length	= cellfun(@structtreelength,cS,'uni',false);
	elseif isoptstruct(f)
		opt	= f;
		cS	= varargin;
	else
		error('first input argument must be the handle to a function');
	end
	
	nOut	= max(nargout,nargout(opt.f));

level	= min(cellfun(@(x) x.length,opt.length));
if level<=opt.offset
	[varargout{1:nOut}]	= opt.f(cS{:});
else
	[varargout{1:nOut}]	= deal(struct);
	
	cField	= fieldnames(cS{1});
	nField	= numel(cField);
	
	for kF=1:nField
		strField	= cField{kF};
		
		optCur			= opt;
		optCur.length	= cellfun(@(s) s.tree.(strField),opt.length,'uni',false);
		
		outCur				= cell(nOut,1);
		cSCur				= cellfun(@(x) x.(strField),cS,'uni',false);
		[outCur{1:nOut}]	= structtreefun(optCur,cSCur{:});
		
		for kO=1:nOut
			varargout{kO}.(strField)	= outCur{kO};
		end
	end
end
