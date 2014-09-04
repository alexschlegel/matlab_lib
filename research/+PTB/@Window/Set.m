function Set(win,strName,h,varargin)
% PTB.Window.Set
% 
% Description:	set the handle of a named window
% 
% Syntax:	win.Set(strName,h,<options>)
% 
% In:
% 	strName	- the name of the window (e.g. 'main'), must be field name compatible
%	h		- the handle of the window
%	<options>: (see PTB.Info.Set)
% 
% Updated: 2011-12-11
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
win.parent.Info.Set('window',{'h',strName},h,varargin{:});

%we won't actually use this later, but just set it for the record
	rect	= Screen('Rect',h);
	win.parent.Info.Set('window',{'rect',strName},rect,varargin{:});
