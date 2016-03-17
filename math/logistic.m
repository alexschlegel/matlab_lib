function y = logistic(x,varargin)
% logistic
% 
% Description:	logistic function of the form:
%                   f(x) = L/(1 + exp(-k*(x-x0)))
% 
% Syntax: y = logistic(x,[L]=1,[k]=1,[x0]=0)
% 
% Updated:	2016-03-10
% Copyright 2016 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	%get the input values
		varargin(numel(varargin)+1:3)	= {[]};
		[L,k,x0]	            		= deal(varargin{1:3});
	%assign defaults to empty inputs
		if isempty(L)
			L	= 1;
		end
		if isempty(k)
			k   = 1;
		end
		if isempty(x0)
			x0	= 0;
		end

y   = L./(1+exp(-k.*(x-x0)));
