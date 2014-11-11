function [strPathD,strPathCT,strPathF,strPathG] = FSLWriteDesign(d,varargin)
% FSLWriteDesign
% 
% Description:	write a set of design specifications for a randomise analysis
% 
% Syntax:	[strPathD,strPathCT,strPathF,strPathG] = FSLWriteDesign(d,[ct],[f],[g],<options>)
% 
% In:
% 	d	- an MxN array specifying the design matrix for M observations and N
%		  explanatory variables
%	[ct]- a TxN array specifying T t-contrasts
%	[f]	- an FxT array specifying F f-tests
%	[g]	- an M-length array specifying the group membership of each observation
%	<options>:
%		dir_out:	(pwd) the output directory
%		name:		('design') the name of the analysis
%		t_name:		(<auto>) a T-length cell specifying the name of each
%					t-contrast
% 
% Out:
% 	strPathD	- the path to the design matrix file
%	strPathCT	- the path to the t-contrast file, if specified
%	strPathF	- the path to the f-test file, if specified
%	strPathG	- the path to the group file, if specified
% 
% Updated: 2012-06-26
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[ct,f,g,opt]	= ParseArgs(varargin,[],[],[],...
					'dir_out'	, pwd		, ...
					'name'		, 'design'	, ...
					't_name'	, []		  ...
					);

[bCT,bF,bG]	= varfun(@(x) ~isempty(x),ct,f,g);

%construct the output paths
	strPathD	= PathUnsplit(opt.dir_out,opt.name,'mat');
	strPathCT	= conditional(bCT,PathUnsplit(opt.dir_out,opt.name,'con'),[]);
	strPathF	= conditional(bF,PathUnsplit(opt.dir_out,opt.name,'fts'),[]);
	strPathG	= conditional(bG,PathUnsplit(opt.dir_out,opt.name,'grp'),[]);

%save the design files
	FSLWriteDesignMatrix(d,strPathD);
	if bCT
		FSLWriteTContrast(ct,strPathCT,'name',opt.t_name);
	end
	if bF
		FSLWriteFTest(f,strPathF);
	end
	if bG
		FSLWriteGroup(g,strPathG);
	end
