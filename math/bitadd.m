function x = bitadd(a,b)
% bitadd
% 
% Description:	add two numbers represented as bit arrays
% 
% Syntax:	x = bitadd(a,b)
% 
% Updated: 2015-03-19
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nA		= numel(a);
nB		= numel(b);
nMax	= max(nA,nB);

if nA<nMax
	a(end+1:nMax)	= false;
elseif nB<nMax
	b(end+1:nMax)	= false;
end

x	= false(1,nMax+1);

for k=1:nMax
	if a(k)
		if b(k)
			x(k+1)	= true;
		elseif x(k)
			x(k+1)	= true;
			x(k)	= false;
		else
			x(k)	= true;
		end
	elseif b(k)
		if x(k)
			x(k+1)	= true;
			x(k)	= false;
		else
			x(k)	= true;
		end
	end
end

if ~x(end)
	x	= x(1:end-1);
end
