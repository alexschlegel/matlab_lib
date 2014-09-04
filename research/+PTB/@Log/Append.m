function Append(lg,strType,varargin)
% PTB.Log.Append
% 
% Description:	append an event to the log
% 
% Syntax:	lg.Append(strType,[ifo]='',[t]=<now>,[bImmediate]=false)
% 
% In:
% 	strType			- the event type
%	ifo				- info about the event
%	t				- the PTB.Now time of the event
%	[bImmediate]	- true to add the event immediate, false to send it to the
%					  scheduler
% 
% Updated: 2011-12-17
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[ifo,t,bImmediate]	= ParseArgs(varargin,'',[],false);

if isempty(t)
	t	= PTB.Now;
end

if bImmediate
	ActuallyAppend(ifo,t);
else
	lg.parent.Scheduler.Add(@ActuallyAppend,15,'log_append',{ifo,t},[],lg.parent.Scheduler.PRIORITY_LOW);
end

%------------------------------------------------------------------------------%
function bAbort	= ActuallyAppend(ifo,t)
	global PTBIFO;
	
	bAbort	= false;

	%append the event
		PTBIFO.log.event.time(end+1)	= t;
		PTBIFO.log.event.type{end+1}	= strType;
		PTBIFO.log.event.info{end+1}	= ifo;
		
		nEvent	= numel(PTBIFO.log.event.time);
	%format the event string
		[strStatus,strFile]	= lg.ToString(nEvent);
	%save it to file
		lg.parent.File.AppendLine(strFile,'log');
	%display the event
		if isequal(PTBIFO.log.event_hide,false) || (~islogical(PTBIFO.log.event_hide) && ~ismember(strType,PTBIFO.log.event_hide))
			lg.parent.Status.Show(strStatus,'time',false);
		end
end
%------------------------------------------------------------------------------%

end
