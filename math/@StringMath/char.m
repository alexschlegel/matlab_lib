function str = char(sm)
% char
% 
% Description:	StringMath char function
% 
% Syntax:	str = char(sm)
% 
% Updated:	2009-05-28
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if numel(sm)==1
	strInt	= char(reshape(sm.int(end:-1:1)+48,1,[]));
	strDec	= char(reshape(sm.dec+48,1,[]));
	
	if sm.sign==1
		strSign	= '';
	else
		strSign	= '-';
	end
	
	if isempty(sm.int)
		if isempty(sm.dec)
			str	= '0';
		else
			str	= [strSign '0.' strDec];
		end
	else
		if isempty(sm.dec)
			str	= [strSign strInt];
		else
			str	= [strSign strInt '.' strDec];
		end
	end
else
	c	= objfun(@char,sm,'UniformOutput',false);
	str	= evalc('disp(c)');
end
