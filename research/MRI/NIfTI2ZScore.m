function [bSuccess,cPathZScore] = NIfTI2ZScore(cPathNII,varargin)
% NIfTI2ZScore
% 
% Description:	convert NIfTI data to Z-scores
% 
% Syntax:	[bSuccess,cPathZScore] = NIfTI2ZScore(cPathNII,<options>)
% 
% In:
% 	cPathNII	- a path to an NIfTI file, or a cell of such
%	<options>:
%		nonzero:	(true) true to only calculate Z-scores based on non-zero,
%					non-NaN values
%		output:		(<auto>) path/cell of paths to the output files
%		nthread:	(1) number of threads to use for processing
%		force:		(true) true to force calculation even if the output file
%					already exists
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	bSuccess	- a logical array indicating which Z-score files were
%				  successfully computed
%	cPathZScore	- the output Z-score path or cell of paths
% 
% Updated: 2011-03-11
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'nonzero'	, true	, ...
		'output'	, []	, ...
		'nthread'	, 1		, ...
		'force'		, true	, ...
		'silent'	, false	  ...
		);

[cPathNII,opt.output,bToChar,b]	= ForceCell(cPathNII,opt.output);
[cPathNII,opt.output]			= FillSingletonArrays(cPathNII,opt.output);

nPath		= numel(cPathNII);
sPath		= size(cPathNII);
bToChar		= bToChar && nPath==1;

bSuccess	= false(nPath,1);

%parse paths
	cPathZScore	= cellfun(@(nii,fo) conditional(~isempty(fo),fo,PathAddSuffix(nii,'Z','favor','nii.gz')),cPathNII,opt.output,'UniformOutput',false);
%get the inputs to process
	[bSuccess,bDo]	= deal(false(sPath));
	
	bDo(opt.force | ~FileExists(cPathZScore))	= true;
	bSuccess(~bDo)								= true;
%calculate each ZScore volume
	if any(bDo(:))
		bSuccess(bDo)	= MultiTask(@NII2ZScore,{cPathNII(bDo),cPathZScore(bDo),opt.nonzero},'uniformoutput',true,'nthread',opt.nthread,'silent',opt.silent);
	end

if bToChar
	cPathZScore	= cPathZScore{1};
end


%------------------------------------------------------------------------------%
function bSuccess = NII2ZScore(strPathNII,strPathZScore,bNonZero)
	bSuccess	= true;
	
	try
		%load the NIfTI data
			nii	= NIfTIRead(strPathNII,'method','load_nii');
		%only calculate for non-zero NII values
			if bNonZero
				b	= ~isnan(nii.img) & nii.img~=0;
			else
				b	= true(size(nii.img));
			end
		%mean of the data
			m	= mean(nii.img(b));
		%standard deviation of data
			sd	= std(nii.img(b));
		%z-score
			nii.img(b)	= conditional(sd==0,0,(nii.img(b) - m)./sd);
		%write the z-score data
			NIfTIWrite(nii,strPathZScore);
	catch me
		bSuccess	= false;
	end
%------------------------------------------------------------------------------%
