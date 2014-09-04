function x = LoadFromExcelTable(strPathMAT,varargin)
% LoadFromExcelTable
% 
% Description:	load a MAT file that has been saved from the Excel MATLAB addin
% 
% Syntax:	c = LoadFromExcelTable(strPathMAT,[valNaN]='')
% 
% In:
% 	strPathMAT	- the path to a .mat file containing a singles variable that
%				  represents a table in Excel (i.e. the first row of the cel
%				  should be the heading of the table)
%	[valNaN]	- convert NaNs to this value
% 
% Out:
% 	x	- a structure of arrays in the following form:
%			.Heading1 = {row1column1; row2column1; ...; rowNcolumn1}
%			...
%			.HeadingM = {row1columnM; row2columnM; ...; rowNcolumnM}
% 
% Updated:	2008-06-19
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
valNaN	= ParseArgs(varargin,'');


%load the cell into c
	c	= load(strPathMAT);
	fn	= fieldnames(c);
	c	= c.(fn{1});

%make the cell a cell of values rather than a cell of cells
%also convert NaNs to ''
	for k=1:numel(c)
		if iscell(c{k})
			c{k}	= c{k}{1};
		end
		if isnan(c{k})
			c{k}	= valNaN;
		end
	end

%get the headings and initialize the struct
	nRow	= size(c,1) - 1;
	nCol	= size(c,2);
	
	x	= struct;
	for kCol=1:nCol
		fn		= str2fieldname(c{1,kCol});
		x.(fn)	= c(2:end,kCol);
	end
