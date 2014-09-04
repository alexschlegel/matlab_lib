function p_RecordPen(drw)
% p_RecordPen
% 
% Description:	record the pen position
% 
% Syntax:	p_RecordPen(drw)
% 
% In:
%	drw		- the PTB.Draw object
% 
% Updated: 2012-12-01
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

bDampen	= false;

persistent tStartSame
tNow	= PTB.Now;

if isempty(tStartSame)
	tStartSame	= 0;
end

%get the actual mode
	[x,y]			= drw.parent.Pointer.Position;
	
	tLast			= drw.lasttime;
	drw.lasttime	= PTB.Now;
	
	diffMax	= 500*(drw.lasttime-tLast)/1000;
	
	if tLast==0
		xDamp	= x;
		yDamp	= y;
	else
		xDiff	= x - drw.lastrecord(2);
		yDiff	= y - drw.lastrecord(3);
		
		if bDampen
			rDiff	= min(diffMax,sqrt(xDiff.^2 + yDiff.^2));
		else
			rDiff	= sqrt(xDiff.^2 + yDiff.^2);
		end
		aDiff	= atan2(yDiff,xDiff);
		
		xDamp	= drw.lastrecord(2) + rDiff*cos(aDiff);
		yDamp	= drw.lastrecord(3) + rDiff*sin(aDiff);
	end
	
	drw.actualmode	= drw.parent.Pointer.Mode;
	
	m	= drw.actualmode;

if PTBIFO.draw.mode.delay>0
%check to see if we should switch the mode
	if drw.lastrecord(1)~=0
	%nothing to check, we haven't been in move mode previously
		drw.lastrecord	= [m xDamp yDamp];
		
		tStartSame	= tNow;
	elseif m~=0
	%we're newly in a non-move mode
		if sqrt((x-drw.lastrecord(2)).^2 + (y-drw.lastrecord(3)).^2) > 10 
		%if x~=drw.lastrecord(2) || y~=drw.lastrecord(3)
		%we're moving, wait until we're stationary
			drw.lastrecord(2:3)	= [xDamp yDamp];
			
			m	= 0;
			
			tStartSame	= tNow;
		elseif tNow<tStartSame + PTBIFO.draw.mode.delay
		%we're still, but not long enough yet
			m	= 0;
		else
		%we've been stationary long enough, change modes!
			drw.lastrecord	= [m xDamp yDamp];
			
			tStartSame	= tNow;
		end
	else
		drw.lastrecord	= [m xDamp yDamp];
	end
end

drw.current.pen.position	= [xDamp yDamp];
drw.current.pen.mode		= m;
drw.current.t				= tNow;

drw.result.N				= drw.result.N + 1;
drw.result.x(drw.result.N)	= drw.current.pen.position(1);
drw.result.y(drw.result.N)	= drw.current.pen.position(2);
drw.result.m(drw.result.N)	= drw.current.pen.mode;
drw.result.t(drw.result.N)	= tNow;
