function [nMonitor,resMonitor,pMonitor] = GetMonitorInfo()
% GetMonitorInfo
% 
% Description:	get information about the current monitors 
% 
% Syntax:	[nMonitor,resMonitor,pMonitor] = GetMonitorInfo()
% 
% Out:
% 	nMonitor	- the number of monitors
%	resMonitor	- an nMonitor x 2 array of the Width x Height resolution of each
%				  monitor
%	pMonitor	- an nMonitor x 2 array of the (Left,Top) position of each
%				  monitor. (0,0) is the upper-left of the monitor array
% 
% Updated: 2011-12-12
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

if isunix
%don't trust MonitorPositions since X can put two monitors on a single screen
	%try to get the info from xrandr
		[ec,strOutput]	= system('xrandr');
		
		%break up into lines
			cOutput	= split(strOutput,'[\n\r]+');
		%get the lines describing the monitor positions
			bMonitor	= cellfun(@(x) ~isempty(strfind(x,' connected')),cOutput);
		%get the position info for each monitor
			nMonitor	= sum(bMonitor);
			sPosition	= cellfun(@(x) regexp(x,'(?<width>\d+)x(?<height>\d+)\+(?<left>\d+)\+(?<top>\d+)','names'),cOutput(bMonitor),'UniformOutput',false);
			bValid		= ~cellfun(@isempty,sPosition);
			sPosition	= cat(1,sPosition{bValid});
			
			w	= cellfun(@str2num,{sPosition.width});
			h	= cellfun(@str2num,{sPosition.height});
			l	= cellfun(@str2num,{sPosition.left});
			t	= cellfun(@str2num,{sPosition.top});
			
			resMonitor	= [w' h'];
			pMonitor	= [l' t'];
	%does Screen recognize more monitors?
		s	= Screen('Screens');
		if numel(s) > nMonitor
			nMonitor	= numel(s);
			
			rect		= arrayfun(@(k) Screen('Rect',k),s,'UniformOutput',false);
			rect		= cat(1,rect{:});
			resMonitor	= rect(:,3:4) - rect(:,1:2);
			
			if ~all(reshape(rect(:,1:2)==0,[],1))
			%Screen know the positions
				pMonitor	= rect(:,1:2);
			else
			%just assume the monitors go left to right
				pMonitor	= cumsum([0 0; rect(1:end-1,3:4)]);
			end
		end
else
	mp	= get(0,'MonitorPositions');
	
	nMonitor	= size(mp,1);
	resMonitor	= mp(:,3:4) - mp(:,1:2) + 1;
	pMonitor	= mp(:,1:2);
	
	%find the top-left of the array
		pTL			= min(pMonitor);
		pMonitor	= pMonitor - repmat(pTL,[nMonitor 1]);
end
