function save(s,strPathOut)
% neurojobs.save
% 
% Description:	save the results to a file for import into Excel
% 
% Syntax:	neurojobs.save(s,strPathOut)
% 
% Updated: 2015-03-06
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%format the results
	s		= restruct(s);
	s.date	= arrayfun(@(d) FormatTime(d,'yyyy-mm-dd'),s.date,'uni',false);
	
	s	= reorderstructure(s,'date');
	
	str	= struct2table(s,'delim','csv');
%save it
	fput(str,strPathOut);
