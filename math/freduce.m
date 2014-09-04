function varargout = freduce(n,d)
% freduce
% 
% Description:	reduce a fraction to lowest terms
% 
% Syntax:	[n,d] = freduce(n,d)
% 
% In:
% 	n	- the numerator
%	d	- the denominator
% 
% Out:
% 	n	- the reduced numerator
%	d	- the reduced denominator
% 
% Updated: 2011-09-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
fn	= factor(n);
fd	= factor(d);
c	= prod(common(fn,fd));
n	= n/c;
d	= d/c;

if nargout>0
	varargout{1}	= n;
	varargout{2}	= d;
else
	disp([num2str(n) '/' num2str(d)]);
end

%------------------------------------------------------------------------------%
function c = common(a,b)
	nA	= numel(a);
	nB	= numel(b);
	
	if nA<nB
		s1	= a;
		s2	= b;
		n	= nA;
	else
		s1	= b;
		s2	= a;
		n	= nB;
	end
	
	c	= [];
	for k=1:n
		[bm,km]	= ismember(s1(k),s2);
		if bm
			c		= [c; s1(k)];
			s2(km)	= [];
		end
	end
%------------------------------------------------------------------------------%
