classdef blob < stimulus.image.base
% stimulus.image.blob
% 
% Description:	create a blobbish figure
% 
% Syntax: obj = stimulus.image.blob([param1,val1,...,paramN,valN])
% 
% Methods:
%	generate:	generate a stimulus
%	validate:	validate a set of parameter values
% 
% Properties:
%	param:	a property collection of parameters that the generator function will
%			use to generate the stimulus. includes:
%				n: (<from d>) the number of control points to use in
%					constructing the blob. more control points lead to a more
%					complex figure.
%				rmin: (0.1) the minimum control point radius, as a fraction of
%					the blob size
%				rmax: (1) the maximum control point radius, as a fraction of the
%					blob size
%				a: (<random (0 2*pi)>) an array specifying the angle, in
%					radians, of each control point. overrides <n>.
%				r: (<random (rmin rmax)>) an array specifying the radius of each
%					control point. overrides <rmin>, <rmax>, and <n>.
%				interp: ('pchip') the interpolation method, either 'pchip',
%					'linear', or 'spline' (which sucks)
%				interp_space: ('polar') the space in which interpolation takes
%					place, either 'polar' or 'cartesian'
%			<see also stimulus.image.base>
% 
% In:
%	[paramK]	- the Kth parameter whose value should be set explicitly
%	[valK]		- the explicit value of parameter paramK (or empty to skip
%				  skip setting the value)
% 
% Updated:	2015-11-17
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%METHODS------------------------------------------------------------------------
	%CONSTRUCTOR
		methods (Access=public)
			function obj = blob(varargin)
				obj = obj@stimulus.image.base();
				
				obj.difficulty_param		= 'n';
				obj.difficulty_param_min	= 3;
				obj.difficulty_param_max	= 50;
				obj.difficulty_param_round	= true;
				
				%set some parameter defaults
					add(obj.param,'n','generic',{@() obj.get_difficulty_param_value(obj.param.d)});
					add(obj.param,'rmin','generic',{0.1});
					add(obj.param,'rmax','generic',{1});
					add(obj.param,'a','range',{[0 2*pi],'size',@() [obj.param.n 1]});
					%add(obj.param,'r','range',{@() [obj.param.rmin obj.param.rmax],'size',@() [obj.param.n 1]});
					add(obj.param,'r','generic',{@() get_radii(obj)});
					add(obj.param,'interp','generic',{'pchip'});
					add(obj.param,'interp_space','generic',{'polar'});
				
				%parse the inputs
					obj.parseInputs(varargin{:});
			end
		end
	
	%PRIVATE
		methods (Access=protected)
			[mask,ifo] = generate_mask(obj,ifo)
			r = get_radii(obj)
		end
%/METHODS-----------------------------------------------------------------------

end
