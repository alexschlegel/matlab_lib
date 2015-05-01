function [b,cPathOut] = FSLConvertWarp(cPathRef,varargin)
% FSLConvertWarp
% 
% Description:	wrapper for FSL's convertwarp tool
% 
% Syntax:	[b,cPathOut] = FSLConvertWarp(cPathRef,<options>)
% 
% In:
% 	cPathRef	- the path/cell of paths to reference images
%	<options>:
%		premat:		(<none>) the path/cell of paths to the pre-affine transform
%					file
%		warp1:		(<none>) the path/cell of paths to the initial warp file
%		warp2:		(<none>) the path/cell of paths to the secondary warp file
%		postmat:	(<none>) the path/cell of paths to the post-affine transform
%					file
%		output:		(<auto>) the path/cell of paths to the output warp file
%		cores:		(1) the number of processor cores to use
%		force:		(true) true to force creation of the warp file even if it
%					already exists
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	b			- an array indicating which warp files were successfully created
%	cPathOut	- the output path/cell of output paths
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'premat'	, []	, ...
		'warp1'		, []	, ...
		'warp2'		, []	, ...
		'postmat'	, []	, ...
		'output'	, []	, ...
		'cores'		, 1		, ...
		'force'		, true	, ...
		'silent'	, false	  ...
		);

%parse the inputs
	[cPathRef,cPathPreMat,cPathWarp1,cPathWarp2,cPathPostMat,cPathOut,bNoCell,b,b,b,b,b]	= ForceCell(cPathRef,opt.premat,opt.warp1,opt.warp2,opt.postmat,opt.output);
	[cPathRef,cPathPreMat,cPathWarp1,cPathWarp2,cPathPostMat,cPathOut]						= FillSingletonArrays(cPathRef,cPathPreMat,cPathWarp1,cPathWarp2,cPathPostMat,cPathOut);
	
	cPathOut	= cellfun(@GetOutputPath,cPathPreMat,cPathWarp1,cPathWarp2,cPathPostMat,cPathOut,'uni',false);

%convert
	b	= MultiTask(@ConvertWarpOne,{cPathRef,cPathPreMat,cPathWarp1,cPathWarp2,cPathPostMat,cPathOut},...
			'description'	, 'converting warps'	, ...
			'uniformoutput'	, true					, ...
			'cores'			, opt.cores				, ...
			'silent'		, opt.silent			  ...
			);

%uncellify
	if bNoCell
		cPathOut	= cPathOut{1};
	end

%------------------------------------------------------------------------------%
function strPathOut = GetOutputPath(strPathPreMat,strPathWarp1,strPathWarp2,strPathPostMat,strPathOut)
	if isempty(strPathOut)
		cPath	= {strPathPreMat,strPathWarp1,strPathWarp2,strPathPostMat};
		
		cPre			= cellfun(@(f) PathGetFilePre(f,'favor','nii.gz'),cPath,'uni',false);
		cDir			= cellfun(@PathGetDir,cPath,'uni',false);
		
		bEmpty			= cellfun(@isempty,cPre);
		
		cPre(bEmpty)	= [];
		cDir(bEmpty)	= [];
		
		strPathOut	= PathUnsplit(cDir{1},join(cPre,'-'),'nii.gz');
	end
end
%------------------------------------------------------------------------------%
function b = ConvertWarpOne(strPathRef,strPathPreMat,strPathWarp1,strPathWarp2,strPathPostMat,strPathOut)
	if ~opt.force && FileExists(strPathOut)
		b	= true;
		return;
	end
	
	%construct the script options
		cPre	= conditional(isempty(strPathPreMat),{},{['--premat=' EscapeArgument(strPathPreMat)]});
		cW1		= conditional(isempty(strPathWarp1),{},{['--warp1=' EscapeArgument(strPathWarp1)]});
		cW2		= conditional(isempty(strPathWarp2),{},{['--warp2=' EscapeArgument(strPathWarp2)]});
		cPost	= conditional(isempty(strPathPostMat),{},{['--postmat=' EscapeArgument(strPathPostMat)]});
		
	%call the script
		ec	= CallProcess('convertwarp',['-r' strPathRef cPre cW1 cW2 cPost '-o' strPathOut],...
				'silent'	, opt.silent	  ...
				);

		b	= ec==0;
end
%------------------------------------------------------------------------------%

end
