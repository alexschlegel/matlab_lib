function rgb = rgbRead(varargin)
% RGBREAD
% 
% Description:	reads in an image and converts it to double
% 
% Syntax:	rgb = rgbRead([cPath]=(prompt),<options>)
%
% In:
%	[cPath]	- the path to the image file, or a cell of such
%	<options>:
%		return:		('matrix' if one path is passed, 'cell otherwise) 'matrix'
%					to return a HxWx<nPlane>xN array of images (assumes all images are
%					the same size).  'cell' to return each image as an entry in
%					a cell
%		progress:	(false) true to show progress
% 
% Out:
%	rgb	- see the 'return' option
%
% Updated:	2010-04-17
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[cPath,opt]	= ParseArgs(varargin,[],...
					'return',	[]		, ...
					'progress',	false	  ...
					);

if isempty(cPath)
	cPath	= PromptFileGet(cPath,[],'Choose an Image');
	
	if isequal(cPath,0)
		rgb	= [];
		return;
	end
end

cPath	= ForceCell(cPath);
nPath	= numel(cPath);

if isempty(opt.return)
	switch nPath
		case 1
			opt.return	= 'matrix';
		otherwise
			opt.return	= 'cell';
	end
end

if opt.progress
	rgb	= cellfunprogress(@(x) im2double(imread(x)),cPath,'label','Loading Image','UniformOutput',false);
else
	rgb	= cellfun(@(x) im2double(imread(x)),cPath,'UniformOutput',false);
end

switch opt.return
	case 'matrix'
		rgb	= cat(4,rgb{:});
	case 'cell'
	otherwise
		error(['"' opt.return '" is not a recognized return type.']);
end
