function x = sndFunctionEval(sF,varargin)
% sndFunctionEval
% 
% Description:	evaluate a function defined with sndFunctionDefine
% 
% Syntax:	x = sndFunctionEval(sF,<inputs>)
% 
% In:
% 	sF			- the function struct returned by sndFunctionDefine
%	<inputs>	- the inputs to the function
% 
% Out:
% 	x	- the result of the function call
% 
% Updated: 2010-11-24
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

switch sF.combine
	case 'add'
		x		= EvalOne(sF.f,sF.p,sF.input_type,varargin{:});
		[x,n]	= stack(x{:});
		x		= sum(x,n);
	case 'multiply'
		x		= EvalOne(sF.f,sF.p,sF.input_type,varargin{:});
		[x,n]	= stack(x{:});
		x		= prod(x,n);
	case 'compose'
		nFunc	= numel(sF.f);
		if nFunc>0
			x	= EvalOne(sF.f{1},sF.p{1},sF.input_type{1},varargin{:});
			for kF=2:nFunc
				x	= EvalOne(sF.f{kF},sF.p{kF},sF.input_type{kF},x,varargin{2:end});
			end
		else
			x	= [];
		end
end

%------------------------------------------------------------------------------%
function x = EvalOne(f,p,strInputType,varargin)
	if iscell(f)
		x	= cell(size(f));
		
		%evaluate for abs types
			bAbs	= ismember(strInputType,'abs');
			xAbs	= varargin{1};
			if any(bAbs)
				x(bAbs)	= cellfun(@(f,p) EvalFunction(f,xAbs,varargin{2:end},p{:}),f(bAbs),p(bAbs),'UniformOutput',false);
			end
		%evaluate for norm types
			bNorm	= ~bAbs;
			if any(bNorm)
				xNorm		= normalize(xAbs);
				x(bNorm)	= cellfun(@(f,p) EvalFunction(f,xNorm,varargin{2:end},p{:}),f(bNorm),p(bNorm),'UniformOutput',false);
			end
	else
		switch strInputType
			case 'abs'
				x	= varargin{1};
			case 'norm'
				x	= normalize(varargin{1});
		end
		
		x	= EvalFunction(f,x,varargin{2:end},p{:});
	end
end
%------------------------------------------------------------------------------%
function x = EvalFunction(f,varargin)
	switch class(f)
		case 'struct'
			x	= sndFuncEval(f,varargin{:});
		case 'function_handle'
			x	= f(varargin{:});
		otherwise
			error(['Function "' tostring(f) '" is unrecognized.']);
	end
end
%------------------------------------------------------------------------------%


end