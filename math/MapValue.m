function x = MapValue(x,minFrom,maxFrom,minTo,maxTo,varargin)
% MapValue
% 
% Description:	map a value from one domain to another
% 
% Syntax:	x = MapValue(x,minFrom,maxFrom,minTo,maxTo,<options>)
% 
% In:
% 	x		- the values to map
% 	minFrom	- the minimum of the source domain
%	maxFrom	- the maximum of the source domain
%	minTo	- the minimum of the destination domain
%	maxTo	- the maximum of the destination domain
%	<options>:
%		constrain:		(true) true to constrain the input values to the input
%						domain
%		map_function:	('linear') a function from (0->1) to (0->1).  can be one
%						the following strings:
%							'linear':	@(x) x
%							'sigmoid':	@(x) normalize(1./(1+exp(12*(-x+0.5))))
% 
% Out:
% 	x	- the mapped values
% 
% Updated: 2010-05-11
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'constrain'		, true		, ...
		'map_function'	, 'linear'	  ...
		);
if ischar(opt.map_function)
	switch opt.map_function
		case 'linear'
			fMap	= @(x) x;
		case 'sigmoid'
			fMap	= @(x) normalize(1./(1+exp(12*(-x+0.5))));
		otherwise
			error(['"' opt.map_function '" is not a valid builtin map function.']);
	end
else
	fMap	= opt.map_function;
end

%expand non-full inputs
	[x,minFrom,maxFrom,minTo,maxTo]	= FillAllButSingletonArrays(x,minFrom,maxFrom,minTo,maxTo);
%transform to 0->1
	warning('off','MATLAB:divideByZero');
	bNaNPre	= isnan(x);
	x		= (x-minFrom)./(maxFrom-minFrom);
	
	x(isnan(x) & ~bNaNPre)	= 0.5;
%apply the map function
	x	= fMap(x);
%constrain
	if opt.constrain
		x	= constrain(x,0,1);
	end
%transform from 0>1
	x	= minTo + x.*(maxTo-minTo);
