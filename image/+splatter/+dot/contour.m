function [b,alpha] = contour(varargin)
% splatter.dot.contour
% 
% Description:	generate a splatter dot contour
% 
% Syntax:	[b,alpha] = splatter.dot.contour(<options>)
%
% In:
%	<options>:
%		preset:			(<none>) a preset set of options to use. one of the
%						following:
%							paint: paint-like splotches
%		radius:			(50) the radius of the splatter dot, in pixels. for
%						eccentricity>0, this is the minimum of the two radii.
%		orientation:	(0) the orientation of the dot, in radians (0==right
%						facing horizontal)
%		speed:			(0) simulate a moving splatter.  the fractional speed.
%						just sets the eccentricities.
%		eccentricity:	(0) the fractional eccentricity of the dot
%		eccentricity2:	(<eccentricity>) the backward facing eccentricity of the
%						dot
%		jitter_n:		(0) the number of amplitude jitters
%		jitter_m:		(0) the fractional jitter amplitude
%
% Out:
%	b		- the logical contour image
%	alpha	- the alpha map for the contour image
% 
% Examples:
%	imshow(splatter.dot.contour('radius',50,'eccentricity',0.75,'jitter_n',4,'jitter_m',0.4));
%	imshow(splatter.dot.contour('radius',50,'eccentricity',0.9,'eccentricity2',0.2,'orientation',pi/4,'jitter_n',[4,40,400],'jitter_m',[0.8,0.1,0.01]));
%	imshow(splatter.dot.contour('radius',50,'eccentricity',0.9,'eccentricity2',0.2,'orientation',pi/4,'jitter_n',[4,20,200],'jitter_m',[0.8,0.1,0.01]));
%
% Updated: 2013-05-19
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent presets

if isempty(presets)
	presets.default	= struct(...
						'radius'		, 50	, ...
						'orientation'	, 0		, ...
						'speed'			, 0		, ...
						'eccentricity'	, []	, ...
						'eccentricity2'	, []	, ...
						'jitter_n'		, 0		, ...
						'jitter_m'		, 0		  ...
						);
	presets.paint	= StructMerge(presets.default,struct(...
						'jitter_n'	, [10,20,200]		, ...
						'jitter_m'	, [0.3,0.1,0.01]	  ...
						));
end

opt	= ParseArgs(varargin,'preset',[]);
if ~isempty(opt.preset)
	sPreset	= presets.(opt.preset);
else
	sPreset	= struct;
end

opt	= StructMerge(sPreset,ParseArgs(varargin,...
		'radius'		, []	, ...
		'orientation'	, []	, ...
		'speed'			, []	, ...
		'eccentricity'	, []	, ...
		'eccentricity2'	, []	, ...
		'jitter_n'		, []	, ...
		'jitter_m'		, []	  ...
		));

%set the speed
if isempty(opt.eccentricity2)
	if isempty(opt.eccentricity)
		opt.eccentricity	= opt.speed;
		opt.eccentricity2	= opt.eccentricity/5;
	else
		opt.eccentricity2	= opt.eccentricity;
	end
elseif isempty(opt.eccentricity1)
	opt.eccentricity	= opt.eccentricity2;
end

n	= 1000;

%angle parameter
	a	= GetInterval(0,2*pi,n)';
%ellipse radii
	r2	= opt.radius;
	r1f	= r2./sqrt(1-opt.eccentricity.^2);
	r1b	= r2./sqrt(1-opt.eccentricity2.^2);
	
	r1	= conditional(cos(a)>0,r1f,r1b);
%generate the unperturbed radii
	r	= r1.*r2./sqrt((r2.*cos(a)).^2 + (r1.*sin(a)).^2);
%jitter the radii
	[opt.jitter_n,opt.jitter_m]	= FillSingletonArrays(opt.jitter_n,opt.jitter_m);
	nJitter						= numel(opt.jitter_n);
	
	for kJ=1:nJitter;
		kJitterCP	= round(GetInterval(1,n,opt.jitter_n(kJ)+2));
		kJitterCP	= kJitterCP(1:end-1);
		
		aJitterCP	= a(kJitterCP);
		mJitterCP	= [0; randnbound(opt.jitter_n(kJ),r(kJitterCP(2:end))*opt.jitter_m(kJ))];
		
		aJitterCP	= [aJitterCP-2*pi; aJitterCP; aJitterCP+2*pi];
		mJitterCP	= repmat(mJitterCP,[3 1]);
		
		r		= r + interp1(aJitterCP,mJitterCP,a,'pchip');
	end
%construct the position of each point
	p	= PointConvert([r opt.orientation-a],'polar','cartesian');
	y	= p(:,2) - min(p(:,2)) + 1;
	x	= p(:,1) - min(p(:,1)) + 1;
	
	b	= contour2im(y,x);
%make sure we have a good border
	[b,alpha]	= deal(imPad(b,false,size(b,1)+2,size(b,2)+2));
