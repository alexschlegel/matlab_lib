function im = Figure2Image(h)
% Figure2Image
% 
% Description:	convert a figure to an image matrix
% 
% Syntax:	im = Figure2Image(h)
% 
% In:
% 	h	- a handle to the figure
% 
% Out:
% 	im	- the image matrix
% 
% Updated: 2010-10-16
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
f	= getframe(h);
im	= f.cdata;
