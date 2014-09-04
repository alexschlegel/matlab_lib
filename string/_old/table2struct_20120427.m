function s = table2struct(str,varargin)
% table2struct
% 
% Description:	convert an ascii table to a struct.  field names are determined
%				by the first row values unless specified.  each field of struct
%				is an Nx1 array (cell or numeric) of values in the table.
% 
% Syntax:	s = table2struct(str,<options>)
% 
% In:
% 	str	- the ASCII table
%	<option>:
%		delim:				(<tab>) the regexp delimiter between values.  set to
%							"csv" to delimit comma-separated data including
%							double quotes and escaped double quotes.
%		convert_numeric:	(true) true to convert numeric values to double
%							arrays
%		fields:				(<determine from first row values>) if the table is
%							headerless, a cell of field names, one for each
%							column
% 
% Out:
% 	s	- the table as a struct
% 
% Updated: 2012-04-10
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'delim'				, '\t'	, ...
		'convert_numeric'	, true	, ...
		'fields'			, []	  ...
		);

if isequal(lower(opt.delim),'csv')
		%mark open and close quotes
			kQuote					= regexp(str,'(?<!\\)"');
			str(kQuote(1:2:end))	= 1;
			str(kQuote(2:2:end))	= 2;
		%replace commas with escaped commas
			strOld	= '';
			while ~isequal(strOld,str)
				strOld	= str;
				str		= regexprep(str,[1 '([^' 1 2 ']*)(?<!\\),([^' 1 2 ']*)' 2],[1 '$1\\,$2' 2]);
			end
		%remove non-escaped quotes
			str	= regexprep(str,[1 '|' 2],'');
		%convert escaped quotes
			str	= regexprep(str,'(?<!\\)\\"','"');
		
		opt.delim	= '(?<!\\),';
end

%split each row into a cell
	c	= split(str,'[\r\n]+');
%trim each row
	c	= cellfun(@StringTrim,c,'UniformOutput',false);
%remove empty rows
	bRemove		= cellfun(@isempty,c);
	c(bRemove)	= [];
%break each row into entries and replace escaped commas if csv
	c				= cellfun(@(r) split(r,opt.delim,'splitend',true),c,'UniformOutput',false);
	c				= stack(c{:})';
	[nRow,nField]	= size(c);
	
	bFieldManual	= ~isempty(opt.fields);
	if bFieldManual
		cField	= opt.fields;
	else
		cField		= cellfun(@str2fieldname,c(1,:),'UniformOutput',false);
		c		= c(2:end,:);
		nRow	= nRow-1;
	end
	
	cValue	= mat2cell(c,nRow,ones(1,nField));
%delete columns with empty field names
	bEmpty				= cellfun(@isempty,cField);
	cField(bEmpty)		= [];
	cValue(:,bEmpty)	= [];
%delete empty end columns if fields were specified and we have a mismatch
	nFieldSpec	= numel(cField);
	nField		= size(cValue,2);
	if bFieldManual && nFieldSpec~=nField
		bEmptyFirst	= all(cellfun(@isempty,cValue{1}));
		bEmptyLast	= all(cellfun(@isempty,cValue{end}));
		
		bError	= false;
		switch nField-nFieldSpec
			case 1
				if bEmptyFirst
					if bEmptyLast
						bError	= true;
					else
						cValue	= cValue(:,2:end);
					end
				elseif bEmptyLast
					cValue	= cValue(:,1:end-1);
				else
					bError	= true;
				end
			case 2
				if bEmptyFirst & bEmptyLast
					cValue	= cValue(:,2:end-1);
				else
					bError	= true;
				end
			otherwise
				bError	= true;
		end
		
		if bError
			error('Field names don''t match with number of table columns.');
		end
	end
%convert numeric arrays
	if opt.convert_numeric
		bNumeric			= cellfun(@(x) all(cellfun(@isnumstr,x)),cValue);
		cValue(bNumeric)	= cellfun(@str2double,cValue(bNumeric),'UniformOutput',false);
	end
%construct the struct
	s	= cell2struct(cValue,cField,2);
