function im = b2rgb(b,varargin)
% b2rgb
% 
% Description:	convert a binary image to a color image
% 
% Syntax:	im = b2rgb(b,[colTrue]=[1 1 1],[colFalse]=[0 0 0)
% 
% In:
% 	b			- a binary image
%	colTrue		- the color to use for true pixels
%	colFalse	- the color to use for false pixels
% 
% Out:
% 	im	- the color image
% 
% Updated: 2014-02-05
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[colTrue, colFalse]	= ParseArgs(varargin,[1 1 1],[0 0 0]);

im	= ind2rgb(b,[colFalse; colTrue]);
