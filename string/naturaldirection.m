function strDirection = naturaldirection(a,varargin)
% naturaldirection
% 
% Description:	get a natural name for the direction in which an object is
%				facing
% 
% Syntax:	strDirection = naturaldirection(a,[symmetry]='none')
% 
% In:
% 	a			- the angle of rotation of the object, in degrees
%	[symmetry]	- the type of symmetry exhibited by the object. only '90' and
%				  '180' do anything
% 
% Out:
% 	strDirection	- a string describing the object's direction
% 
% Updated: 2014-11-11
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
symmetry	= ParseArgs(varargin,'none');

a	= fixangle(a);
switch symmetry
	case '90'
		switch a
			case {-90, 0, 90, 180}
				strDirection	= '';
			otherwise
				strDirection	= [naturalangle(a) ' rotated'];
		end
	case '180'
		switch a
			case {0, 180}
				strDirection	= 'vertical';
			case {-90,90}
				strDirection	= 'horizontal';
			otherwise
				strDirection	= [naturalangle(a) ' rotated'];
		end
	otherwise
		switch a
			case 0
				strDirection	= 'up facing';
			case 90
				strDirection	= 'right facing';
			case 180
				strDirection	= 'down facing';
			case -90
				strDirection	= 'left facing';
			otherwise
				strDirection	= [naturalangle(a) ' rotated'];
		end
end
