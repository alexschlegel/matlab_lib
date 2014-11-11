function [b,strPathOut] = FSLMask(strPathIn,varargin)
% FSLMask
% 
% Description:	construct a mask from 4D data
% 
% Syntax:	[b,strPathOut] = FSLMask(strPathIn,<options>)
% 
% In:
% 	strPathIn	- the path to a 4D data set
%	<options>:
%		output:	(<auto>) the output path
%		method:	('max') the method to use.  one of the following:
%					'min':	min of absolute value across time > 0
%					'max':	max of absolute value across time > 0
%					'mean':	mean used as input to bet and binarized
%		thresh:	(<prompt>) the bet threshold if method=='mean'
%		silent:	(false) true to suppress status messages
% 
% Out:
% 	b			- true if the operation was a success
%	strPathOut	- the output path
% 
% Updated: 2013-01-24
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'output'	, PathAddSuffix(strPathIn,'-mask','favor','nii.gz')	, ...
		'method'	, 'min'													, ...
		'thresh'	, []													, ...
		'silent'	, false													  ...
		);

switch lower(opt.method)
	case 'min'
		[ec,strOut]	= CallProcess('fslmaths',{strPathIn,'-abs','-Tmin','-bin',opt.output},'silent',opt.silent);
		b			= ec==0;
	case 'max'
		[ec,strOut]	= CallProcess('fslmaths',{strPathIn,'-abs','-Tmax','-bin',opt.output},'silent',opt.silent);
		b			= ec==0;
	case 'mean'
		b	= FSLBet(strPathIn,'output',opt.output,'thresh',opt.thresh,'binarize',true,'silent',opt.silent);
	otherwise
		error(['"' tostring(opt.method) '" is an unrecognized method.']);
end

strPathOut	= opt.output;
