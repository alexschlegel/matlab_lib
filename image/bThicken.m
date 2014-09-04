function b = bThicken(b,w)
% bThicken
% 
% Description:	thicken the black features of a binary image so that a 1 pixel
%				wide feature becomes w pixels wide
% 
% Syntax:	b = bThicken(b,w)
% 
% Updated:	2009-04-02
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
w	= round(w);

%min filter the image to get our desired width
	fCircle	= MaskCircle(w);
	b	= ordfilt2(b,1,fCircle,'symmetric');
%get rid of extra white around the edges
	[y,x]	= find(b==0);
	mnY	= min(y);
	mxY	= max(y);
	mnX	= min(x);
	mxX	= max(x);
	b	= b(mnY:mxY,mnX:mxX);
