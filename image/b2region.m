function r = b2region(b,varargin)
% b2region
% 
% Description:	converts a binary image to a regionprops struct
% 
% Syntax:	r = b2region(b,prop1,...,propN)
%
% In:
%	b		- a binary image
%	propK	- see regionprops help
% 
% Out:
%	r	- the regionprops struct
%
% Updated:	2010-04-20
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
b	= bwconncomp(b);
r	= regionprops(b,varargin{:});
