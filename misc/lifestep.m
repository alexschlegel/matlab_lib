function y = lifestep(x,varargin)
% lifestep
% 
% Description:	perform one iteration of Conway's Game of Life
% 
% Syntax:	y = lifestep(x,<options>)
% 
% In:
% 	x	- a 2D binary array
%	<options>:
%		starve:	(1) the maximum number of neighbors that is insufficient to
%				sustain a unit
%		spawn:	(3) the minimum number of neighbors needed to spawn a new unit
%		crowd:	(4) the minimum number of neighbors to kill off a unit
% 
% Out:
% 	y	- x, processed through one step of the Game of Life
% 
% Updated: 2014-06-24
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent flt;

if isempty(flt)
	flt			= ones(3);
	flt(2,2)	= 0;
end

opt	= ParseArgs(varargin,...
		'starve'	, 1	, ...
		'spawn'		, 3	, ...
		'crowd'		, 4	  ...
		);

%logical version of x
	b	= logical(x);
%calculate the number of neighbors of each cell
	y	= imfilter(uint8(x),flt,0);
%which cells are alive in the next round?
	y	= ((b & y>opt.starve) | y>=opt.spawn) & y<opt.crowd; 
