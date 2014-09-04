function [x,y,t,xPx,yPx] = PositionVA(poi)
% PTB.Device.Pointer.PositionVA
% 
% Description:	get the current position of the pointer, with origin at the
%				center of the screen and in degrees of visual angle
% 
% Syntax:	[x,y,t,xPx,yPx] = poi.PositionVA
% 
% Out:
%	x	- the current x position, in d.v.a
%	y	- the current y position, in d.v.a
%	t	- the time associated with the query
%	xPx	- the x position in pixels
%	yPx	- the y position in pixels
%
% Updated: 2012-11-26
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[xPx,yPx,t,sz]	= poi.Position;

px	= [xPx yPx] - sz/2;
va	= poi.parent.Window.px2va(px);

x	= va(1);
y	= va(2);
