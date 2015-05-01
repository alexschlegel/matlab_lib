function [bSuccess,cPathZScore] = ZScore(cPathNII,varargin)
% NIfTI.ZScore
% 
% Description:	convert NIfTI data to Z-scores
% 
% Syntax:	[bSuccess,cPathZScore] = NIfTI.ZScore(cPathNII,<options>)
% 
% In:
% 	cPathNII	- a path to an NIfTI file, or a cell of such
%	<options>:
%		nonzero:	(true) true to only calculate Z-scores based on non-zero,
%					non-NaN values
%		output:		(<auto>) path/cell of paths to the output files
%		cores:		(1) the number of processor cores to use
%		force:		(true) true to force calculation even if the output file
%					already exists
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	bSuccess	- a logical array indicating which Z-score files were
%				  successfully computed
%	cPathZScore	- the output Z-score path or cell of paths
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'nonzero'	, true	, ...
		'output'	, []	, ...
		'cores'		, 1		, ...
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
		bSuccess(bDo)	= MultiTask(@NII2ZScore,{cPathNII(bDo),cPathZScore(bDo),opt.nonzero},'uniformoutput',true,'cores',opt.cores,'silent',opt.silent);
	end

if bToChar
	cPathZScore	= cPathZScore{1};
end


%------------------------------------------------------------------------------%
function bSuccess = NII2ZScore(strPathNII,strPathZScore,bNonZero)
	bSuccess	= true;
	
	try
		%load the NIfTI data
			nii			= NIfTI.Read(strPathNII);
			nii.data	= double(nii.data);
		%only calculate for non-zero NII values
			if bNonZero
				b	= ~isnan(nii.data) & nii.data~=0;
			else
				b	= true(size(nii.data));
			end
		%mean of the data
			m	= mean(nii.data(b));
		%standard deviation of data
			sd	= std(nii.data(b));
		%z-score
			nii.data(b)	= conditional(sd==0,0,(nii.data(b) - m)./sd);
		%write the z-score data
			NIfTI.Write(nii,strPathZScore);
	catch me
		bSuccess	= false;
	end
%------------------------------------------------------------------------------%
