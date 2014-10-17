function strPathXFM = FSLConcatenateTransform(cPathXFM,varargin)
% FSLConcatenateTransform
% 
% Description:	concatenate transforms using FSL's convert_xfm tool.  note that
%				convert_xfm takes input transforms in reverse order, e.g.
%				AtoB.mat, BtoC.mat, and CtoD.mat are concatenated as:
%				convert_xfm -omat AtoD.mat -concat CtoD.mat BtoC.mat AtoB.mat
%				and should be passed as:
%					cPathXFM={'CtoD.mat','BtoC.mat','AtoB.mat'};
% 
% Syntax:	strPathXFM = FSLConcatenateTransform(cPathXFM,<options>)
% 
% In:
% 	cPathXFM	- a cell of paths to transforms to concatenate
%	<options>:
%		output:	(<append suffixes>) the path to the output concatenated
%				transform file
%		silent:	(false) true to suppress status messages
% 
% Out:
% 	strPathXFM	- path to the concatenated transform file, or [] if the process
%				  was unsuccessful
% 
% Updated: 2011-02-19
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if isempty(cPathXFM)
	strPathXFM	= [];
	return;
end

opt	= ParseArgs(varargin,...
		'output'	, []	, ...
		'silent'	, false	  ...
		);
if isempty(opt.output)
	%concatenate the suffixes of each transform
		cFilePre		= cellfun(@PathGetFilePre,cPathXFM,'UniformOutput',false);
		strPathBase		= PathGetBase(cFilePre,'include_file',true);
		nBase			= numel(strPathBase);
		cSuffix			= cellfun(@(x) x(nBase+1:end),cFilePre,'UniformOutput',false);
		strSuffixCat	= cat(2,cSuffix{2:end});
	%concatenated transform file path
		strPathXFM	= PathAddSuffix(cPathXFM{1},strSuffixCat);
else
	strPathXFM	= opt.output;
end

%construct the script string
	strScript	= ['convert_xfm -omat "' strPathXFM '" -concat "' join(cPathXFM,'" "') '"']; 
%run the script
	if RunBashScript(strScript,'silent',opt.silent)
		strPathXFM	= []; 
	end
