function xn = AddNoise(x,varargin)
% AddNoise
% 
% Description:	add noise to an array
% 
% Syntax:	xn = AddNoise(x,<options>)
% 
% In:
% 	x			- an array
%	<options>:
%		'distribution':	('uniform') add noise from a 'uniform' or 'normal'
%						distribution
%		'strength':		(1) if uniform noise, the range of the noise as a
%						fraction of the range of the input data.  if normal, a
%						multiplier for the noise
%		'scale:			(false)	true or false to specify whether the noisy data
%						should be scaled to have the same min and max as the
%						input data
% 
% Out:
% 	xn	- x with noise added
% 
% Updated:	2010-12-09
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt	(varargin						, ...
						'distribution'	, 'uniform'	, ...
						'strength'		, 1			, ...
						'scale'			, false		  ...
					);

%get the noise
	s	= size(x);
	mn	= min(x(:));
	mx	= max(x(:));
	
	nMult	= opt.strength*(mx-mn);
	
	switch lower(opt.distribution)
		case 'uniform'
			xn	= nMult*(rand(s)-0.5);
		case 'normal'
			xn	= nMult*randn(s);
		otherwise
			error(['"' opt.distribution '" is not a valid distribution.']);
	end
%add to the input array
	xn	= x + xn;
%optionally scale the noise
	if opt.scale
		xn	= normalize(xn,'type','minmax','min',mn,'max',mx);
	end
	