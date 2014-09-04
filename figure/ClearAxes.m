function ClearAxes(h)
% ClearAxes
% 
% Description:	clear the specified axes of ticks and other stuff
% 
% Syntax:	ClearAxes(h)
% 
% In:
% 	h	- the handle to the axes
% 
% Updated:	2011-03-18
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%clear all children
	%cla(h);
	
%clear ticks
	set(h,'XTick',[]);
	set(h,'YTick',[]);
	set(h,'ZTick',[]);
%make everything the same as the axes color
	%set(h,'Color',[1 1 1]);
	c	= get(h,'Color');
	
	set(h,'XColor',c);
	set(h,'YColor',c);
	set(h,'ZColor',c);
