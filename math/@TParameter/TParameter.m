function tP = TParameter(varargin)
% TParameter
%
% Description:	the TParameter constructor function.  a TParameter object
%				stores a mapping from [0,1]->[0,1]
%
% Syntax:	tP = TParameter(n)   OR
%			tP = TParameter(f,n) OR
%			tP = TParameter(f,t) OR
%			tP = TParameter(t)
%			
%			x = tP.<n,f,t>:	get the specified parameter
%			tP.<n,f,t> = x:	set the specified parameter.  setting n or f
%							overwrites t and setting t overwrites n and f
%
% In:
%	n	- the number of elements in the mapping
%	f	- a cfit object specifying the mapping (if unspecified, assumes a linear
%		  mapping)
%	t	- an explicit definition of the mapping range if passed alone, or domain
%		  if passed with f
%
% Out:
%	tP	- the TParameter object
%
% Updated:	2010-06-08
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%parse the input
	[v1,v2]	= ParseArgs(varargin,0,[]);
	
	if isnumeric(v1)
		if numel(v1)==1 && (v1==0 || v1>=1)	%passed n
			n	= v1;
			f	= [];
			t	= [];
		else	%t passed
			t	= v1;
			n	= numel(v1);
			f	= [];
		end
	else
		switch class(v1)
			case 'cfit'
				f	= v1;
				
				if numel(v2)==1 && (v2==0 || v2>=1)	%passed n
					n	= v2;
					t	= [];
				else	%passed t
					tIn	= v2;
					n	= numel(v2);
					t	= f(tIn);
				end
			otherwise
				error('Unrecognized input.');
		end
	end

%initialize the instance
	tP.n	= n;
	tP.f	= f;
	tP.t	= t;
	
	tP		= class(tP,'TParameter');
	