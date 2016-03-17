function y = gaussian(x,varargin)
% gaussian
% 
% Description:	multivariate gaussian distribution of the form:
%					f(x) = C * exp(-1/2*(x-mu)'*inv(S)*(x-mu))
%						where 	C  = (1/(2*pi)^(n/2)*sqrt(|S|))
%								n  = the dimensionality of x
%								S  = a covariance matrix
%								mu = the mean of the distribution.
%				note that for 1D input, this simplifies to:
%					f(x) = (1/sqrt(2*pi*S))*exp(-(x-mu)/(2*S)).
%				
%				NOTE also that for 1D S is the variance, not the standard
%				deviation.
% 
% Syntax:	y = gaussian(x,[mu]=<0>,[S]=<1>)
%
% In:
%	x		- an s1 x s2 x ... x sM x N matrix of N-dimensional input values
%	[mu]	- the distribution mean value
%	[S]		- the variance / covariance matrix
% 
% Updated:	2016-03-11
% Copyright 2016 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	%calculate some dimensions
		sz	= size(x);
		N	= sz(end);
		sz	= sz(1:end-1);
		M	= prod(sz);
		
		if numel(sz)==1
			sz	= [sz 1];
		end
	
	%get the input values
		varargin(numel(varargin)+1:2)	= {[]};
		[mu,S]							= deal(varargin{1:2});
	%assign defaults to empty inputs
		if isempty(mu)
			mu	= zeros(N,1);
		end
		if isempty(S)
			S	= eye(N);
		end
	
	%reshape x to be N x M for convenience
		x	= reshape(x,[M N])';
	%reshape other stuff
		mu	= reshape(mu,[N 1]);

%calculate the gaussian
	%calculate (x-mu)' * inv(S) * (x-mu) for each x
		x0	= x - repmat(mu,[1 M]);
		A	= sum(x0.*(inv(S)*x0),1);

	C	= 1/((2*pi)^(N/2)*sqrt(det(S)));
	y	= C * exp(-A/2);

%reshape to the output size
	y	= reshape(y,sz);
