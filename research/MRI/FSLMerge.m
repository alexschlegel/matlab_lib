function bSuccess = FSLMerge(cPathIn,cPathOut,varargin)
% FSLMerge
% 
% Description:	wrapper for FSL's fslmerge utility
% 
% Syntax:	bSuccess = FSLMerge(cPathIn,cPathOut,<options>) OR
%			strScript = FSLMerge(cPathIn,strPathOut,'run',false,<options>)
% 
% In:
% 	cPathIn		- a cell of input NIfTI paths, all with the same dimensions, or
%				  a cell of cells
%	cPathOut	- the output NIfTI path, or a cell of NIfTI paths
%	<options>:
%		force:		(true) true to overwrite the output file if it already exists
%		cores:		(1) the number of processor cores to use
%		silent:		(false) true to suppress status messages
%		run:		(true) true to actually carry out the merging, false to just
%					return a command to do it (see Syntax).  note that only one
%					merge operation can be specified in this case.
% 
% Out:
% 	bSuccess	- true if the files were sucessfully merged
%	strScript	- the script that would merge the specified files
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'force'		, true	, ...
		'cores'		, 1		, ...
		'silent'	, false	, ...
		'run'		, true	  ...
		);

cPathIn		= ForceCell(cPathIn,'level',2);
cPathOut	= ForceCell(cPathOut);
sPathIn		= size(cPathIn);

if opt.run
	bSuccess	= true(sPathIn);
	
	if opt.force
		bProcess	= true(sPathIn);
	else
		bProcess	= ~FileExists(cPathOut);
	end
	
	bSuccess(bProcess)	= MultiTask(@MergeOne,{cPathIn(bProcess) cPathOut(bProcess) true opt},...
							'description'	, 'Merging NIfTI files'	, ...
							'cores'			, opt.cores				, ...
							'uniformoutput'	, true					, ...
							'silent'		, opt.silent			  ...
							);
else
	bSuccess	= MergeOne(cPathIn{1},cPathOut{1},false,opt);
end

%------------------------------------------------------------------------------%
function b = MergeOne(cPathIn,strPathOut,bDo,opt)
	%save the input paths to a file so they don't make our command too long
		strPaths	= join(cPathIn,10);
		strPathTemp	= GetTempFile;
		fput(strPaths,strPathTemp);
	%run the fslmerge script
		strScript	= sprintf('cat %s | xargs fslmerge -a %s',strPathTemp,strPathOut);
		
		if bDo
			[vExitCode,strOutput]	= RunBashScript(strScript,'silent',opt.silent);
		else
			b	= strScript;
			return;
		end
	%delete the input file
		delete(strPathTemp);
	
	b	= ~vExitCode && FileExists(strPathOut);
%------------------------------------------------------------------------------%
