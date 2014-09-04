function str = to(x)
% json.to
% 
% Description:	encode a variable in JSON format
% 
% Syntax:	str = json.to(x)
% 
% In:
% 	x	- a variable that can be encoded in JSON, meaning that it consists only
%		  of structs, arrays, strings, numbers, and logicals, and NaNs. note
%		  that cells may be converted back into numerical arrays.
% 
% Out:
% 	str	- a JSON encoding of x
% 
% Updated: 2014-02-14
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

if isscalar(x)
	switch class(x)
		case 'char'
			str	= to_char(x);
		case 'logical'
			str	= conditional(x,'true','false');
		case 'cell'
			str	= json.to(x{1});
		case 'struct'
			cField	= fieldnames(x);
			cStr	= cellfun(@(f) sprintf('\t"%s": %s',f,regexprep(json.to(x.(f)),'[\t\n]','')),cField,'uni',false);
			str		= sprintf('{\n%s\n}',join(cStr,[',' 10]));
		otherwise
			if isnumeric(x)
				if isnan(x)
					str	= 'null';
				else
					str	= num2str(x);
				end
			else
				error('Inputs of type %s are not JSON serializable.',class(x));
			end
	end
elseif ischar(x)
	str	= to_char(x);
else
	sz	= size(x);
	nd	= numel(sz);
	
	if sz(1)>1
		cStr	= cell(sz(1),1);
		cSubs	= repmat({':'},[1 nd-1]);
		
		for k=1:sz(1)
			xSub	= squeeze(x(k,cSubs{:}));
			cStr{k}	= json.to(xSub);
			
			if isscalar(xSub)
				cStr{k}	= sprintf('[ %s ]',cStr{k});
			end
		end
	else
		cStr	= arrayfun(@json.to,x,'uni',false);
	end
	
	str	= sprintf('[ %s ]',join(cStr,', '));
end

%------------------------------------------------------------------------------%
function str = to_char(x)
	str	= sprintf('"%s"',strrep(x,'"','\"'));
end
%------------------------------------------------------------------------------%

end
