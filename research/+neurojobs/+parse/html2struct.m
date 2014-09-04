function s = html2struct(html)
% neurojobs.parse.html2struct
% 
% Syntax:	s = neurojobs.parse.html2struct(html)
% 
% Updated: 2014-08-02
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
switch class(html)
	case 'org.jsoup.select.Elements'
		nElement	= html.size;
		
		s	= cell(nElement,1);
		for kE=1:nElement
			s{kE}	= ParseNode(html.get(kE-1));
		end
		
		s	= cat(1,s{:});
	otherwise
		s	= ParseNode(html);
end

%------------------------------------------------------------------------------%
function s = ParseNode(node)
	s		= struct;
	
	%node properties
		s.name	= char(node.tagName);
		s.attr	= ParseAttributes(node);
		s.text	= char(node.ownText);
	
	%children
		chillen	= node.children;
		nChild	= chillen.size;
		
		s.child	= cell(nChild,1);
		for kC=1:nChild
			child	= chillen.get(kC-1);
			
			s.child{kC}	= ParseNode(child);
		end
		
		s.child	= cat(1,s.child{:});
end
%------------------------------------------------------------------------------%
function s = ParseAttributes(node)
	s	= struct;
	
	attribs	= node.attributes.asList;
	nAttr	= attribs.size;
	
	for kA=0:nAttr-1
		attr	= attribs.get(kA);
		key		= str2fieldname(char(attr.getKey));
		val		= char(attr.getValue);
		
		switch key
			case 'class'
				val	= split(val,'\s+');
		end
		
		s.(key)	= val;
	end
end
%------------------------------------------------------------------------------%

end
