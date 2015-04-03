function b = bitgt(x,y)
% bitgt
% 
% Description:	check whether bit array x represents a number greater than that
%				represented by bit array y
% 
% Syntax:	b = bitgt(x,y)
% 
% Updated: 2015-03-19
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nX	= numel(x);
nY	= numel(y);

if nX>nY && any(x(nY+1:end))
	b	= true;
	return;
elseif nX<nY && any(y(nX+1:end))
	b	= false;
	return;
end

n	= min(nX,nY);
for k=n:-1:1
	if x(k)
		if ~y(k)
			b	= true;
			return;
		end
	elseif y(k)
		b	= false;
		return;
	end
end

b	= false;
