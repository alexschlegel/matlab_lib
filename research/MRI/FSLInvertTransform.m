function strPathXFMInv = FSLInvertTransform(strPathXFM,varargin)
% FSLInvertTransform
% 
% Description:	invert a transform using FSL's convert_xfm tool
% 
% Syntax:	strPathXFMInv = FSLInvertTransform(strPathXFM,<options>)
% 
% In:
% 	strPathXFM	- the path to the affine transform to invert
%	<options>:
%		output:	(<input>_inv.mat) the path to the output inverted transform file
%		silent:	(false) true to suppress status messages
% 
% Out:
% 	strPathXFMInv	- path to the inverted transform file
% 
% Updated: 2011-02-19
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'output'	, []	, ...
		'silent'	, false	  ...
		);

strPathXFMInv	= unless(opt.output,PathAddSuffix(strPathXFM,'_inv'));

%construct the script string
	strScript	= ['convert_xfm -omat "' strPathXFMInv '" -inverse "' strPathXFM '"']; 
%run the script
	if RunBashScript(strScript,'silent',opt.silent)
		strPathXFMInv	= []; 
	end
