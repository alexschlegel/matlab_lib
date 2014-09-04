function Close(lg)
% PTB.Log.Close
% 
% Description:	close the log file
% 
% Syntax:	lg.Close()
% 
% Updated: 2011-12-10
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%close the log
	lg.parent.File.Close('log');
%stop the diary
	diary off;
%show some info
	strStatusLog	= ['log saved to: "' lg.parent.File.Get('log') '"'];
	lg.parent.Status.Show(strStatusLog,'time',false);
	
	strStatusDiary	= ['diary saved to: "' lg.parent.File.Get('diary') '"'];
	lg.parent.Status.Show(strStatusDiary,'time',false);
