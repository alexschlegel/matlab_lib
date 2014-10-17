function [s,cHeading] = table2struct(str,varargin)
% table2struct
% 
% Description:	convert an ascii table to a struct.  field names are determined
%				by the first row values unless specified.  each field of struct
%				is an Nx1 array (cell or numeric) of values in the table.
% 
% Syntax:	[s,cHeading] = table2struct(str,<options>)
% 
% In:
% 	str	- the ASCII table
%	<option>:
%		delim:				(<tab>) the regexp delimiter between values.  can
%							also be one of the following:
%								'csv': delimit comma-separated data including
%									double quotes and escaped double quotes
%								'tsv': like 'csv' but with tabs instead of commas
%		convert_numeric:	(true) true to convert numeric values to double
%							arrays
%		fields:				(<determine from first row values>) if the table is
%							headerless, a cell of field names, one for each
%							column
% 
% Out:
% 	s			- the table as a struct
%	cHeading	- the original headings
% 
% Updated: 2013-01-11
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'delim'				, '\t'	, ...
		'convert_numeric'	, true	, ...
		'fields'			, []	  ...
		);

bReplaceEscape	= false;
switch lower(opt.delim)
	case 'csv'
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
			str(str==1 | str==2)	= [];
		%convert escaped quotes
			%find escaped quotes
				kEsc	= strfind(str,'\"');
			%remove escaped escaped quotes
				kEscEsc	= strfind(str,'\\"')+1;
			
			str(setdiff(kEsc,kEscEsc))	= [];
		%convert escaped escaped quotes
			str(strfind(str,'\\"'))	= [];
		
		opt.delim	= '(?<!\\),';
		
		bReplaceEscape	= true;
		strEscapeFrom	= '\,';
		strEscapeTo		= ',';
	case 'tsv'
		%mark open and close quotes
			kQuote					= regexp(str,'(?<!\\)"');
			str(kQuote(1:2:end))	= 1;
			str(kQuote(2:2:end))	= 2;
		%replace tabs with escaped tabs
			strOld	= '';
			while ~isequal(strOld,str)
				strOld	= str;
				str		= regexprep(str,[1 '([^' 1 2 ']*)(?<!\\)' 9 '([^' 1 2 ']*)' 2],[1 '$1\\' 9 '$2' 2]);
			end
		%remove non-escaped quotes
			str	= regexprep(str,[1 '|' 2],'');
		%convert escaped quotes
			str	= regexprep(str,'(?<!\\)\\"','"');
		
		opt.delim	= ['(?<!\\)' 9];
		
		bReplaceEscape	= true;
		strEscapeFrom	= ['\' 9];
		strEscapeTo		= char(9);
end

%get the number of columns from the first line
	kFirstLine	= find(str==13 | str==10,1);
	if isempty(kFirstLine)
		kFirstLine	= numel(str)+1;
	end
	
	nColumn		= numel(regexp(str(1:kFirstLine-1),opt.delim))+1;
%collapse the table
	%get an example of a delimiter
		strDelim	= regexp(str,opt.delim,'match','once');
	
	
	while str(end)==13 || str(end)==10
		str(end)	= [];
	end
		
	str	= strrep(str,char([13 10]),strDelim);
	str	= strrep(str,char([13]),strDelim);
	str	= strrep(str,char([10]),strDelim);
%replace escaped characters
	if bReplaceEscape
		kDelim		= strfind(str,strEscapeTo);
		kEscaped	= strfind(str,strEscapeFrom);
		
		kReplace		= setdiff(kDelim,kEscaped+1);
		str(kReplace)	= 3;
		opt.delim		= char(3);
		
		str			= strrep(str,strEscapeFrom,strEscapeTo);
	end
%split into cells
	c	= split(str,opt.delim,'splitend',true);
%get the field names
	bFieldManual	= ~isempty(opt.fields);
	if bFieldManual
		[cHeading,cField]	= deal(opt.fields);
	else
		cHeading	= c(1:nColumn);
		cField		= cellfun(@str2fieldname,cHeading,'UniformOutput',false);
		c			= c(nColumn+1:end);
	end
%split into columns
	c		= reshape(c,nColumn,[])';
	cValue	= mat2cell(c,size(c,1),ones(1,nColumn));
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
		cValue	= cellfun(@col2num,cValue,'uni',false);
	end
%construct the struct
	s	= cell2struct(cValue,cField,2);

%------------------------------------------------------------------------------%
function x = col2num(c)
	x	= sscanf(sprintf('%s#', c{:}), '%g#');
	
	if numel(x) ~= numel(c)
		x	= c;
	else
		x	= reshape(x,size(c));
	end
% 	n	= numel(c);
% 	x	= zeros(n,1);
	
% 	for k=1:n
% 		x(k)	= str2double(c{k});
		
% 		if isnan(x(k)) && ~strcmp(lower(c{k}),'nan')
% 			x	= c;
% 			return;
% 		end
% 	end
end
%------------------------------------------------------------------------------%

end
