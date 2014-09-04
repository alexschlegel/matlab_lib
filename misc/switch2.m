function y = switch2(x,varargin)
% switch2
% 
% Description:	like switch but used to choose between possible return values
% 
% Syntax:	y = switch2(x,x1,y1,...,xN,yN,[y0]=[])
% 
% In:
% 	x	- the test value
%	xK	- the Kth possible x value, or a cell of possible values
%	yK	- the return value if x is in the xK set
%	y0	- the return value if x is not in any xK set
% 
% Out:
% 	y	- one of the yKs
% 
% Updated: 2011-10-21
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

nSwitch	= floor(numel(varargin)/2);

for kS=1:nSwitch
	kX	= 2*(kS-1)+1;
	kY	= kX+1;
	
	if (iscell(varargin{kX}) && isin(x,varargin{kX})) || isequal(x,varargin{kX})
		y	= varargin{kY};
		return;
	end
end

if isodd(numel(varargin))
	y	= varargin{end};
else
	y	= [];
end


%------------------------------------------------------------------------------%
function b = isin(a,c)
	b	= false;
	for k=1:numel(c)
		if isequal(a,c{k})
			b	= true;
			return;
		end
	end
%------------------------------------------------------------------------------%


