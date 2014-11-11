function strPathWarpInv = FSLInvertWarp(strPathWarp,strPathFrom,varargin)
% FSLInvertWarp
% 
% Description:	invert a fnirt warp using FSL's invwarp tool
% 
% Syntax:	strPathWarpInv = FSLInvertWarp(strPathWarp,strPathFrom,<options>)
% 
% In:
% 	strPathWarp	- the path to the warp to invert
%	strPathFrom	- the path to the from-volume of the original warp (i.e. the
%				  input volume to the call to fnirt that created the warp being
%				  inverted)
%	<options>:
%		output:	(<input>_inv.nii.gz) the path to the output inverted warp
%		silent:	(false) true to suppress status messages
% 
% Out:
% 	strPathWarpInv	- path to the inverted warp
% 
% Updated: 2011-03-11
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'output'	, []	, ...
		'silent'	, false	  ...
		);

strPathWarpInv	= unless(opt.output,PathAddSuffix(strPathWarp,'_inv','favor','nii.gz'));

%construct the script string
	strScript	= ['invwarp -w "' strPathWarp '" -o "' strPathWarpInv '" -r "' strPathFrom '"']; 
%run the script
	if RunBashScript(strScript,'silent',opt.silent)
		strPathWarpInv	= []; 
	end
