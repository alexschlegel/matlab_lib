function sme = exp(sm)
% exp
% 
% Description:	StringMath exp function
% 
% Syntax:	sm = exp(sm)
% 
% Updated:	2009-05-30
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%fix the input
	[sm,bEmptyInput]	= p_FixInput(sm);
	n					= numel(sm);
	
	if bEmptyInput
		sme	= [];
		return;
	end

persistent sm0 sm01;
if isempty(sm0) || ~p_EqualProperties(sm0,sm)
	[sm0,sm01]	= p_TransferProperties(sm,StringMath('0'),StringMath('1'));
end

%initialize
	sme	= p_TransferProperties(sm,sm01);
	sme	= repmat(sme,size(sm));

%exp!
	for k=1:n
		%get the precision test value
			smTest	= sm0;
			smTest.dec(sm(k).precision)	= 1;
		
		vCur	= sm(k);
		vDiv	= sm01;
		while vCur>=smTest
			%add it
				sme(k)	= sme(k) + vCur;
			%calculate the next term
				vDiv	= vDiv + sm01;
				vCur	= vCur .* sm(k) ./ vDiv;
		end
	end
	