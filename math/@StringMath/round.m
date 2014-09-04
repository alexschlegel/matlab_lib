function sm = round(sm)
% round
% 
% Description:	StringMath round function
% 
% Syntax:	sm = round(sm)
% 
% Updated:	2009-05-29
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

persistent sm01;
if isempty(sm01) || ~p_EqualProperties(sm01,sm)
	sm01	= p_TransferProperties(sm,StringMath('1'));
end

%get the numbers to round
	cDec	= {sm.dec};
	bRound	= ~cellfun('isempty',cDec) & cellfun(@(x) ~isempty(x) && x(1)>=5,cDec);

%make them positive
	s					= {sm(bRound).sign};
	[sm(bRound).sign]	= deal(1);
	
%round up
	sm(bRound)	= sm(bRound) + sm01;
	
%restore the sign
	[sm(bRound).sign]	= deal(s{:});
	
%make them integers
	[sm.dec]	= deal(int8([]));
