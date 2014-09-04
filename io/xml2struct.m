function s = xml2struct(xml,varargin)
% xml2struct
% 
% Description:	convert an XML file into a struct
% 
% Syntax:	s = xml2struct(xml,<options>)
%
% In:
%	xml	- an XML file or XML string
%	<options>:
%		collapse:	(false) true to collapse the struct to get rid of 'child'
%					and 'attribute' elements
%		keeptext:	(~<collapse>) true to keep the text elements (the stuff
%					between tags)
% 
% Updated:	2012-12-28
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'collapse'	, false	, ...
		'keeptext'	, []	  ...
		);
opt.keeptext	= unless(opt.keeptext,~opt.collapse);

if FileExists(xml)
	xml	= fget(xml);
end

%split the text
	if opt.keeptext
		cXML	= regexp(xml,'((?<=^|>)[^<]+(?=<))|(<[^>]+>)','match')';
		bTag	= cellfun(@(x) x(1)=='<',cXML);
	else
		cXML	= regexp(xml,'<[^>]+>','match')';
		bTag	= true(size(cXML));
	end
%get the XML preamble
	kTagFirst	= find(bTag,1);
	v			= regexp(cXML{kTagFirst},'(?<=<\?xml\s+version=["]?)[^"]+(?=["]?\?>)','match');
	
	if ~isempty(v)
		v	= str2num(v{1});
		
		cXML(1:kTagFirst)	= [];
		bTag(1:kTagFirst)	= [];
	else
		v	= NaN;
	end
	
	nXML	= numel(cXML);
	
	s	= struct(...
			'element'	, '#document'			, ...
			'attribute'	, struct('version',v)	, ...
			'data'		, []					, ...
			'child'		, struct([])			  ...
			);
%parse all children
	s.child	= ParseChildren(1,nXML);
%optionally collapse
	if opt.collapse
		s	= xmlcollapse(s);
	end

%------------------------------------------------------------------------------%
function c = ParseChildren(kStart,kEnd)
	c	= struct('element',{},'attribute',{},'data',{},'child',{});
	
	kCur	= kStart;
	while kCur<=kEnd
		if bTag(kCur)
		%tag
			%parse the tag
				sOpen	= regexp(cXML{kCur},'^<(?<element>[^\s>]+)(?<attribute>.*?)(?<closing>/>|>)$','names');
				
				if isempty(sOpen)
					error(['XML parse error in "' cXML{kCur} '"']);
				end
				
				attr	= ParseAttribute(sOpen.attribute);
			%parse the element's children
				if isequal(sOpen.closing,'>')
				%has children
					%find the closing tag
						kClose	= FindCell(cXML(kCur:end),['</' sOpen.element '>'],1)+kCur-1;
						
						if isempty(kClose)
							error(['No end tag for line "' cXML{kCur} '"']);
						end
					%parse the children
						if kClose>kCur+1
							child	= ParseChildren(kCur+1,kClose-1);
						else
							child	= struct([]);
						end
					
					kCur	= kClose+1;
				else
				%has no children
					child	= struct([]);
					
					kCur	= kCur+1;
				end
			
			c(end+1).element	= sOpen.element;
			c(end).attribute	= attr;
			c(end).data			= [];
			c(end).child		= child;
		else
		%text
			c(end+1).element	= '#text';
			c(end).attribute	= struct([]);
			c(end).data			= cXML{kCur};
			c(end).child		= struct([]);
			
			kCur	= kCur+1;
		end
	end
end
%------------------------------------------------------------------------------%
function a = ParseAttribute(xml)
	sAttribute	= regexp(xml,'(?<name>[^\s=]+)=["''](?<value>[^"'']*)','names');
	nAttribute	= numel(sAttribute);
	
	if nAttribute==0
		a	= struct([]);
	else
		for kA=1:nAttribute
			a.(sAttribute(kA).name)	= sAttribute(kA).value;
		end
	end
end
%------------------------------------------------------------------------------%

end