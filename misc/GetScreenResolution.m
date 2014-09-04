function [w,h] = GetScreenResolution()
% GetScreenResolution
% 
% Description:	get the width and height of the screen
% 
% Syntax:	[w,h] = GetScreenResolution()
% 
% Updated:	2009-03-09
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
	s = get(0,'ScreenSize');
	
	w	= s(3);
	h	= s(4);
	