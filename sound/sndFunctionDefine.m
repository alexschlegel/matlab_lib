function sF = sndFunctionDefine(n,f,varargin)
% sndFunctionDefine
% 
% Description:	define a function struct
% 
% Syntax:	sF = sndFunctionDefine(n,f,[p]=<all ones>,<options>)
% 
% In:
%	n	- the number of input arguments to the function being defined 
% 	f	- the handle to a function, or a cell of handles, that will compose the
%		  function being defined. if a cell is passed then a compound function
%		  is formed according to the options below. each function must require
%		  the the number of input arguments specified by n, plus an additional
%		  set of parameters unique to the function, and must return one output
%	[p]	- a cell array of initial parameter values for the function in f (or a
%		  cell of cells if f is a cell of functions}
%	<options>:
%		param_name:	(<from index>) a cell with the same structure as p defining
%					a name for each function's parameter
%		combine:	('add') one of the following to determine how compound
%							functions are combined:
%								'add': evaluate each function with the inputs and
%									add the results
%								'multiply':	evaluate each function with the
%									inputs and multiply the results
%								'compose':	compose the functions from left to
%									right.  the first function is evaluated with
%									all the inputs.  the rest are evaluated
%									either with the result of the previous
%									function, or the result of the previous
%									function followed by the 2nd-Nth original
%									inputs, depending on how many input arguments
%									each function defines
%		input_type:	('abs') one of the following to determine how the first
%							input argument should actually be passed to the
%							function(s).  can be a single value or a cell, one
%							for each function:
%								'abs':	pass the first input argument without
%										modification
%								'norm':	normalize the first input argument to
%										0->1 before passing it
% 
% Out:
% 	sF	- a function struct that can be passed to sndFunctionEval
% 
% Updated: 2010-11-24
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[p,opt]	= ParseArgs(varargin,{},...
			'param_name'	, {}	, ...
			'combine'		, 'add'	, ...
			'input_type'	, 'abs'	  ...
			);
if ~ismember(opt.combine,{'add','multiply','compose'})
	error(['"' tostring(opt.combine) '" is not a valid function combination method.']);
end

%fix sizes/cells
	[f,opt.input_type]						= varfun(@(x) reshape(ForceCell(x),[],1),f,opt.input_type);
	[p,opt.param_name]						= varfun(@(x) reshape(ForceCell(x,'level',2),[],1),p,opt.param_name);
	[f,opt.input_type,p,opt.param_name]	= FillSingletonArrays(f,opt.input_type,p,opt.param_name);
	nFunction								= numel(f);
%fill in unspecified parameters
	nInput	= cellfun(@GetNArgIn,f);
	
	for kF=1:nFunction
		if isempty(p{kF})
			p{kF}	= num2cell(ones(1,nInput(kF)-n));
		end
	end
%fill in unspecified parameter names
	for kF=1:nFunction
		if isempty(opt.param_name{kF})
			opt.param_name{kF}	= repmat({{}},size(p{kF}));
		end
		
		kEmpty						= find(cellfun(@isempty,opt.param_name{kF}));
		opt.param_name{kF}(kEmpty)	= num2cell(kEmpty);
	end
%make sure functions are defined well
	nSpecified	= n + cellfun(@numel,p);
	bMismatch	= nInput~=nSpecified;
	if any(bMismatch)
		error(join({'Mismatch between function input arguments and defined parameters for: ' tostring(f(bMismatch))},10));
	end

sF	= struct(...
		'n'				, n						, ...
		'f'				, {f}					, ...
		'p'				, {p}					, ...
		'p_name'		, {opt.param_name}		, ...
		'input_type'	, {opt.input_type}		, ...
		'combine'		, opt.combine			  ...
		);

%------------------------------------------------------------------------------%
function nIn = GetNArgIn(f)
	switch class(f)
		case 'struct'
			nIn	= f.n;
		case 'function_handle'
			nIn	= nargin(f);
		otherwise
			error(['Function "' tostring(f) '" is unrecognized.']);
	end
end
%------------------------------------------------------------------------------%

end