function [p,varargout] = Pressure(poi)
% PTB.Device.Pointer.Pressure
% 
% Description:	get the current pressure on the pointer as a value between 0 (no
%				pressure) and 1 (maximum pressure)
% 
% Syntax:	[p,t] = poi.Pressure
% 
% Out:
%	p	- the current pressure
%	t	- the time associated with the query
%
% Updated: 2012-11-26
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[x,varargout{1:nargout-1}]	= poi.State;

p	= x(poi.IDX_PRESSURE);
