function [xt,yt,varargout] = Tilt(poi)
% PTB.Device.Pointer.Tilt
% 
% Description:	get the current tilt of the pointer
% 
% Syntax:	[xt,yt,t] = poi.Tilt
% 
% Out:
%	xt	- the current x tilt
%	yt	- the current y tilt
%	t	- the time associated with the query
%
% Updated: 2012-11-26
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[s,varargout{1:nargout-1}]	= poi.State;

xt	= s(poi.IDX_XTILT);
yt	= s(poi.IDX_YTILT);
