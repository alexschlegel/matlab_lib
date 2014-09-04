function [m,varargout] = Mode(poi)
% PTB.Device.Pointer.Mode
% 
% Description:	get the current pointer mode:
%	
% 
% Syntax:	[m,t] = poi.Mode
% 
% Out:
%	m	- the current mode (see poi.MODE_* constants)
%	t	- the time associated with the query
%
% Updated: 2012-11-26
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[x,varargout{1:nargout-1}]	= poi.State;

m	= poi.MODE_DRAW*x(poi.IDX_DRAW) + poi.MODE_ERASE*x(poi.IDX_ERASE);

if m~=poi.lastMode
	if bitand(m,poi.MODE_DRAW)
		poi.AddLog('draw mode');
	end
	
	if bitand(m,poi.MODE_ERASE)
		poi.AddLog('erase mode');
	end
	
	if m==0
		poi.AddLog('move mode');
	end
end

poi.lastMode	= m;
