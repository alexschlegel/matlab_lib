function d = double(sm)
% double
% 
% Description:	convert a StringMath object to a double
% 
% Syntax:	d = double(sm)
% 
% Updated:	2009-05-30
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%fix the input
	[sm,bEmptyInput]	= p_FixInput(sm);
	
	if bEmptyInput
		d	= [];
		return;
	end

%convert from number to ascii and concatenate
	cNumber	= cellfun(@(x) x+48,{sm.int},'UniformOutput',false);
	
	cDec			= {sm.dec};
	bDec			= ~cellfun('isempty',cDec);
	cNumber(bDec)	= cellfun(@(x,y) [x 46 y+48],cNumber(bDec),cDec(bDec),'UniformOutput',false);
%convert to string then number
	cNumber	= cellfun(@char,cNumber,'UniformOutput',false);
	d		= cellfun(@str2num,cNumber);
%add the sign
	bNeg	= [sm.sign]==-1;
	d(bNeg)	= -d(bNeg);
%reshape
	d	= reshape(d,size(sm));
	