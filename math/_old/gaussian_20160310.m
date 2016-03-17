function g = gaussian(s,varargin)
% gaussian
% 
% Description:	generates a normalized radial gaussian
% 
% Syntax:	g = gaussian(s,<options>)
%
% In:
%	s	- the dimensions of the matrix to return.  if s is scalar, creates a
%		  square matrix
%	<options>:
%		sigma	- (1) the standard deviation of the gaussian.  may be an array
%				  to specify different sigmas for each direction.
%		mu		- (0) an array specifying the peak offset
%		fwhm	- (<from sigma>) if specified, calculates sigma from the given
%				  fwhm
%		rpeak	- (0) the radius at which the gaussian should peak
%		rmethod	- ('cartesian') the method to calculate radii.  either
%				  'cartesian' or 'rectangular'
%		units	- ('absolute') either 'absolute' or 'fractional' to specify
%				  whether arguments are given as absolute values or as a
%				  fraction of s
% 
% Out:
%	g	- the gaussian matrix
%
% Last Updated: 2010-04-14
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs	(varargin						, ...
						'sigma'		, 1				, ...
						'mu'		, 0				, ...
						'fwhm'		, []			, ...
						'rpeak'		, 0				, ...
						'rmethod'	, 'cartesian'	, ...
						'units'		, 'absolute'	  ...
					);
if ~isempty(opt.fwhm)
	opt.sigma	= opt.fwhm./(2*sqrt(-log(0.5)));
end

%fix sizes
	if isscalar(s)
		s	= [s s];
	end	
	nd	= numel(s);
	
	[s,opt.sigma,opt.mu,opt.rpeak]	= FillSingletonArrays(s,opt.sigma,opt.mu,opt.rpeak);

%get the values in fractional units
	switch lower(opt.units)
		case 'absolute'
			opt.sigma	= opt.sigma ./ s;
			opt.mu		= 2*opt.mu ./ s;
			opt.rpeak	= 2*opt.rpeak ./ s;
		case 'fractional'
	end

%get the coordinates
	p	= Coordinates(s,'cartesian');

%get the fractional positions
	sR	= repmat(reshape(s,[ones(1,nd) nd]),[s 1]);
	muR	= repmat(reshape(opt.mu,[ones(1,nd) nd]),[s 1]);
	p	= 2*p./sR-muR;

%fractional radius
	r	= GetRadius(p,opt.rmethod);

%sigma at each point
	opt.sigma	= InterpolateByPosition(opt.sigma,p,r,opt.rmethod);
%rpeak at each point
	opt.rpeak	= InterpolateByPosition(opt.rpeak,p,r,opt.rmethod);

g	= exp( -((r-opt.rpeak)./opt.sigma).^2);
g	= g ./ sum(g(:));


%------------------------------------------------------------------------------%
function r = GetRadius(p,strMethod)
	switch lower(strMethod)
		case 'cartesian'
			r	= sqrt(sum(p.^2,ndims2(p)));
		case 'rectangular'
			r	= max(abs(p),[],ndims2(p));
	end
%------------------------------------------------------------------------------%
function x = InterpolateByPosition(x,p,r,strMethod)
	xOrig	= x;
	
	sz	= size(p);
	s	= sz(1:end-1);
	nd	= sz(end);
	switch lower(strMethod)
		case 'cartesian'
			x	= repmat(reshape(x,[ones(1,nd) nd]),[s 1]);
			r	= repmat(r,[ones(1,nd) nd]);
			x	= sum(p.^2.*x./r.^2,nd+1);
		case 'rectangular'
			[mx,kMax]	= max(abs(p),[],nd+1);
			x			= x(kMax);
	end
	
	x(isnan(x))	= mean(xOrig);
%------------------------------------------------------------------------------%
