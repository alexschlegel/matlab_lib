function t = ExcelDate2ms(t)
% ExcelDate2ms
% 
% Description:	convert a date read in from an Excel spreadsheet (e.g. via
%				xlsread) to number of milliseconds since the epoch
% 
% Syntax:	t = ExcelDate2ms(t)
% 
% Assumptions: if t is a string, assumes it can be automatically converted via
%				FormatTime
% 
% Updated: 2011-10-13
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

if ~isnan(t)
	switch class(t)
		case 'char'
			t	= FormatTime(t);
		otherwise
		%t is a serial date
			t	= t*86400000 + FormatTime('1899-12-30 00:00:00');
	end
end
