function str = num2frac(x,varargin)
% num2frac
% 
% Description:	convert a number to a string representing the number as a
%				fraction
% 
% Syntax:	str = num2frac(x,[bProper]=false)
% 
% In:
% 	x			- a number
%	[bProper]	- true to convert to a proper fraction
% 
% Out:
% 	str	- the fraction string representation of the number
% 
% Updated: 2013-07-28
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
bProper	= ParseArgs(varargin,false);

[n,d]	= rat(x);

if bProper
	w	= fix(n/d);
	
	if w~=0
		n	= n - w*d;
		
		if n~=0
			str	= [num2str(w) ' ' nd2frac(n,d)];
		else
			str	= num2str(w);
		end
	else
		str	= nd2frac(n,d);
	end
else
	str	= nd2frac(n,d);
end

%------------------------------------------------------------------------------%
function str = nd2frac(n,d)
	if n~=0
		if d~=1
			str	= [num2str(n) '/' num2str(d)];
		else
			str	= num2str(n);
		end
	else
		str	= '0';
	end
end
%------------------------------------------------------------------------------%

end
