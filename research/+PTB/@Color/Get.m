function x = Get(col,strName,varargin)
% PTB.Color.Get
% 
% Description:	get the [r g b a] value of a color
% 
% Syntax:	col = col.Get(strName,[alpha]=<default>)
% 
% In:
% 	strName	- the name of the color or a (r,g,b,[a]) color.  must be MATLAB
%			  field name compatible.
%	alpha	- set a custom alpha for the color (0->1)
%
% Out:
%	col	- the color
% 
% Updated: 2011-12-17
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

if numel(varargin)>0
	alpha	= ParseArgs(varargin,[]);
else
	alpha	= [];
end

%get the numeric version of the color
	x	= strName;
	while ~isempty(x) && ischar(x)
		if isfield(PTBIFO.color,x)
			x	= PTBIFO.color.(x);
		else
			x	= [];
		end
		
		if isempty(x)
			x	= str2array(strName);
		end
	end
	
	if isempty(x)
		x	= [0 0 0];
	end
%convert to uint8
	x	= im2uint8(x);
%optionally change the alpha
	if ~isempty(alpha)
		x	= [x(1:3) alpha*255];
	elseif numel(x)==3
		x	= [x 255];
	end
