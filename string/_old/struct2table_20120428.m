function str = struct2table(s,varargin)
% struct2table
% 
% Description:	convert a struct to an ascii table.  field names are stored as
%				the first row values unless specified in the 'heading' options.
%				each field of struct must be an Nx1 array (cell or numeric) of
%				values
% 
% Syntax:	b = struct2table(s,<options>)
% 
% In:
% 	s			- a struct array
%	strPathXLS	- the output path
%	<options>:
%		heading:	(<auto>) a cell specifying the heading for each column
%		delim:		(9) the delimiter between entries, or 'csv' for comma
%					separated variable format
% 
% Out:
% 	str	- the ASCII table
% 
% Updated: 2012-04-28
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'heading'	, []	, ...
		'delim'		, 9		  ...
		);

cField	= fieldnames(s);
nField	= numel(cField);

opt.heading	= unless(opt.heading,cField);

cData	= cellfunprogress(@(x) reshape(ToCell(s.(x)),[],1),cField,'UniformOutput',false,'label','cellifying');
nMax	= max(cellfun(@numel,cData));
cData	= cellfun(@(x) [x; repmat({NaN},[nMax - numel(x) 1])],cData,'UniformOutput',false);

cTable	= cellfun(@(d,f) [{f}; d],cData,cField,'UniformOutput',false);

switch opt.delim
	case 'csv'
		str		= join(cellfunprogress(@(varargin) ['"' join(cellfun(@(s) strrep(tostring(s),'"','\"'),varargin,'UniformOutput',false),'","') '"'],cTable{:},'UniformOutput',false,'label','joining data'),10);
	otherwise
		str		= join(cellfunprogress(@(varargin) join(varargin,opt.delim),cTable{:},'UniformOutput',false,'label','joining data'),10);
end

%------------------------------------------------------------------------------%
function x = ToCell(x)
	if ~iscell(x)
		x	= num2cell(x);
	end
	
	x	= cellfun(@tostring,x,'UniformOutput',false);
end
%------------------------------------------------------------------------------%

end