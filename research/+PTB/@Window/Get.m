function [h,varargout] = Get(win,strName)
% PTB.Window.Get
% 
% Description:	get info about a named window
% 
% Syntax:	[h,sz,rect,szVA] = win.Get(strName)
% 
% In:
% 	strName	- the name of the window (previously assigned using win.Set), or the
%			  handle to a window
%
% Out:
%	h		- the handle to the window
%	sz		- the size of the window, in pixels
%	rect	- the window rect
%	szVA	- the size of the window, in degrees of visual angle
% 
% Updated: 2011-12-11
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
switch class(strName)
	case 'char'
		h	= win.parent.Info.Get('window',{'h',strName});
	otherwise
		h	= strName;
end

if nargout>1
	if ~isempty(h)
	%calculate the size of the window
		rect	= Screen('Rect',h);
		sz		= rect(3:4) - rect(1:2);
		
		varargout{1}	= sz;
		
		if nargout>2
		%return the rect
			varargout{2}	= rect;
			
			if nargout>3
			%return the size in degrees of visual angle
				varargout{3}	= win.px2va(sz);
			end
		end
	else
		[varargout{1:nargout-1}]	= deal([]);
	end
end
