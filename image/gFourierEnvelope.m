function g = gFourierEnvelope(g,varargin)
% gFourierEnvelope
% 
% Description:	applies an envelope to the fourier transform of a grayscale
%				image
% 
% Syntax:	g = gFourierEnvelope(g,[strType]='cutoff',<options>)
%
% In:
%	g			- an grayscale image
%	[strType]	- the type of envelope to apply.  can be one of the following:
%					'gaussian':				radial gaussian
%					'gaussian_inv':			inverse radial gaussian
%					'gaussian_rect':		rectangular gaussian
%					'gaussian_rect_inv':	inverse rectangular gaussian
%					'cutoff':				cutoff values greater than the
%											specified radius
%					'cutoff_inv':			cutoff values less than the
%											specified radius
%	<options>:
%		'sigma'		- (1) if the envelope type involves a gaussian, the gaussian
%					  sigma
%		'radius'	- (0) for gaussians, the radius at which the gaussian peaks
%					  (or troughs).  for cutoff, the cutoff radius
%		'units'		- ('absolute') either 'absolute' or 'fractional' to specify
%					  whether arguments are given as absolute values or as a
%					  fraction of s
%
% Out:
%	g	- the image with the envelope applied to the fourier transform
% 
% Note: all gaussians are normalized from 0 to 1
% 
% Updated:	2009-04-02
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[strType,opt]	= ParseArgs	(varargin,'cutoff'				, ...
									'sigma'		, 1				, ...
									'radius'	, 0				, ...
									'units'		, 'absolute'	  ...
								);

s	= size(g);

if isequal(opt.units,'absolute')
	rAbs	= opt.radius;
	rRel	= opt.radius./s;
else
	rAbs	= opt.radius.*s;
	rRel	= opt.radius;
end

if numel(rAbs)==1
	rAbs	= [rAbs rAbs];
end
if numel(rRel)==1
	rRel	= [rRel rRel];
end

%construct the envelope
	switch lower(strType)
		case 'cutoff'
			env	= InsertImage(zeros(s),MaskCircle(rAbs(1),rAbs(2)),[0 0],'center');
		case 'cutoff_inv'
			env	= 1 - InsertImage(zeros(s),MaskCircle(rAbs(1),rAbs(2)),[0 0],'center');
		case 'gaussian'
			env	= normalize(gaussian(s,'sigma',opt.sigma,'mu',0,'rpeak',opt.radius,'rmethod','cartesian','units',opt.units));
		case 'gaussian_inv'
			env	= 1 - normalize(gaussian(s,'sigma',opt.sigma,'mu',0,'rpeak',opt.radius,'rmethod','cartesian','units',opt.units));
		case 'gaussian_rect'
			env	= normalize(gaussian(s,'sigma',opt.sigma,'mu',0,'rpeak',opt.radius,'rmethod','rectangular','units',opt.units));
		case 'gaussian_rect_inv'
			env	= 1 - normalize(gaussian(s,'sigma',opt.sigma,'mu',0,'rpeak',opt.radius,'rmethod','rectangular','units',opt.units));
		otherwise
			error(['"' strType '" is not a recognized envelope type.']);			
	end

f	= fft2(g);
f	= fftshift(f);

f	= f .* env;

f	= ifftshift(f);
g	= real(ifft2(f));
