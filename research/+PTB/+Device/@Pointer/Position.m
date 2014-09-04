function [x,y,varargout] = Position(poi)
% PTB.Device.Pointer.Position
% 
% Description:	get the current position of the pointer
% 
% Syntax:	[x,y,t,sz] = poi.Position
% 
% Out:
%	x	- the current x position
%	y	- the current y position
%	t	- the time associated with the query
%	sz	- the window size (to avoid having to calculate this twice)
%
% Updated: 2012-07-20
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

if nargout>2
	[s,varargout{1}]	= poi.State;
else
	s	= poi.State;
end

rect	= PTBIFO.window.rect.main;
sz		= rect(3:4) - rect(1:2);

x	= 1+(sz(1)-1)*s(poi.IDX_XPOS);
y	= 1+(sz(2)-1)*s(poi.IDX_YPOS);

if nargout>3
	varargout{2}	= sz;
end
