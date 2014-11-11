function b = EqualEnough(x,y,varargin)
% EqualEnough
% 
% Description:	test if two arrays are equal within the specified tolerance
% 
% Syntax:	b = EqualEnough(x,y,<options>)
% 
% In:
% 	x	- an array
%	y	- another array the same size as x
%	<options>:
%		method:		('mean') one of the following values to specify the method
%					to use for testing equality of matrices.  can be a cell of
%					strings to require equality using multiple methods:
%						'corr':		the correlation coefficient between the
%									values of the two matrices must be >= the r
%									cutoff
%						'abscorr':	same as 'corr' but considers the absolute
%									value of the correlation coefficient
%						'mean':		the mean of the absolute values of the
%									differences between elements must be <= the
%									tolerance
%						'sum':		the sum of the absolute values of the
%									differences between elements must be <= the
%									tolerance
%						'normmean':	same as mean but with x and y normalized
%						'normsum':	same as sum but with x and y normalized
%		tol:		(<see below>) the tolerance for determining equality.  can
%					be a single value or a separate value for each method
%					specified.  NaNs are replace with default values.
%					tolerances for each method and their default values are
%					described below:
%						corr:		(0.8) the correlation coefficient between x
%									and y
%						abscorr:	(0.8) the absolute value of the correlation
%									coefficient between x and y
%						mean:		(max(eps(x),eps(y))) the mean of the absolute
%									difference between x and y
%						sum:		(max(eps(x),eps(y))) the sum of the absolute
%									differences between x and y
%						normmean:	(0.1) the mean absolute difference between
%									the normalized values of x and y
%						normsum:	(0.1) the sum of the absolute difference
%									between the normalized values of x and y
%		element:	(false) true to compare elements of x and y individually. if
%					this is true than the method option is ignored.
% 
% Out:
% 	b	- a logical array indicating which of the inputs are equal within the
%		  specified tolerance
% 
% Updated: 2010-09-10
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'method'	, 'mean'	, ...
		'tol'		, NaN		, ...
		'element'	, false		  ...
		);

[x,y]	= FillSingletonArrays(x,y);

tolDefault	= max(eps(x),eps(y));

if opt.element || numel(x)==1 || numel(y)==1
	if isnan(opt.tol)
		tol	= tolDefault;
	end
	
	b	= abs(x-y)<=opt.tol;
else
	xNorm	= [];
	yNorm	= [];
	
	opt.method				= ForceCell(opt.method);
	[opt.method,opt.tol]	= FillSingletonArrays(opt.method,opt.tol);
	opt.tol					= cellfun(@(t,m) EE_FillDefaultTolerance(t,m),num2cell(opt.tol),opt.method,'UniformOutput',false);
	nMethod					= numel(opt.method);
	
	b	= true;
	
	for kM=1:nMethod
		switch opt.method{kM}
			case 'corr'
				r	= corrcoef(x,y);
				b	= b && r(2)>=opt.tol{kM};
			case 'abscorr'
				r	= corrcoef(x,y);
				b	= b && abs(r(2))>=opt.tol{kM};
			case 'mean'
				b	= b && mean(abs(x(:)-y(:)))<=max(opt.tol{kM}(:));
			case 'sum'
				b	= b && sum(abs(x(:)-y(:)))<=max(opt.tol{kM}(:));
			case 'normmean'
				EE_normalize;
				b	= b && mean(abs(xNorm(:)-yNorm(:)))<=opt.tol{kM};
			case 'normsum'
				EE_normalize;
				b	= b && mean(abs(xNorm(:)-yNorm(:)))<=opt.tol{kM};
			otherwise
				error(['"' tostring(opt.method{kM}) '" is not a recognized comparison method.']);
		end
	end
end

%------------------------------------------------------------------------------%
function t = EE_FillDefaultTolerance(t,m)
	if isnan(t)
		switch m
			case 'corr'
				t	= 0.8;
			case 'abscorr'
				t	= 0.8;
			case 'mean'
				t	= tolDefault;
			case 'sum'
				t	= tolDefault;
			case 'normmean'
				t	= 0.1;
			case 'normsum'
				t	= 0.1;
			otherwise
				error(['"' tostring(opt.method{kM}) '" is not a recognized comparison method.']);
		end
	end
end
%------------------------------------------------------------------------------%
function EE_normalize()
	if isempty(xNorm)
		xNorm	= normalize(x);
		yNorm	= normalize(y);
	end
end
%------------------------------------------------------------------------------%
end