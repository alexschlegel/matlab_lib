function im = GraphPaper(varargin)
% GraphPaper
% 
% Description:	generate an image of a sheet of graph paper
% 
% Syntax:	im = GraphPaper(<options>)
% 
% In:
% 	<options>:
%		'paper_size':	('letter') a string specifying the size of the output.
%						can be one of the following:
%							'letter':	8.5in. x 11in.
%							'a4':		210mm x 297mm
%		'width':		(8.5 [in.]) width of the paper.  overrides 'paper_size'
%		'height':		(11 [in.]) height of the paper.  overrides 'paper_size'
%		'units':		('in') dimension units.  can be:
%							'in':	inches
%							'mm':	millimeters
%		'margin':		(0.25 [in.]) margin size.  use 'margin_h' and 'margin_v'
%						for different horizontal and vertical margins
%		'dpu':			(300 [dpi]) dots per unit, based on 'units'
%		'cell_size':	(0.25 [in.]) side-length of each cell.  use
%						'cell_size_h' and 'cell_size_v' for different horizontal
%						and vertical side lengths
%		'color':		([0 0 0]) the color of the grid lines
% 
% Out:
% 	im	- the graph paper image
% 
% Updated:	2009-05-09
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%process optional arguments
	opt	= ParseArgs(varargin, ...
			'paper_size'	, 'letter'	, ...
			'units'			, 'in'		, ...
			'color'			, [0 0 0]	  ...
			);
	switch lower(opt.units)
		case 'in'
			opt	= GetDimensions(opt,varargin,1);
		case 'mm'
			opt	= GetDimensions(opt,varargin,25.4);
		otherwise
			error(['"' opt.units '" is not a recognized unit.']);
	end
	
	opt.color	= im2double(opt.color);
	
%initialize the image
	h		= round(opt.height*opt.dpu);
	w		= round(opt.width*opt.dpu);
	bGrid	= NaN(h,w);
	im		= ones(h,w,3);
	
	hOffset	= opt.margin_h*opt.dpu;
	wOffset	= opt.margin_v*opt.dpu;
	
%get the horizontal lines
	hCell	= opt.cell_size_h*opt.dpu;
	yLine	= round(hOffset+1:hCell:min(h,h-hOffset+1));
	
	bGrid(yLine,wOffset+1:min(w,w-wOffset+1))	= 1;
	
%get the vertical lines
	wCell	= opt.cell_size_v*opt.dpu;
	xLine	= round(wOffset+1:wCell:min(w,w-wOffset+1));
	
	bGrid(hOffset+1:min(h,h-hOffset+1),xLine)	= 1;
	
%construct the image
	im				= repmat(bGrid,[1 1 3]) .* repmat(reshape(opt.color,1,1,3),[h w 1]);
	im(isnan(im))	= 1;

%------------------------------------------------------------------------------%
function opt = GetDimensions(opt,vargin,fConvert)
%get the extra dimensions after determining the units.  fConvert is number of
%the given unit per inch
%returns all dimensions in inches
	opt	= StructCombine(opt,ParseArgs(vargin	, ...
			'width'			, []				, ...
			'height'		, []				, ...
			'margin'		, 0.25*fConvert		, ...
			'dpu'			, 300*fConvert		, ...
			'cell_size'		, 0.25*fConvert		  ...
			));
	opt	= StructCombine(opt,ParseArgs(vargin	, ...
			'margin_h'		, opt.margin		, ...
			'margin_v'		, opt.margin		, ...
			'cell_size_h'	, opt.cell_size		, ...
			'cell_size_v'	, opt.cell_size		  ...
			));
	if isempty(opt.width) switch lower(opt.paper_size)
		case 'letter'
			opt.width	= 8.5;
		case 'a4'
			opt.width	= 210/25.4;
		otherwise
			error(['"' opt.paper_size '" is not a recognized paper size.']);
	end; end
	if isempty(opt.height) switch lower(opt.paper_size)
		case 'letter'
			opt.height	= 11;
		case 'a4'
			opt.width	= 297/25.4;
	end; end
%------------------------------------------------------------------------------%
