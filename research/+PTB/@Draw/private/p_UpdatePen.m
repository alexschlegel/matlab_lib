function p_UpdatePen(drw)
% p_UpdatePen
% 
% Description:	update the pen
% 
% Syntax:	p_UpdatePen(drw)
% 
% In:
%	drw		- the PTB.Draw object
% 
% Updated: 2012-11-07
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
drw.current.pen.shape		= drw.f.pen.shape(drw.t.next.flip,drw.t.start);
drw.current.pen.color		= drw.f.pen.color(drw.t.next.flip,drw.t.start);
drw.current.erase.shape		= drw.f.erase.shape(drw.t.next.flip,drw.t.start);

if ischar(drw.current.pen.color)
	drw.current.pen.color	= drw.parent.Color.Get(drw.current.pen.color);
end
