function disp(obj)
% stimulus.property.collection.disp
% 
% Description:	display the collection
% 
% Syntax: obj.disp()
% 
% Updated:	2015-09-29
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
cField	= fieldnames(obj.prop);
nField	= numel(cField);

strIndent	= '     ';
lenField	= max(cellfun(@numel,cField));

if nField==0
	disp([strIndent 'empty collection']);
else
	for kF=1:nField
		strProp		= StringFill(cField{kF},lenField,' ');
		strValue	= StringTrim(evalc('disp(obj.prop.(cField{kF}))'));
		
		disp(sprintf('%s%s: %s',strIndent,strProp,strValue));
	end
end
