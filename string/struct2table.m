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
%		heading:	(<auto>) a cell specifying the heading for each column. set
%					to false to skip headings
%		delim:		(9) the delimiter between entries, or 'csv' or 'tsv' for
%					comma/tab separated variable format
% 
% Out:
% 	str	- the ASCII table
% 
% Updated: 2012-04-28
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'heading'	, fieldnames(s)	, ...
		'delim'		, 9				  ...
		);

c	= struct2cell(s);

%convert numeric arrays to cells of strings
	bNumeric	= ~cellfun(@iscell,c);
	c(bNumeric)	= cellfun(@(x) arrayfun(@num2str,x,'UniformOutput',false),c(bNumeric),'UniformOutput',false);
%make sure the rest are strings
	bCheck		= ~bNumeric;
	kCheck		= find(bCheck);
	nCheck		= numel(kCheck);
	
	bToString	= cellfun(@(x) ~cellfun(@ischar,x),c(bCheck),'UniformOutput',false);
	
	for kC=1:nCheck
		c{kCheck(kC)}(bToString{kC})	= cellfun(@tostring,c{kCheck(kC)}(bToString{kC}),'UniformOutput',false);
	end
%concatenate
	c	= cat(2,c{:});
%escape quotes/surround in quotes if we're doing csv or tsv
	if isequal(opt.delim,'csv') || isequal(opt.delim,'tsv')
		c	= cellfun(@(x) ['"' strrep(x,'"','\"') '"'],c,'UniformOutput',false);
		
		opt.heading	= cellfun(@(x) ['"' strrep(x,'"','\"') '"'],opt.heading,'UniformOutput',false);
	end
%add the line breaks
	c(:,end)	= cellfun(@(x) [x 10],c(:,end),'UniformOutput',false);
%add the delimiter
	opt.delim	= switch2(opt.delim,...
					'csv'	, ','		, ...
					'tsv'	, char(9)	, ...
					opt.delim);
	
	c(:,1:end-1)	= cellfun(@(x) [x opt.delim],c(:,1:end-1),'UniformOutput',false);
%concatenate!
	c	= reshape(c',[],1);
	str	= cat(2,c{:});
%add the headings!
	if notfalse(opt.heading)
		str	= [join(opt.heading,opt.delim) 10 str];
	end
