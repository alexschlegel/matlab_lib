function Append(lg,varargin)
% Group.Log.Append
% 
% Description:	append an event to the log
% 
% Syntax:	lg.Append([ifo]='',[t]=<now>,[bImmediate]=false)
% 
% In:
%	ifo				- info about the event
%	t				- the Group.Now time of the event
%	[bImmediate]	- true to add the event immediately, false to send it to the
%					  scheduler
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[ifo,t,bImmediate]	= ParseArgs(varargin,'',[],false);

if isempty(t)
	t	= Group.Now;
end

if bImmediate
	ActuallyAppend(ifo,t);
else
	lg.root.Scheduler.Add(@ActuallyAppend,15,'log_append',{ifo,t},[],lg.root.Scheduler.PRIORITY_LOW);
end

%------------------------------------------------------------------------------%
function bAbort	= ActuallyAppend(ifo,t)
	bAbort	= false;

	%append the event
		lg.root.info.(lg.type).event.time(end+1)	= t;
		lg.root.info.(lg.type).event.type{end+1}	= lg.parent.type;
		lg.root.info.(lg.type).event.info{end+1}	= ifo;
		
		nEvent	= numel(lg.root.info.(lg.type).event.time);
	%format the event string
		[strStatus,strFile]	= lg.ToString(nEvent);
	%save it to file
		if lg.root.info.(lg.type).save
			lg.root.File.AppendLine(strFile,lg.type);
		end
	%display the event
		if isequal(lg.root.info.(lg.type).hide,false) || (~islogical(lg.root.info.(lg.type).hide) && ~ismember(strType,lg.root.info.(lg.type).hide))
			lg.root.Status.Show(strStatus,'time',false);
		end
end
%------------------------------------------------------------------------------%

end
