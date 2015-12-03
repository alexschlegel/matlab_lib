function param = validate(obj,param)
% stimulus.image.scribble.validate
% 
% Description:	validate a set of parameter values for scribble stimuli
% 
% Syntax: param = obj.validate(param)
% 
% In:
%	param	- a struct of parameter values
%
% Out:
%	param	- the validated parameter struct
% 
% Updated:	2015-11-17
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%validate superclass stuff
	param	= validate@stimulus.image.base(obj,param);

%number of control points
	assert(isscalar(param.n),'n must be scalar');
	assert(param.n>=3,'n must be at least 3');

%x and y type (a little redundant since x and y are filled before this)
	param.x_type	= obj.validate_coordinate_type(param.x_type,'x');
	param.y_type	= obj.validate_coordinate_type(param.y_type,'y');

%step size
	param.step_size	= obj.validate_step_size(param.step_size);

%x and y values
	assert(numel(param.x)==numel(param.y),'x and y must have the same number of elements');
	assert(numel(param.x)>=3,'at least three control points must be defined');
	
	param.x	= reshape(param.x,[],1);
	param.y	= reshape(param.y,[],1);
	
	assert(all(param.x>=-1 & param.x<=1),'x values must be between -1 and 1');
	assert(all(param.y>=-1 & param.y<=1),'y values must be between -1 and 1');

%calligraphy angle
	assert(isscalar(param.calligraphy_angle),'calligraphy_angle must be a scalar');

%pen
	assert(isscalar(param.pen_size),'pen_size must be scalar');
	
	param.pen_size_px	= round(param.pen_size*param.size);
	
	switch class(param.pen)
		case 'char'
			param.pen	= CheckInput(param.pen,'pen',{'calligraphy','round','random'});
			
			switch param.pen
				case 'calligraphy'
					param.pen	= imrotate(true(param.pen_size_px,2),-param.calligraphy_angle);
				case 'round'
					param.pen	= MaskCircle(param.pen_size_px);
				case 'random'
					param.pen	= @(t,T) rand(param.pen_size_px)>=0.99;
			end
		case 'logical'
			assert(numel(size(param.pen))==2,'logical pens must be 2D');
		case 'function_handle'
			n	= nargin(param.pen);
			assert(n==2 || n==-3,'pen functions must take 2 required arguments');
		otherwise
			error('pen cannot be of class %s',class(param.pen));
	end
	
