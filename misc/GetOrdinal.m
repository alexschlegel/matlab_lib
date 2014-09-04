function strOrdinal = GetOrdinal(n)
% GetOrdinal
% 
% Description:	get the ordinal (th/st/nd/rd) for a number
% 
% Syntax:	strOrdinal = GetOrdinal(n)
% 
% Updated: 2011-10-04
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get the tens and unit digits
	dTenUnit	= n - 100*fix(n/100);
	dTen		= abs(fix(dTenUnit/10));
	dUnit		= abs(dTenUnit - dTen*10);
%get the ordinal
	if dTen==1
		strOrdinal	= 'th';
	else
		switch dUnit
			case {0,4,5,6,7,8,9}
				strOrdinal	= 'th';
			case 1
				strOrdinal	= 'st';
			case 2
				strOrdinal	= 'nd';
			case 3
				strOrdinal	= 'rd';
		end
	end
	