function cDefault = common_defaults()
% stimulus.image.common_defaults
% 
% Description:	common default options for stimulus image functions
% 
% Syntax:	cDefault = stimulus.image.common_defaults()
% 
% Notes:
%		size:		(400) the figure size
%		foreground:	([1 1 1]) the foreground color
%		background:	([0.5 0.5 0.5]) the background color
%		seed:		(randseed2) the seed to use for randomizing, or false to
%					skip seeding the random number generator
% 
% Updated: 2015-09-24
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent c;

if isempty(c)
	c	=	{
				'size'			, 400			, ...
				'foreground'	, [1 1 1]		, ...
				'background'	, [0.5 0.5 0.5]	, ...
				'seed'			, []			  ...
			};
end

cDefault	= c;
