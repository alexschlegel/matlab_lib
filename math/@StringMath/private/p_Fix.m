function sm = p_Fix(sm)
% p_Fix
% 
% Description:	make sure aInt and aDec are well-formatted integer and decimal
%				components
% 
% Syntax:	sm = p_Fix(dm)
% 
% Updated:	2009-05-28
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get rid of trailing zeros
	sm.int	= RemoveTrailingZeros(sm.int);
	sm.dec	= RemoveTrailingZeros(sm.dec);
	
%make sure the empties are nice
	if isempty(sm.int)
		sm.int	= int8([]);
	end
	if isempty(sm.dec)
		sm.dec	= int8([]);
	end

%fix the sign
	if ~isempty(sm.int) && sm.int(end)<0;
		sm.int(end)	= -sm.int(end);
		sm.sign		= -sm.sign;
	end


%------------------------------------------------------------------------------%
function a = RemoveTrailingZeros(a)
	if numel(a)>0 && a(end)==0
		%find the last non-zero
			kLast	= find(a~=0,1,'last');
		%get rid of the last block
			a	= a(1:kLast);
	end
%------------------------------------------------------------------------------%
