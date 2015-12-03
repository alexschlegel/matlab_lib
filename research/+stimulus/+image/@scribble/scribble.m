classdef scribble < stimulus.image.base
% stimulus.image.scribble
% 
% Description:	create a scribble figure
% 
% Syntax: obj = stimulus.image.scribble([param1,val1,...,paramN,valN])
% 
% Methods:
%	generate:	generate a stimulus
%	distractor:	generate a distractor stimulus
%	validate:	validate a set of parameter values
% 
% Properties:
%	param:	a property collection of parameters that the generator function will
%			use to generate the stimulus. includes:
%				n: (<from d>) the number of control points to use in
%					constructing the scribble. more control points lead to a
%					more complex figure. must be at least 3.
%				x_type:	('random') a method for choosing x values. one of the
%					following:
%						'random':	randomly choose each value (from a uniform
%							distribution)
%						'step:	randomly choose the first value, then choose a
%							random step for each additional value
%						'increase':	uniform increasing steps
%						'decrease':	uniform decreasing steps
%						f:	the handle to a function that takes the desired
%							number of control points as inputs and returns the
%							control points' x values
%				y_type:	('random') same as <x_type>, but for y values
%				x:	(<from x_type>) an array of control point x values between
%					-1 and 1. overrides <x_type>.
%				y:	(<from y_type>) an array of control point y values between
%					-1 and 1. overrides <y_type>.
%				pen_size:	(0.0625) the size of the pen to apply, as a fraction
%							of the stimulus size
%				pen:	('calligraphy') the type of pen to use. one of the
%					following:
%						'calligraphy':	use a line as a pen to mimic the effect
%							of calligraphy
%						'round':	a circular pen
%						'random':	a random configuration of dots at each point
%							in the scribble
%						b:	a binary 2D array to use as the pen
%						f:	a function that takes the current scribble position
%							and the total scribble length (in pixels) and
%							returns the pen for the current point
%				step_size:	(0.1) for 'step' type coordinate values, the maximum
%					step size
%				calligraphy_angle:	(0) for calligraphy pens, the clockwise
%					rotation of the pen from vertical, in degrees
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
			function obj = scribble(varargin)
				obj = obj@stimulus.image.base();
				
				obj.difficulty_param		= 'n';
				obj.difficulty_param_min	= 3;
				obj.difficulty_param_max	= 50;
				obj.difficulty_param_round	= true;
				
				%set some parameter defaults
					add(obj.param,'n','generic',{@() obj.get_difficulty_param_value(obj.param.d)});
					add(obj.param,'x_type','generic',{'random'});
					add(obj.param,'y_type','generic',{'random'});
					add(obj.param,'x','generic',{@() get_coordinates(obj,'x')});
					add(obj.param,'y','generic',{@() get_coordinates(obj,'y')});
					add(obj.param,'pen_size','generic',{0.0625});
					add(obj.param,'pen','generic',{'calligraphy'});
					add(obj.param,'step_size','generic',{0.1});
					add(obj.param,'calligraphy_angle','generic',{0});
				
				%parse the inputs
					obj.parseInputs(varargin{:});
			end
		end
	
	%PRIVATE
		methods (Access=protected)
			[mask,ifo] = generate_mask(obj,ifo)
			x = validate_coordinate_type(obj,x,xy)
			step_size = validate_step_size(obj,step_size)
		end
%/METHODS-----------------------------------------------------------------------

end
