function [cStr,sMarkup] = ParseSimpleMarkup(str,varargin)
% ParseSimpleMarkup
% 
% Description:	parse a string with markup of the form <label:value>...</label>.
%				< and > in the text must be escaped as \< and \>.  each label
%				must be MATLAB fieldname compatible.  new lines can be indicated
%				with the string '\n' and will be output as entries on their own.
% 
% Syntax:	[cStr,sMarkup] = ParseSimpleMarkup(str,<options>)
% 
% In:
% 	str		- a string formatted with markup
%	sMarkup	- a struct of markup already applied to str
%	<options>:
%		default:	(struct) a struct of default markup
% 
% Out:
% 	cStr	- a cell of substrings with different markup
%	sMarkup	- a struct of arrays with one entry for each string in cStr and
%			  fields denoting the markup applied to each substring
% 
% Updated: 2015-03-06
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'default'	, struct	  ...
		);

%get rid of line breaks
	str	= regexprep(str,'[\r\n]','');
%isolate new lines
	str	= regexprep(str,'\\n','<psmnewline:true>\\n</psmnewline>');

nStr	= numel(str);

%assign styles to each character in the string
	[sBlock,kBlockStart,kBlockEnd]	= regexp(str,'(?<!\\)<(?<label>[^/][^:]*):(?<value>[^>]+)>','names','start','end');
	nBlock							= numel(sBlock);
	
	kStyle	= repmat({[]},nStr,1);
	
	for kB=nBlock:-1:1
		%find the end of the block
			[kEndStart,kEndEnd]	= regexp(str(kBlockEnd(kB)+1:end),['(?<!\\)</' sBlock(kB).label '>'],'start','end');
			kEndStart	= kBlockEnd(kB) + kEndStart;
			kEndEnd		= kBlockEnd(kB) + kEndEnd;
		%assign this block
			kBlock			= kBlockEnd(kB)+1:kEndStart-1;
			kStyle(kBlock)	= cellfun(@(x) [x; kB],kStyle(kBlock),'UniformOutput',false);
		%delete the markup
			kMarkup			= [kBlockStart(kB):kBlockEnd(kB) kEndStart:kEndEnd];
			str(kMarkup)	= [];
			kStyle(kMarkup)	= [];
	end
%break up the string into blocks of the same format
	if numel(str)>0
		kEnd	= [find(cellfun(@(x1,x2) ~isequal(x1,x2),kStyle(1:end-1),kStyle(2:end))); numel(str)];
		kStart	= [1; kEnd(1:end-1)+1];
	else
		[kEnd,kStart]	= deal([]);
	end
	nBlock	= numel(kEnd);
	
	cStr	= arrayfun(@(ks,ke) str(ks:ke),kStart,kEnd,'UniformOutput',false);
	
	sMarkup	= repmat(opt.default,[nBlock 1]);
	for kB=1:nBlock
		kStyleCur	= kStyle{kStart(kB)};
		nStyle		= numel(kStyleCur);
		
		for kS=nStyle:-1:1
			sMarkup(kB).(sBlock(kStyleCur(kS)).label)	= sBlock(kStyleCur(kS)).value;
		end
	end
%eliminate empty blocks
	bDelete				= cellfun(@isempty,cStr);
	cStr(bDelete)		= [];
	sMarkup(bDelete)	= [];
%restructure the struct
	sMarkup	= restruct(sMarkup);
	sMarkup	= structfun2(@(x) conditional(ischar(x),{x},x),sMarkup);
%get rid of the newline format
	sMarkup	= RmFieldPath(sMarkup,'psmnewline');
