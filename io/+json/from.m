function x = from(str,varargin)
% json.from
% 
% Description:	convert a JSON string to a MATLAB variable
% 
% Syntax:	x = json.from(str,<options>)
% 
% In:
% 	str	- a previously-encoded JSON string
%	<options>:
%		checkquotes:		(true) true to check for special characters within
%							strings
%		checkfieldnames:	(true) true to check for valid field names
% 
% Out:
% 	x	- the MATLAB variable form of str
% 
% Updated: 2015-01-11
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'checkquotes'		, true	, ...
		'checkfieldnames'	, true	  ...
		);

%remove line feeds and tabs
	str	= regexprep(str,'[\n\t]','');
%escape special characters within strings
	if opt.checkquotes
		str	= EscapeInString(str);
	end
%make sure we have valid field names
	if opt.checkfieldnames
		str	= ValidFieldNames(str);
	end
%single quotes to double single quotes
	str	= regexprep(str,'''','''''');
%non-escaped double quotes to single quotes
	str	= regexprep(str,nonesc('"'),'''');
%escaped double quotes to double quotes
	str	= regexprep(str,'\\"','"');
%objects to structs
	str	= regexprep(str,nonesc('{'),'struct(');
	str	= regexprep(str,nonesc('}'),')');
	str	= regexprep(str,nonesc(':'),',');
%arrays to cells (double because of the annoying struct() cell thing)
	str	= regexprep(str,nonesc('['),'{{');
	str	= regexprep(str,nonesc(']'),'}}');
%unescape special characters within strings
	str	= regexprep(str,'\\([{}\[\]:])','$1');
%convert to a variable
	x	= serialize.from(str);

%simplify stuff
	x	= from_simplify(x);

%------------------------------------------------------------------------------%
function str = EscapeInString(str)
	%find the non-escaped double quotes
		kQuote	= regexp(str,nonesc('"'));
		nQuote	= numel(kQuote);
		
		for kQ=1:2:nQuote
			kStart	= kQuote(kQ) + 1;
			kEnd	= kQuote(kQ+1) - 1;
			
			strOrig	= str(kStart:kEnd);
			strNew	= regexprep(strOrig,'([{}\[\]:])','\\$1');
			
			nOrig	= numel(strOrig);
			nNew	= numel(strNew);
			
			if nOrig==nNew
				str(kStart:kEnd)	= strNew;
			else
				str	= [str(1:kStart-1) strNew str(kEnd+1:end)];
				
				kQuote(kQ+2:end)	= kQuote(kQ+2:end) + nNew - nOrig;
			end
		end
end
%------------------------------------------------------------------------------%
function str = ValidFieldNames(str)
	%find the field specifiers
		pat		= sprintf('(%s)\\s*(%s)',nonesc('"'),nonesc(':'));
		kField	= regexp(str,pat);
		nField	= numel(kField);
	
	for kF=1:nField
		kEnd	= kField(kF) - 1;
		
		kStart	= kEnd;
		while str(kStart)~='"'
			kStart	= kStart - 1;
		end
		kStart	= kStart + 1;
		
		strFieldOld	= str(kStart:kEnd);
		strFieldNew	= str2fieldname(strFieldOld);
		if ~strcmp(strFieldOld,strFieldNew)
			nOld	= numel(strFieldOld);
			nNew	= numel(strFieldNew);
			
			if nOld==nNew
				str(kStart:kEnd)	= strFieldNew;
			else
				str	= [str(1:kStart-1) strFieldNew str(kEnd+1:end)];
				
				kField(kF:end)	= kField(kF:end) + nNew - nOld;
			end
		end
	end
end
%------------------------------------------------------------------------------%
function re = nonesc(chr)
	re	= sprintf('^%s|(?<=[^\\\\])%s',chr,chr);
end
%------------------------------------------------------------------------------%
function x = from_simplify(x)
	switch class(x)
		case 'struct'
			cField	= fieldnames(x);
			nField	= numel(cField);
			
			for kF=1:nField
				x.(cField{kF})	= from_simplify(x.(cField{kF}));
			end
		case 'cell'
			if isscalar(x) && iscell(x{1})
				x	= from_simplify(x{1});
			elseif isempty(x)
				x	= [];
			else
				x	= cellfun(@from_simplify,x,'uni',false);
				
				sz	= cellfun(@size,x,'uni',false);
				cls	= cellfun(@class,x,'uni',false);
				if uniform(sz) && uniform(cls) && (~all(strcmp(cls,'struct')) || uniform(cellfun(@fieldnames,x,'uni',false)))
					if size(x{1},1)>1
						x	= cellfun(@(x) permute(x,[numel(x)+1 1:numel(x)]),x,'uni',false);
					end
					
					x	= cat(1,x{:});
				end
			end
		otherwise
	end
end
%------------------------------------------------------------------------------%

end
