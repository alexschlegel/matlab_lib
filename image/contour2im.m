function im = contour2im(y,x,varargin)
% contour2im
% 
% Description:	construct an image representing a contour
% 
% Syntax:	im = contour2im(y,x,[s]=<tightest>,[kStart]=1,[kEnd]=<end>,[strInterp]='pchip')
% 
% In:
%	y			- an N-length vector of y values, in pixels
% 	x			- an N-length vector of x values, in pixels
%	[s]			- the size of the output image
%	[kStart]	- the index of the first point on the contour to represent in
%				  the image
%	[kEnd]		- the index of the last point on the contour to represent in the
%				  image
%	[strInterp]	- the interpolation method to use (see interp1)
% 
% Out:
% 	im	- the binary contour image
% 
% Updated: 2013-04-17
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[s,kStart,kEnd,strInterp]	= ParseArgs(varargin,[],1,numel(x),'pchip');

n	= numel(x);

if n==1
	yI	= y;
	xI	= x;
else
	%get the contour length
		[L,d]	= contourlength(x,y);
	
		if L>10*n
		%do an initial interpolation to get a better estimate of the length
			nIInit	= round(L/10);
			
			tInit	= (0:n-1)'./(n-1);
			tIInit	= (0:nIInit-1)'./(nIInit-1);
			
			yIInit	= round(interp1(tInit,y,tIInit,strInterp));
			xIInit	= round(interp1(tInit,x,tIInit,strInterp));
			
			[L,d]	= contourlength(xIInit,yIInit);
		end
	%construct the step parameter so we get constant spacing along the contour
		p		= [0; cumsum(d)];
		t		= GetInterval(0,1,numel(p))';
		
		[pU,kU]	= unique(p);
		tU		= t(kU);
		
		tI	= [0; interp1(pU,tU,GetInterval(1,L,round(2*L))','linear'); 1];
	
	tIStart	= round((kStart-1)/(n-1));
	tIEnd	= round((kEnd-1)/(n-1));
	
	t		= (0:n-1)'./(n-1);
	tI		= tI(tI >= tIStart & tI <= tIEnd);
	
	yI	= round(interp1(t,y,tI,strInterp));
	xI	= round(interp1(t,x,tI,strInterp));
end

if isempty(s)
	s	= [max(yI) max(xI)];
end

bBad		= yI<1 | yI>s(1) | xI<1 | xI>s(2);
yI(bBad)	= [];
xI(bBad)	= [];

im		= false(s);
kI		= sub2ind(s,yI,xI);
im(kI)	= true;
