classdef shepard < stimulus.image.base
% stimulus.image.mentalrotation.shepard
% 
% Description:	create a figure used in Shepard & Metzler's mental rotation
%				study
% 
% Syntax: obj = stimulus.image.mentalrotation.shepard([param1,val1,...,paramN,valN])
% 
% Methods:
%	generate:	generate a stimulus
%	validate:	validate a set of parameter values
% 
% Properties:
%	param:	a property collection of parameters that the generator function will
%			use to generate the stimulus. includes:
%				figure: (<random>) the figure index (1-8)
%				tx: ('') a string specifying the transformations to perform on
%					the figure. takes the form
%					'<x1>[<n1>] <x2>[<n2>] ... <xN>[<nN>]', where <xK> is the
%					operation and possible <nK> is the parameter for the
%					operation. possible operations are:
%						RX:	rotate around x-axis nK degrees
%						RY:	rotate around y-axis nK degrees
%						RZ:	rotate around z-axis nK degrees
%						RB:	"back" rotate nK degrees
%						RF:	"forward" rotate nK degrees
%						RL:	"left" rotate nK degrees
%						RR:	"right" rotate nK degrees
%						FX:	flip along x-axis (no parameter)
%						FY:	flip along y-axis (no parameter)
%						FZ:	flip along z-axis (no parameter)
%					e.g. 'RX-90 RF45.5 FX' rotate -90 degrees around the x-axis,
%					then rotate forward 45.5 degrees, then flip along the
%					x-axis.
%				view: ([-60 15 0]) the rotation to introduce around each axis
%					for the viewpoint, in degrees
%				axis_radius: (3.5) the axis radius from the origin to include in
%					the viewport
%				edge: ([0 0 0]) the edge color
%				thickness: (0.5) the line thickness (maybe in points? not sure)
%			<see also stimulus.image.base>
% 
% In:
%	[paramK]	- the Kth parameter whose value should be set explicitly
%	[valK]		- the explicit value of parameter paramK (or empty to skip
%				  skip setting the value)
% 
% Updated:	2015-10-06
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%PROPERTIES---------------------------------------------------------------------
	%CONSTANT
		properties (Constant, GetAccess=protected)
			N_FIGURE	= 8;
		end
	
	%PRIVATE
		properties (SetAccess=protected, GetAccess=protected)
			stim_param;
		end
%/PROPERTIES--------------------------------------------------------------------

%METHODS------------------------------------------------------------------------
	%CONSTRUCTOR
		methods (Access=public)
			function obj = shepard(varargin)
				obj = obj@stimulus.image.base();
				
				%set some parameter defaults
					add(obj.param,'figure','list',{1:obj.N_FIGURE});
					add(obj.param,'tx','generic',{''});
					add(obj.param,'view','generic',{[-60 15 0]});
					add(obj.param,'axis_radius','generic',{3.5});
					add(obj.param,'edge','generic',{[0 0 0]});
					add(obj.param,'thickness','generic',{0.5});
				
				%parse the inputs
					obj.parseInputs(varargin{:});
				
				%get the stimulus parameters
					obj.stim_param	= obj.get_stimulus_parameters;
			end
		end
	
	%PRIVATE
		methods (Access=protected)
			[stim,ifo] = generate_inner(obj,ifo)
			param = get_stimulus_parameters(obj)
		end
%/METHODS-----------------------------------------------------------------------

end
