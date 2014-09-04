function t = TR(scn)
% PTB.Scanner.TR
% 
% Description:	get the current TR, with a fractional estimate
% 
% Syntax:	t = scn.TR
%
% Out:
%	t	- the current TR number, with a fractional estimate (e.g. 2.5 for half
%		  way between TRs 2 and 3)
% 
% Updated: 2012-07-04
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

%update the TR
	[d,tTrigger]	= scn.parent.Serial.Check(scn.SCANNER_TRIGGER);
	
	t	= PTBIFO.scanner.tr.heard + numel(d);
%store it
	if t~=PTBIFO.scanner.tr.heard
		%update the number of heard TRs
			PTBIFO.scanner.tr.heard	= t;
		%update the record of when TRs happened
			PTBIFO.scanner.tr.time	= [PTBIFO.scanner.tr.time; sort(tTrigger)];
		if t<=PTBIFO.scanner.tr.total
		%add a log entry
			strTotal	= num2str(PTBIFO.scanner.tr.total);
			nFill		= numel(strTotal);
			strNow		= StringFill(t,nFill);
			
			scn.AddLog(['TR: ' strNow '/' strTotal],tTrigger(1));
		end
	end
%if we're on the last TR then simulate the next one (i.e. the end of the last
%frame of the stimulus
	if t==PTBIFO.scanner.tr.total
		if ~notfalse(scn.parent.Info.Get('scanner','last'))
			PTBIFO.scanner.last	= true;
			
			scn.parent.Scheduler.Remove('scanner');
			
			try
				stop(scn.TSim);
				set(scn.TSim,'TasksToExecute',1,'StartDelay',PTBIFO.scanner.tr.per/1000);
				start(scn.TSim);
			catch me
				scn.AddLog('error simulating final TR');
			end
		end
	end
%estimate the fractional part of the TR
	if ~isempty(PTBIFO.scanner.tr.time)
		tFrac	= (PTB.Now - PTBIFO.scanner.tr.time(end))./PTBIFO.scanner.tr.per;
		
		%if tFrac<1
			t		= t + tFrac;
		%end
	end
	