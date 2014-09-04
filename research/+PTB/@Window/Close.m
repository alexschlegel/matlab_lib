function Close(win)
% PTB.Window.Close
% 
% Description:	close the windows
% 
% Syntax:	win.Close
% 
% Updated: 2011-12-12
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%close the main window
	try
		hMain	= win.parent.Info.Get('window',{'h','main'});
		Screen('Close',hMain);
		strLog	= 'closed';
	catch me
		strLog	= ['closed (' regexprep(me.message,'\s+',' ') ')'];
	end
	win.AddLog(strLog);
	
	win.parent.Info.Unset('window',{'h','main'});

%close everything else
	h	= win.parent.Info.Get('window','h');
	
	if isstruct(h)
		h	= struct2array(h);
	else
		h	= [];
	end
	nH	= numel(h);
	
	%get the windows that are still open
		h	= intersect(h,Screen('Windows'));
	
	for kH=1:nH
		try
			Screen('Close',h(kH));
		catch me
		end
	end
	
	win.parent.Info.Unset('window','h');
