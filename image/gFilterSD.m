function g = gFilterSD(g,varargin)
% gFilterSD
% 
% Description:	replaces each value in the grayscale image g with the standard
%				deviation of its neighbor pixels
% 
% Syntax:	g = gFilterSD(g,[f]=ones(3))
%
% In:
%	g	- a grayscale image
%	[f]	- the binary neighborhood matrix
% 
% Out:
%	g	- the filtered image
%
% Updated:	2010-04-19
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
f	= ParseArgs(varargin,ones(3));
n	= sum(f(:));

%calculate the mean of each neighborhood
	m	= imfilter(g,f./n,'symmetric');
	
%calculate the sd
	g	= sqrt(imfilter((g-m).^2,f./n,'symmetric'));
	