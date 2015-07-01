function x = from(str)
% json.from
% 
% Description:	convert a JSON string to a MATLAB variable
% 
% Syntax:	x = json.from(str)
% 
% In:
% 	str	- a previously-encoded JSON string
% 
% Out:
% 	x	- the MATLAB variable form of str
% 
% Updated: 2015-07-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

chrSpecialFrom	= '{}[]:';
chrSpecialTo	= 1:numel(chrSpecialFrom);

%remove line feeds and tabs
	str	= regexprep(str,'[\n\t]','');
%temporarily replace escaped backslashes because they might cause problems
	str	= regexprep(str,'\\\\','ALEXWUZHERENOHEWASNT');
%hide special characters within strings
	str	= HideSpecialCharacters(str);
%make sure we have valid field names
	str	= ValidFieldNames(str);
%single quotes to double single quotes
	str	= regexprep(str,'''','''''');
%non-escaped double quotes to single quotes
	str	= regexprep(str,nonesc('"'),'''');
%escaped double quotes to double quotes
	str	= regexprep(str,'\\"','"');
%objects to structs
	str	= regexprep(str,'{','struct(');
	str	= regexprep(str,'}',')');
	str	= regexprep(str,':',',');
%arrays to cells (double because of the annoying struct() cell thing)
	str	= regexprep(str,'[','{{');
	str	= regexprep(str,']','}}');
%restore escaped backslashes
	str	= regexprep(str,'ALEXWUZHERENOHEWASNT','\\\\');
%restore special characters within strings
	str	= RestoreSpecialCharacters(str);
%convert to a variable
	x	= serialize.from(str);

%simplify stuff
	x	= from_simplify(x);

%------------------------------------------------------------------------------%
function str = HideSpecialCharacters(str)
	%find the non-escaped double quotes
		kQuote	= regexp(str,nonesc('"'));
		nQuote	= numel(kQuote);
	
	%get the characters that are between quotes
		kQuoteStart	= kQuote(1:2:nQuote)+1;
		kQuoteEnd	= kQuote(2:2:nQuote)-1;
		
		kInQuote	= arrayfun(@(s,e) s:e,kQuoteStart,kQuoteEnd,'uni',false);
		kInQuote	= cat(2,kInQuote{:});
		
		strInQuote	= str(kInQuote);
	
	%hide special characters in this set
		[bSpecial,kChar]	= ismember(strInQuote,chrSpecialFrom);
		kCharSpecial		= kChar(bSpecial);
		
		strInQuote(bSpecial)	= chrSpecialTo(kCharSpecial);
	
	%insert the hidden version back into the string
		str(kInQuote)	= strInQuote;
end
%------------------------------------------------------------------------------%
function str = RestoreSpecialCharacters(str)
	%find the hidden characters
		[bSpecial,kChar]	= ismember(str,chrSpecialTo);
		kCharSpecial		= kChar(bSpecial);
	
	%restore them
		str(bSpecial)	= chrSpecialFrom(kCharSpecial);
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
