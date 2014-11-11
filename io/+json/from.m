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
% Updated: 2014-10-17
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%remove line feeds and tabs
	str	= regexprep(str,'[\n\t]','');
%escape special characters within strings
	str	= EscapeInString(str);
%make sure we have valid field names
	str	= ValidFieldNames(str);
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
			
			str	= [str(1:kStart-1) regexprep(str(kStart:kEnd),'([{}\[\]:])','\\$1') str(kEnd+1:end)];
		end
end
%------------------------------------------------------------------------------%
function str = ValidFieldNames(str)
	%find the field specifiers
		kField	= regexp(str,[nonesc('"') nonesc(':')]);
		nField	= numel(kField);
	
	for kF=1:nField
		kEnd	= kField(kF) - 2;
		kStart	= regexp(str(1:kEnd),nonesc('"'));
		kStart	= kStart(end) + 1;
		
		strFieldOld	= str(kStart:kEnd);
		strFieldNew	= str2fieldname(strFieldOld);
		if ~strcmp(strFieldOld,strFieldNew)
			str	= [str(1:kStart-1) strFieldNew str(kEnd+1:end)];
			kField	= kField + numel(strFieldNew) - numel(strFieldOld);
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
