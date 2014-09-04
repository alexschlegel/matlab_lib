function a = colon(varargin)
% colon
% 
% Description:	colon for StringMath objects
% 
% Syntax:	a = colon(j,k) OR
%			a = colon(j,d,k) OR
%			j:k / j:d:k
% 
% Updated:	2009-05-30
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%parse the input
	switch nargin
		case 2
			[j,k]	= deal(varargin{:});
			d		= 1;
		case 3
			[j,d,k]	= deal(varargin{:});
		otherwise
			error('Incorrect number of input arguments');
	end

%only consider the first element (weird, but this is what MATLAB does)
	if isempty(j) || isempty(d) || isempty(k)
		a	= [];
		return;
	else
		j	= j(1);
		d	= d(1);
		k	= k(1);
	end
	
%fix the input
	[j,d,k,bEmptyInput]	= p_FixInputNoResize(j,d,k);
	
%colon!
	kSM	= 0;
	a	= p_TransferProperties(j,StringMath);
	
	kStep	= j;
	while kStep<=k
		kSM	= kSM + 1;
		
		a(kSM)	= kStep;
		kStep	= kStep + d;
	end
	