function tr = ms2TR(scn,t)
% PTB.Scanner.ms2TR
% 
% Description:	convert a PTB.Now time to a TR (with fractional part)
% 
% Syntax:	tr = scn.ms2TR(t)
%
% In:
%	t	- the PTB.Now time associated with the tr
%
% Out:
%	tr	- the TR number (with fractional part)
% 
% Updated: 2011-12-22
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

tTR	= PTBIFO.scanner.tr.time;
nTR	= numel(tTR);

durTR	= PTBIFO.scanner.tr.per;

if nTR>0
	if t<tTR(1)
	%t is before the first TR
		tr	= 1 + (t-tTR(1))/durTR;
	else
	%find the closest TR to t
		kClosest	= find(t>=tTR,1,'first');
		
		if isempty(kClosest)
			tr	= NaN;
		else
			tr	= kClosest + (t-tTR(kClosest))/durTR;
		end
	end
else
	tr	= NaN;
end
