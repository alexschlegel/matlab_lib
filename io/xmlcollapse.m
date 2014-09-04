function s = xmlcollapse(s,varargin)
% xmlcollapse
% 
% Description:	collapse an XML struct parsed with xml2struct
% 
% Syntax:	s = xmlcollapse(s)
% 
% Updated: 2012-12-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent cFieldUncollapsed

if isempty(cFieldUncollapsed)
	cFieldUncollapsed	=	{
								'attribute'
								'child'
								'data'
								'element'
							};
end

if (nargin>1 && varargin{1}==false) || isequal(sort(fieldnames(s)),cFieldUncollapsed)
	%remove data if it's empty
		if isstruct(s) && isfield(s,'data') && isempty(s.data)
			s	= rmfield(s,'data');
		end
		
	s	= CollapseAttribute(s);
	s	= CollapseChildren(s);
	
	if isfield(s,'element') && isequal(s.element,'#document')
		s	= rmfield(s,'element');
	end
end

%------------------------------------------------------------------------------%
function s = CollapseAttribute(s)
	attrib	= s.attribute;
	s		= rmfield(s,'attribute');
	
	cField	= fieldnames(attrib);
	nField	= numel(cField);
	
	for kF=1:nField
		s.(cField{kF})	= attrib.(cField{kF});
	end
end
%------------------------------------------------------------------------------%
function s = CollapseChildren(s)
	child	= s.child;
	s		= rmfield(s,'child');
	
	nChild	= numel(child);
	
	for kC=1:nChild
		strElement	= str2fieldname(child(kC).element);
		childCur	= rmfield(child(kC),'element');
		
		if isfield(s,strElement)
			s.(strElement)	= structadd(s.(strElement),xmlcollapse(childCur,false));
		else
			s.(strElement)	= xmlcollapse(childCur,false);
		end
	end
end
%------------------------------------------------------------------------------%

end
