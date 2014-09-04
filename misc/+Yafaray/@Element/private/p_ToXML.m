function [xml,str] = p_ToXML(e)
% p_ToXML
% 
% Description:	convert the element into an XML struct and string
% 
% Syntax:	[xml,str] = p_ToXML(e)
% 
% Updated: 2012-12-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

xml.element		= e.type;
xml.attribute	= e.attribute;
xml.data		= [];
xml.child		= arrayfun(@p_ToXML,e.child);

%fill in other attributes
	if ~isempty(e.name)
		xml.attribute.name	= e.name;
	end
	
	if ~isempty(e.value)
		[cType,cVal]	= p_ParseValue(e.value);
		nVal			= numel(cVal);
		
		for kV=1:nVal
			xml.attribute.(cType{kV})	= cVal{kV};
		end
	end
%get the string
	if nargout>1
		xmlMain.element		= '#document';
		xmlMain.attribute	= struct([]);
		xmlMain.data		= [];
		xmlMain.child		= xml;
		
		str	= struct2xml(xmlMain,'keeptext',false);
	end
