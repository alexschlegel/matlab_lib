function y = dummy(x)
% dummy
% 
% Description:	construct something that looks like x but is filled with dummy
%				values
% 
% Syntax:	y = dummy(x)
% 
% Updated: 2015-03-20
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
switch class(x)
	case 'struct'
		y	= structfun2(@dummy,x);
	case 'cell'
		y	= cellfun(@dummy,x,'uni',false);
	case 'char'
		y	= '';
	otherwise
		y	= NaN(size(x));
end
