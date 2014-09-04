function k = AngleSection(a,s)
% ANGLESECTION
% 
% Description:	determine to which of the sections defined in s the angles in a
%				belong.
% 
% Syntax:	k = AngleSection(a,s)
%
% In:
%	a	- a matrix of angles
%	s	- the angle section cutoffs.  s is assumed to be increasing
% 
% Out:
%	k	- the s section to which each a belongs.  section 1 is the section with
%		  angles less than s(1) or greater than s(2)
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
	nS	= numel(s);
	
	k	= zeros(size(a));
	for kS=2:nS
		k(a>s(kS-1) & a<=s(kS))	= kS;
	end
	k(a<=s(1) | a>s(nS))	= 1;
	