function y = fevalWarp(f,x,r)
% fevalWarp
% 
% Description:	scan through a 1D function at a warped rate
% 
% Syntax:	y = fevalWarp(f,x,r)
% 
% In:
% 	f	- the handle to a 1D function
%	x	- an 1D increasing array of values at which the function should be
%		  evaluated
%	r	- a scalar or an array the same size as x specifying the warped rate of
%		  the function at each evaluation
% 
% Out:
% 	y	- the warped output from the function
% 
% Updated: 2011-11-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if isempty(x)
	y	= [];
	return;
end

%get the new x-values
	s	= size(x);
	x	= reshape(x,[],1);
	r	= reshape(r,[],1);
	x	= x(1) + [0; cumsum(diff(x).*r(1:end-1))];
%evaluate
	y	= f(x);
	