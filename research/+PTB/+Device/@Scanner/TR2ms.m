function t = TR2ms(scn,tr)
% PTB.Scanner.TR2ms
% 
% Description:	convert a TR to either the time at which it occurred or an
%				estimate of the time at which it will occur
% 
% Syntax:	t = scn.TR2ms(tr)
%
% In:
%	tr	- the TR number
%
% Out:
%	t	- the PTB.Now time associated with the tr
% 
% Updated: 2011-12-16
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

tTR	= PTBIFO.scanner.tr.time;
nTR	= numel(tTR);

durTR	= PTBIFO.scanner.tr.per;

if tr>0
	if tr<=nTR
	%into the past
		trWhole	= fix(tr);
		trFrac	= abs(tr-trWhole);
		
		t	= tTR(trWhole) + trFrac*durTR;
	else
	%into the future!
		if nTR>0
			t	= tTR(end) + (tr-nTR)*durTR;
		else
			t	= 0;
		end
	end
else
%weird
	if nTR>0
		t	= tTR(1) - (-tr+1)*durTR;
	else
		t	= 0;
	end
end
