function xml = struct2xml(s,varargin)
% struct2xml
% 
% Description:	convert a struct tree to an xml string
% 
% Syntax:	xml = struct2xml(s,<options>)
% 
% In:
% 	s	- a nested struct
%	<options>:
%		keeptext:	(true) true to keep the text defined in #text elements
% 
% Out:
% 	str	- the struct as an xml string
% 
% Updated: 2012-12-28
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

opt	= ParseArgs(varargin,...
		'keeptext'	, true	  ...
		);

%parse each element
	if isequal(sort(fieldnames(s)),cFieldUncollapsed)
		xml	= S2X_Full(s);
	else
		xml	= S2X_Collapsed(s);
	end
%combine into a string
	if opt.keeptext
		xml	= ['<?xml version="1.0"?>' 10 join(xml,'')];
	else
		xml	= ['<?xml version="1.0"?>' 10 join(xml,10)];
	end
	
%------------------------------------------------------------------------------%
function [xml,aName,aVal] = S2X_Full(s)
	aName			= fieldnames(s.attribute);
	aVal			= struct2cell(s.attribute);
	bToChar			= ~cellfun(@ischar,aVal);
	
	if any(bToChar)
		x=1;
	end
	
	aVal(bToChar)	= cellfun(@tostring,aVal(bToChar),'UniformOutput',false);
	
	nChild	= numel(s.child);
	
	xml	= {};
	for kC=1:nChild
		bText	= isequal(s.child(kC).element,'#text');
		if opt.keeptext && bText
			xml{end+1}	= s.child(kC).data;
		elseif ~bText
			[child,aNameChild,aValChild]	= S2X_Full(s.child(kC));
			
			nAttribute	= numel(aNameChild);
			if nAttribute>0
				aChild	= cell(nAttribute,1);
				for kA=1:nAttribute-1
					aChild{kA}	= [aNameChild{kA} '="' aValChild{kA} '" '];
				end
				aChild{end}	= [aNameChild{end} '="' aValChild{end} '"'];
				
				aChild	= cat(2,aChild{:});
			else
				aChild	= '';
			end
			
			if ~isempty(child)
				if opt.keeptext
					xml(end+(1:3))	=	{
											['<' s.child(kC).element conditional(isempty(aChild),'',' ') aChild '>']
											child
											['</' s.child(kC).element '>']
										};
				else
					xml(end+(1:3))	=	{
											['<' s.child(kC).element conditional(isempty(aChild),'',' ') aChild '>']
											cellfun(@(x) [9 x],child,'UniformOutput',false)
											['</' s.child(kC).element '>']
										};
				end
			else
				xml{end+1}	= ['<' s.child(kC).element ' ' aChild '/>'];
			end
		end
	end
end
%------------------------------------------------------------------------------%
function [xml,aName,aVal] = S2X_Collapsed(s)
	cField	= fieldnames(s);
	nField	= numel(cField);
	
	[xml,aName,aVal]	= deal({});
	for kF=1:nField
		if isstruct(s.(cField{kF}))
		%child
			nStruct	= numel(s.(cField{kF}));
			
			for kS=1:nStruct
				[child,aNameChild,aValChild]	= S2X_Collapsed(s.(cField{kF})(kS));
				
				nAttribute	= numel(aNameChild);
				if nAttribute>0
					aChild	= cell(nAttribute,1);
					for kA=1:nAttribute-1
						aChild{kA}	= [aNameChild{kA} '="' aValChild{kA} '" '];
					end
					aChild{end}	= [aNameChild{end} '="' aValChild{end} '"'];
					
					aChild	= cat(2,aChild{:});
				else
					aChild	= '';
				end
				
				if ~isempty(child)
					xml	=	[	xml
								['<' cField{kF} conditional(isempty(aChild),'',' ') aChild '>']
								cellfun(@(x) [9 x],child,'UniformOutput',false)
								['</' cField{kF} '>']
							];
				else
					xml	= 	[	xml
								['<' cField{kF} ' ' aChild '/>']
							];
				end
			end
		elseif ~isempty(s.(cField{kF}))
			aName{end+1}	= cField{kF};
			aVal{end+1}		= s.(cField{kF});
		end
	end
end
%------------------------------------------------------------------------------%

end
