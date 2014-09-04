function str = underline(str,sFont)
% underline
% 
% Description:	produce TeX-formatted underlined text
% 
% Syntax:	str = underline(str,sFont)
% 
% Updated: 2011-10-26
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
nStr	= numel(str);

u	= repmat('\_',[1 2*nStr]);
str	= ['_{\fontsize{' num2str(sFont) '}^{' str '}_{^{' u '}}}']; 
