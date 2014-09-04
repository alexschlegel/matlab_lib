function [str,bUnFilled,bEmptyField] = StringFillTemplate(strTemplate,sFill)
% StringFillTemplate
% 
% Description:	fill a template string with values
% 
% Syntax:	str = StringFillTemplate(strTemplate,sFill)
% 
% In:
% 	strTemplate	- a template string with values to fill denoted by "<name>"
%	sFill		- a struct with fields corresponding to values to fill in the
%				  template (e.g. sFill.name)
% 
% Out:
% 	str			- the filled template string
%	bUnFilled	- true if values were left unfilled in the template
%	bEmptyField	- true if a fill value was empty
% 
% Updated: 2011-11-13
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
cField	= fieldnames(sFill);
nField	= numel(cField);

bEmptyField	= false;

str	= strTemplate;
for kF=1:nField
	strOld	= str;
	str		= strrep(str,['<' cField{kF} '>'],tostring(sFill.(cField{kF})));
	
	if ~isequal(str,strOld) && isempty(sFill.(cField{kF}))
		bEmptyField	= true;
	end
end

bUnFilled	= ~isempty(regexp(str,'<[^A-Za-z_]+>'));
