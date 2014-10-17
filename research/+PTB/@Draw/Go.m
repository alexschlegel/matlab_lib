function res = Go(drw,varargin)
% PTB.Draw.Go
% 
% Description:	start the drawing
% 
% Syntax:	res = drw.Go(<options>)
%
% In:
%	<options>:
%		underlay:	(<none>) an underlay image or the handle to a function
%						that takes the current time, the time of the next flip,
%						and a texture handle as inputs and draws the underlay on
%						that texture
%		unblock:	(true) true to unblock the monitor at the end of the drawing
%
% Out:
%	res	- a struct of information about the drawing
% 
% Updated: 2012-12-01
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

drw.t.go	= PTB.Now;

drw.AddLog('go');

opt	= ParseArgs(varargin,...
		'underlay'	, []	, ...
		'unblock'	, true	  ...
		);

%get some info
	rate	= PTBIFO.draw.rate;

if ~drw.prepared || ~isempty(opt.underlay)
%prepare the drawing if it hasn't already been
	drw.Prepare('underlay',opt.underlay);
end

%pause the scheduler
	bPauseScheduler	= drw.parent.Scheduler.Running;
	if bPauseScheduler
		drw.parent.Scheduler.Pause;
	end
%wait to start
	drw.t.start	= PTB.Now;
	while ~drw.f.start(drw.t.start,drw.t.go)
		WaitABit;
		
		drw.t.start	= PTB.Now;
	end
	
	drw.AddLog('start');
	
	drw.result.tstart	= drw.t.start;
%draw until we shouldn't
	[drw.running,drw.ran]	= deal(true);
	
	%initialize the time variables
		[drw.t.first.flip,drw.t.first.pen,drw.t.first.record,drw.t.next.flip,drw.t.next.pen,drw.t.next.record]	= deal(drw.t.start);
		
		[nFlip,nPen,nRecord]	= deal(0);
	
	tNow	= drw.t.start;
	
	if drw.showtimer
		[bEnd,drw.timerleft,drw.timertotal]	= drw.f.end(tNow,drw.t.start);
	else
		bEnd	= drw.f.end(tNow,drw.t.start);
	end
	
	while ~bEnd
		%check for flip
			bFlipped	= tNow>=drw.t.next.flip;
			if bFlipped
				drw.parent.Window.Flip;
				
				nFlip			= nFlip+1;
				drw.t.next.flip	= drw.t.first.flip + 1000*nFlip/rate.flip;
			end
		%check for pen
			if tNow>=drw.t.next.pen
				p_UpdatePen(drw);
				
				nPen			= nPen+1;
				drw.t.next.pen	= drw.t.first.pen + 1000*nPen/rate.pen;
			end
		%check for record
			if tNow>=drw.t.next.record
				p_RecordPen(drw);
				
				nRecord				= nRecord+1;
				drw.t.next.record	= drw.t.first.record + 1000*nRecord/rate.record;
			end
		%check for stimulus prep
			if bFlipped
				p_PrepareNextStimulus(drw,tNow,drw.t.next.flip,drw.t.start);
			end
		
		if drw.f.wait(drw,tNow,drw.t.next.flip,drw.t.start)
		%abort
			drw.result.abort	= true;
			break;
		end
		
		WaitABit;
		
		tNow	= PTB.Now;
		
		if drw.showtimer
			[bEnd,drw.timerleft,drw.timertotal]	= drw.f.end(tNow,drw.t.start);
		else
			bEnd	= drw.f.end(tNow,drw.t.start);
		end
	end
	
	drw.AddLog('end');
%resume the scheduler
	if bPauseScheduler
		drw.parent.Scheduler.Resume;
	end
%unblock the monitor
	if opt.unblock
		drw.parent.Window.UnblockMonitor;
	end
%set the results
	drw.result.tend						= tNow;
	drw.result.x(drw.result.N+1:end)	= [];
	drw.result.y(drw.result.N+1:end)	= [];
	drw.result.m(drw.result.N+1:end)	= [];
	drw.result.t(drw.result.N+1:end)	= [];
	drw.result.im						= p_ConstructImage(drw);
	drw.result.fliprate					= 1000*nFlip/(tNow-drw.t.start);
	drw.result.recordrate				= 1000/mean(diff(drw.result.t));
	
	drw.running		= false;
	drw.prepared	= false;

%------------------------------------------------------------------------------%
function WaitABit()
	drw.parent.Scheduler.Wait(drw.parent.Scheduler.PRIORITY_LOW);
end
%------------------------------------------------------------------------------%

end
