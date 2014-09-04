function bvqx = BVQXObject(varargin)
% BVQXObject
% 
% Description:	create a BVQX COM object (Windows only)
% 
% Syntax:	bvqx = BVQXObject(<options>)
%
% Notes: get a list of methods available to the COM object by typing:
%			bvqx.invoke (see actxserver help)
% 
% Out:
% 	bvqx	- the BVQX COM object
%	<options>:
%		'visible':	(false) true to show the BVQX window, false otherwise
% 
% Updated:	2009-07-10
% Copyright 2009 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'visible'	, false	  ...
		);

%make sure we're in Windows
	if ~ispc
		error('This function requires Windows.');
	end

%start BVQX
	bvqx 			= actxserver('BrainVoyagerQX.BrainVoyagerQXInterface.1');
	bvqx.visible	= opt.visible;
%BVQX seems to crash if you don't give it enough time to load
	pause(2);
	