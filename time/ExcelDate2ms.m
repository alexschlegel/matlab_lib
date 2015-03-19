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
% Updated: 2015-03-10
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
persistent serialEpoch

if isempty(serialEpoch)
	serialEpoch	= FormatTime('1899-12-30 00:00:00');
end

if ~isnan(t)
	switch class(t)
		case 'char'
			t	= FormatTime(t);
		otherwise
		%t is a serial date
			t	= t*86400000 + serialEpoch;
	end
end
