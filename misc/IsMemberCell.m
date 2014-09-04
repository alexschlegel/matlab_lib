function [tf,loc] = IsMemberCell(a,b)
% IsMemberCell
% 
% Description:	ismember implemented for arbitrary cells
% 
% Syntax:	[tf,loc] = IsMemberCell(a,b)
% 
% In:
% 	a	- a cell
%	b	- another cell
% 
% Out:
% 	tf	- a logical array the same size as a indicating which elements of a are
%		  also in b
%	loc	- for each element in a, the highest index in b that matches that
%		  element, or 0 if no matches occur
% 
% Updated:	2009-05-27
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

nA	= numel(a);
nB	= numel(b);

tf	= false(size(a));
loc	= zeros(size(a));
for kA=1:nA
	for kB=nB:-1:1
		if isequalwithequalnans(a{kA},b{kB})
			tf(kA)	= true;
			loc(kA)	= kB;
			break;
		end
	end
end

