function [hA,hF] = canvas(varargin)
% canvas
% 
% Description:	create a figure and axes that fill it
% 
% Syntax:	[hA,hF] = canvas(<options>)
% 
% In:
% 	<options>:
%		color:	([1 1 1]) the canvas color
%		w:		(500) the axes width, in pixels
%		h:		(<w>) the axes height, in pixels
%		xlim:	([1 w]) the x-axis limits
%		ylim:	([1 h]) the y-axis limits
% 
% Out:
% 	hA	- the axes handle
%	hF	- the figure handle
% 
% Updated: 2012-01-01
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'color'	, [1 1 1]	, ...
		'w'		, 500		, ...
		'h'		, []		, ...
		'xlim'	, []		, ...
		'ylim'	, []		  ...
		);
opt.h		= unless(opt.h,opt.w);
opt.xlim	= unless(opt.xlim,[1 opt.w]);
opt.ylim	= unless(opt.ylim,[1 opt.h]);

hF		= figure;
pF		= get(hF,'Position');
pF(3:4)	= [opt.w opt.h];
set(hF,'Position',pF);

hA	= axes('position',[0 0 1 1],'XLim',opt.xlim,'YLim',opt.ylim,'XTick',[],'YTick',[],'Color',opt.color,'XColor',opt.color,'YColor',opt.color);
