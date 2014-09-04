function subnode = extract(node,query,varargin)
% neurojobs.parse.extract
% 
% Description:	extract a subnode based on a query
% 
% Syntax:	subnode = neurojobs.parse.extract(node,query,<options>)
% 
% In:
%	node	- the jsoup node
% 	query	- the query to extract based on
%	<options>:
%		type:	('class') the type of query to perform. one of the following:
%					title:	find a node with the specified title
%					class:	find a node with the specified class
%					text:	find a node with the specified text
%					tag:	find nodes of the specified tags
%					attr:	find nodes with attribute matching the specified
%							query (use attr option)
%		attr:	('') use for the 'attr' type
%		tag:	(<all>) limit results to the specified tag(s)
%		return:	('elements') what to return. one of the following:
%					elements:	the Elements object
%					text:		the text of the results
%					href:		the href attribute
%					html:		the html string
% 
% Updated: 2014-08-02
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'type'		, 'class'		, ...
		'attr'		, ''			, ...
		'tag'		, {}			, ...
		'return'	, 'elements'	  ...
		);

if isequal(class(node),'org.jsoup.select.Elements')
	nElement	= node.size;
	
	if nElement==0
		subnode	= [];
	else
		subnode	= cell(nElement,1);
		
		for kE=1:nElement
			subnode{kE}	= neurojobs.parse.extract(node.get(kE-1),query,varargin{:});
		end
		
		switch opt.return
			case 'elements'
				for kE=2:nElement
					subnode{1}.addAll(subnode{kE});
				end
				
				subnode	= subnode{1};
			otherwise
				subnode	= cat(1,subnode{:});
		end
	end
	
	return;
end

%get the subnodes
	switch opt.type
		case 'title'
			subnode	= node.getElementsByAttributeValueMatching('title',query);
		case 'class'
			subnode	= node.getElementsByAttributeValueMatching('class',query);
		case 'text'
			subnode	= node.getElementsMatchingText(query);
		case 'tag'
			subnode	= node.getElementsByTag(query);
		case 'attr'
			subnode	= node.getElementsByAttributeValueMatching(opt.attr,query);
		otherwise
			error(sprintf('%s is not a valid query type.',opt.type));
	end

%keep only the specified tags
	if ~isempty(opt.tag)
		cTag	= ForceCell(opt.tag);
		
		kE=0;
		while kE<subnode.size
			strTag	= char(subnode.get(kE).tagName);
			
			if ~ismember(strTag,cTag)
				subnode.remove(kE);
			else
				kE	= kE+1;
			end
		end
	end

%return the requested data
	nNode	= subnode.size;
	
	switch opt.return
		case 'elements'
			%nothing to do
		case 'text'
			cText	= cell(nNode,1);
			for kN=1:nNode
				cText{kN}	= char(subnode.get(kN-1).ownText);
			end
			
			subnode	= cText;
		case 'href'
			cHref	= cell(nNode,1);
			
			for kN=1:nNode
				cHref{kN}	= char(subnode.get(kN-1).attr('href'));
			end
			
			subnode	= cHref;
		case 'html'
			cHref	= cell(nNode,1);
			
			for kN=1:nNode
				cHref{kN}	= char(subnode.get(kN-1).html);
			end
			
			subnode	= cHref;
		otherwise
			error(sprintf('%s is not a valid return specified.',opt.return));
	end
