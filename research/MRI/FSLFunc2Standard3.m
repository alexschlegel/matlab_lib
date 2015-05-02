function [bSuccess,cPathOut] = FSLFunc2Standard3(cPathFunc,varargin)
% FSLFunc2Standard3
% 
% Description:	transform preprocessed functional data to 3mm standard space
% 
% Syntax:	[bSuccess,cPathOut] = FSLFunc2Standard3(cPathFunc,<options>)
% 
% In:
% 	cPathFunc	- the path to a functional file that has been preprocessed using
%				  FSLFEATPreprocess, or a cell of file paths
%	<options>:
%		output:		(<auto>) the output file path/cell of output paths
%		force:		(true) true to force creation of output paths if they
%					already exist
%		force_pre:	(false) true to force preliminary steps if outputs already
%					exist
%		cores:		(1) the number of processor cores to use
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	bSuccess	- a logical array specifying which data were transformed
%				  successfully
%	cPathOut	- the output file path/cell of output paths
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if isempty(cPathFunc)
	[bSuccess,cPathOut]	= deal([]);
	return;
end

%parse the inputs
	opt	= ParseArgs(varargin,...
			'output'	, []	, ...
			'force'		, true	, ...
			'force_pre'	, false	, ...
			'cores'		, 1		, ...
			'silent'	, false	  ...
			);
	
	[cPathFunc,cPathOut,bNoCell,b]	= ForceCell(cPathFunc,opt.output);
	[cPathFunc,cPathOut]			= FillSingletonArrays(cPathFunc,cPathOut);
	cPathOut						= cellfun(@(fi,fo) conditional(~isempty(fo),fo,PathAddSuffix(fi,'-standard-3mm','favor','nii.gz')),cPathFunc,cPathOut,'uni',false);

%which data do we need to process?
	if opt.force
		bDo	= true(size(cPathFunc));
	else
		bDo	= ~FileExists(cPathOut);
	end

%transform!
	bSuccess		= ~bDo;
	
	if any(bDo(:))
		bSuccess(bDo)	= MultiTask(@TransformOne,{cPathFunc(bDo) cPathOut(bDo)},...
							'description'	, 'Transforming data to 3mm standard space'	, ...
							'cores'			, opt.cores									, ...
							'uniformoutput'	, true										, ...
							'silent'		, opt.silent								  ...
							);
	end

%------------------------------------------------------------------------------%
function b = TransformOne(strPathIn,strPathOut)
	[strDirIn,strFileIn,strExtIn]	= PathSplit(strPathIn,'favor','nii.gz');
	
	s	= regexp(strFileIn,'^data_(?<suffix>\w+)$','names');
	if isempty(s)
		error('Data file name must be of the form "data_\w+.nii.gz"');
	end
	strSuffix	= s.suffix;
	
	strDirReg		= DirAppend(strDirIn,sprintf('feat_%s',strSuffix),'reg');
	strPathExample	= PathUnsplit(strDirReg,'example_func','nii.gz');
	strPathMNI		= PathUnsplit(strDirReg,'standard','nii.gz');
	strPathWarp		= PathUnsplit(strDirReg,'example_func2standard_warp','nii.gz');
	
	b	= FileExists(strPathExample) && FileExists(strPathMNI) && FileExists(strPathWarp);
	if ~b
		if ~opt.silent
			warning('Registration files do not exist');
		end
		return;
	end
	
	%resample standard space to 3mm
		[b,strPathMNI3]	= FSLResample(strPathMNI,3,...
							'force'		, opt.force_pre	, ...
							'silent'	, true			  ...
							);
		if ~b
			if ~opt.silent
				warning('Failed to resample standard space reference to 3mm');
			end
			return;
		end
	%transform the functional data to 3mm MNI space
		b	= FSLRegisterFNIRT(strPathIn,strPathMNI3,...
				'output'	, strPathOut	, ...
				'warp'		, strPathWarp	, ...
				'force'		, true			, ...
				'silent'	, true			  ...
				);
		
		if ~b
			if ~opt.silent
				warning('Failed to transform functional data');
			end
			return;
		end
	%transform the example_func file
		strPathExampleMNI3	= PathAddSuffix(strPathExample,'2standard-3mm','favor','nii.gz');
		b	= FSLRegisterFNIRT(strPathExample,strPathMNI3,...
				'warp'		, strPathWarp	, ...
				'force'		, opt.force_pre	, ...
				'silent'	, true			  ...
				);
		
		if ~b
			if ~opt.silent
				warning('Failed to transform functional data');
			end
			return;
		end
end
%------------------------------------------------------------------------------%

end
