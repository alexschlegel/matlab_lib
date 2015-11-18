function x = get_coordinates(obj,xy)
% stimulus.image.scribble.get_coordinates
% 
% Description:	get control point coordinates
% 
% Syntax: x = obj.get_coordinates(xy)
% 
% In:
%	xy	- either 'x' or 'y' to specify the coordinates to get
%
% Out:
%	x	- the coordinates
% 
% Updated:	2015-11-17
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
coordType	= obj.validate_coordinate_type(obj.param.(sprintf('%s_type',xy)),xy);

switch class(coordType)
	case 'char'
		switch coordType
			case 'random'
				x	= 2*normalize(rand(obj.param.n,1))-1;
			case 'step'
				x		= NaN(obj.param.n,1);
				x(1)	= 2*rand-1;
				for k=2:n
					x(k)	= min(1,max(-1,x(1) + obj.param.step_size*(2*rand-1)));
				end
			case 'increase'
				x	= reshape(GetInterval(-1,1,obj.param.n),obj.param.n,1);
			case 'decrease'
				x	= reshape(GetInterval(1,-1,obj.param.n),obj.param.n,1);
		end
	case 'function_handle'
		x	= reshape(coordType(obj.param.n),[],1);
end
