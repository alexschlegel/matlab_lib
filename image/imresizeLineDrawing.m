function im = imresizeLineDrawing(im,s,varargin)
% imresizeLineDrawing
% 
% Description:	resize a line drawing
% 
% Syntax:	im = imresizeLineDrawing(im,s,<options>)
% 
% In:
% 	im	- a grayscale image of a line drawing, path to such, or cells of such
%	s	- the scale argument to imresize
%	<options>:
%		output:			(<none>) the output file path/cell of output file paths
%						to save the results
%		min_filt_size:	(3) the size of the minimum filter applied before
%						resizing
%		envelope_sigma:	(10) the sigma of the fourier envelope applied after
%						resizing
%		cores:			(1) the number of processor cores to use 
% 
% Out:
% 	im	- the resized line drawing image(s), or output paths if the output
%		  option was specified
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'output'			, []	, ...
		'min_filt_size'		, 3		, ...
		'envelope_sigma'	, 10	, ...
		'cores'				, 1		  ...
		);

[im,opt.output,bNoCell,dummy]	= ForceCell(im,opt.output);
[im,opt.output]					= FillSingletonArrays(im,opt.output);

im	= MultiTask(@ResizeOne,{im opt.output},...
		'description'	, 'resizing line drawings'	, ...
		'cores'			, opt.cores					  ...
		);

if bNoCell
	im	= im{1};
end

%------------------------------------------------------------------------------%
function im = ResizeOne(im,strPathOut)
	%get the image
		if ischar(im)
			im	= rgbRead(im);
		elseif ~isa(im,'double')
			im	= double(im);
		end
	%resize
		im	= ordfilt2(im,1,ones(opt.min_filt_size));
		im	= imresize(im,s);
		im	= gFourierEnvelope(1-im,'gaussian_inv','sigma',opt.envelope_sigma);
		im	= max(0,im);
		im	= 1 - normalize(im);
	%should we save?
		if ~isempty(strPathOut)
			rgbWrite(im,strPathOut);
			im	= strPathOut;
		end
end
%------------------------------------------------------------------------------%

end
