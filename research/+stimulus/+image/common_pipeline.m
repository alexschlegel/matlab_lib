function [im,b,ifo] = common_pipeline(varargin)
% stimulus.image.common_pipeline
% 
% Description:	common pipeline for generating stimulus images
% 
% Syntax:	opt = stimulus.image.common_pipeline(<options>)
% 
% In:
%	<options>:
%		vargin:		({}) the varargin input to the stimulus function
%		defaults:	({}) a cell of key/value defaults for the options struct
%		f_validate:	([]) the handle to a function that validates the user input.
%					this and below functions should use the same syntax as the
%					corresponding default functions.
%		f_mask:		(@Pipeline_Mask) the handle to a function that constructs
%					the mask 
%		f_image:	(@Pipeline_Image) the handle to a function that generates
%					the image
%		f_generate:	(@Pipeline_Generate) the handle to a function that generates
%					the mask and image. overrides <f_mask> and <f_image>.
%
% Out:
%	im	- the stimulus image
%	b	- the stimulus mask
%	ifo	- a struct of info about the stimulus
% 
% Updated: 2015-09-24
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	optPipe	= ParseArgs(varargin,...
				'vargin'		, {}					, ...
				'defaults'		, {}					, ...
				'f_validate'	, []					, ...
				'f_mask'		, @Pipeline_Mask		, ...
				'f_image'		, @Pipeline_Image		, ...
				'f_generate'	, @Pipeline_Generate	  ...
				);

%parse the user inputs and do pre stuff
	[opt,ifo]	= stimulus.image.common_pre(optPipe.vargin,optPipe.defaults{:});

%validate the user inputs
	[opt,ifo]	= Pipeline_Validate(opt,ifo);

%generate the stimulus
	[im,b,ifo]	= optPipe.f_generate(opt,ifo);

%------------------------------------------------------------------------------%
function [opt,ifo] = Pipeline_Validate(opt,ifo)
	%default validation steps
		assert(opt.size>=0,'size must be non-negative');
		
		opt.foreground	= str2rgb(opt.foreground);
		opt.backgroud	= str2rgb(opt.background);
	
	if ~isempty(optPipe.f_validate)
		[opt,ifo]	= optPipe.f_validate(opt,ifo);
	end
end
%------------------------------------------------------------------------------%
function [b,ifo] = Pipeline_Mask(opt,ifo)
	b	= false(opt.size);
end
%------------------------------------------------------------------------------%
function [im,ifo] = Pipeline_Image(b,opt,ifo)
	map	=	[
				opt.background
				opt.foreground
			];
	
	im	= ind2im(double(b)+1,map);
end
%------------------------------------------------------------------------------%
function [im,b,ifo] = Pipeline_Generate(opt,ifo)
	[b,ifo]		= optPipe.f_mask(opt,ifo);
	[im,ifo]	= optPipe.f_image(b,opt,ifo);
end
%------------------------------------------------------------------------------%

end
