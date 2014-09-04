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
%		nthread:	(1) the number of threads to use
%		silent:		(false) true to suppress status messages
%		run:		(true) true to actually carry out the merging, false to just
%					return a command to do it (see Syntax).  not only one merge
%					operation can be specified in this case.
% 
% Out:
% 	bSuccess	- true if the files were sucessfully merged
%	strScript	- the script that would merge the specified files
% 
% Updated: 2014-04-24
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'force'		, true	, ...
		'nthread'	, 1		, ...
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
	
	bSuccess(bProcess)	= MultiTask(@MergeOne,{cPathIn(bProcess) cPathOut(bProcess) true},...
							'description'	, 'Merging NIfTI files'	, ...
							'nthread'		, opt.nthread				, ...
							'uniformoutput'	, true						, ...
							'silent'		, opt.silent				  ...
							);
else
	bSuccess	= MergeOne(cPathIn{1},cPathOut{1},false);
end

%------------------------------------------------------------------------------%
function b = MergeOne(cPathIn,strPathOut,bDo)
	%save the input paths to a file so they don't make our command too long
		strPaths	= join(cPathIn,10);
		strPathTemp	= GetTempFile;
		fput(strPaths,strPathTemp);
	%run the fslmerge script
		strScript	= ['cat ' strPathTemp ' | xargs fslmerge -a ' strPathOut];
		
		if bDo
			[vExitCode,strOutput]	= RunBashScript(strScript,'silent',opt.silent);
		else
			b	= strScript;
			return;
		end
	%delete the input file
		delete(strPathTemp);
	
	b	= ~vExitCode && FileExists(strPathOut);
end
%------------------------------------------------------------------------------%

end
