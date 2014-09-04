function str = EscapeArgument(x)
% EscapeArgument
% 
% Description:	escape a command line argument
% 
% Syntax:	arg = EscapeArgument(arg)
% 
% Updated: 2014-03-29
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
str	= reshape(tostring(x),1,[]);
	
%escape quotes that are already escaped, enclosing the string, or directly
%after an equals sign
	re		= '([^=\\])"(.)';
	strNew	= regexprep(str,re,'$1\\"$2');
	while ~isequal(str,strNew)
		str		= strNew;
		strNew	= regexprep(str,re,'$1\\"$2');
	end
%add double quote if necessary
	if ~isempty(find(str==' ',1)) && numel(str)>=2 && (str(1)~='"' || str(end)~='"')
		str	= ['"' str '"'];
	end