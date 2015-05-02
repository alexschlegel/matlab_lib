function [b,cPathMaskOut] = FSLMaskTransform(cDirFunctional,cPathMaskIn,cFrom,cTo,varargin)
% FSLMaskTransform
% 
% Description:	transform masks between functional, highres, and standard space
%				using flirt
% 
% Syntax:	[b,cPathMaskOut] = FSLMaskTransform(cDirFunctional,cPathMaskIn,cFrom,cTo,<options>)
% 
% In:
% 	cDirFunctional	- the functional directory of a subject who has been
%					  preprocessed using FSLFEATPreprocess, or a cell of paths
%	cPathMaskIn		- the path to a mask to transform, a cell of paths to
%					  transform the same set of masks for each subject, or a
%					  cell of cells of paths to transform a different set of
%					  masks for each subject
%	cFrom			- the source space, cell of source spaces, or cell of cells
%					  of source spaces for each mask.  must be 'highres',
%					  'standard', 'cat' (for concatenated runs), or a number
%					  indicating a functional run.
%	cTo				- the destination space, cell of destination spaces, or cell
%					  of cells of destination spaces for each mask.
%	<options>:
%		force:		(true) true to retransform masks whose output exists
%		cores:		(1) the number of processor cores to use
%		silent:		(false) true to suppress status messages
% 
% Out:
%	b				- true if all masks were created successfully
% 	cPathMaskOut	- the path/cell of paths/cell of cells of paths to the
%					  transformed masks
%
% Note: if cPathMaskIn is a cell of strings the same size as cDirFunctional, the
%		function assumes the masks match up one to one with the functional
%		directories.  if this is not the case make sure cPathMaskIn is wrapped
%		in another cell.
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
cPathMaskOut	= [];
cSpace			= [{'standard','highres','functional','cat'} num2cell(1:50)];

%parse the input
	opt	= ParseArgs(varargin,...
			'force'		, true	, ...
			'cores'		, 1		, ...
			'silent'	, false	  ...
			);
	
	if isempty(cDirFunctional) || isempty(cPathMaskIn)
		return;
	end
	
	kLevelAll	= cellnestmaxlevel(cDirFunctional,cPathMaskIn,cFrom,cTo);
	kLevelMask	= cellnestmaxlevel(cPathMaskIn,cFrom,cTo);
	
	bSingleSubject	= ~iscell(cDirFunctional);
	bSingleMask		= ~iscell(cPathMaskIn);
	
	[cDirFunctional,cPathMaskIn,cFrom,cTo]	= ForceCell(cDirFunctional,cPathMaskIn,cFrom,cTo);
	[cPathMaskIn,cFrom,cTo]				= ForceCell(cPathMaskIn,cFrom,cTo,'level',2);
	[cPathMaskIn,cFrom,cTo]				= FillSingletonArrays(cPathMaskIn,cFrom,cTo);
	[cPathMaskIn,cFrom,cTo]				= cellfun(@(cm,cf,ct) FillSingletonArrays(cm,cf,ct),cPathMaskIn,cFrom,cTo,'UniformOutput',false);
	
	cFrom	= cellnestfun(@(x) CheckInput(x,'space',cSpace),cFrom);
	cTo		= cellnestfun(@(x) CheckInput(x,'space',cSpace),cTo);
	
	nSubject		= numel(cDirFunctional);
	
	bNonMatching	= kLevelMask~=1 || numel(cPathMaskIn{1})~=nSubject;
	
	[cDirFunctional,cPathMaskIn,cFrom,cTo]	= FillSingletonArrays(cDirFunctional,cPathMaskIn,cFrom,cTo);
%get the output paths
	cPathMaskOut	= cellfun(@(d,m,t) cellnestfun(@(m,t) GetOutputPath(d,m,t),m,t),cDirFunctional,cPathMaskIn,cTo,'UniformOutput',false);
%get the transform XFM
	[cPathXFM,cPathRef]		= cellfun(@(d,f,t) cellnestfun(@(f,t) GetXFMPath(d,f,t),f,t),cDirFunctional,cFrom,cTo,'UniformOutput',false);
%flatten the nest and determine which masks to create
	cPathMaskInAll	= append(cPathMaskIn{:});
	cPathMaskOutAll	= append(cPathMaskOut{:});
	cPathXFMAll		= append(cPathXFM{:});
	cPathRefAll		= append(cPathRef{:});
%transform!
	b	= all(FSLRegisterFLIRT(cPathMaskInAll,cPathRefAll,...
			'output'	, cPathMaskOutAll		, ...
			'xfm'		, cPathXFMAll			, ...
			'interp'	, 'nearestneighbour'	, ...
			'force'		, opt.force				, ...
			'cores'		, opt.cores				, ...
			'silent'	, opt.silent			  ...
			));
%format the output
	switch kLevelAll
		case 0
			cPathMaskOut	= cPathMaskOut{1}{1};
		case 1
			if ~bNonMatching || bSingleSubject
				cPathMaskOut	= cPathMaskOut{1};
			elseif bSingleMask
				cPathMaskOut	= cellfun(@(x) x{1},cPathMaskOut,'UniformOutput',false);
			end
	end


%------------------------------------------------------------------------------%
function strPathOut = GetOutputPath(strDirFunctional,strPathMask,vTo)
	if ischar(vTo)
		switch vTo
			case {'standard','highres'}
				strDirOut	= strDirFunctional;
			case 'cat'
				strDirOut	= DirAppend(strDirFunctional,'feat-cat','reg');
				vTo			= 'func';
		end
		
		strTo	= vTo;
	else
		strDirOut	= DirAppend(strDirFunctional,['feat-' StringFill(vTo,2)],'reg');
		
		strTo		= 'func';
	end
	
	strPathPre	= PathGetFilePre(strPathMask,'favor','nii.gz');
	strPathOut	= PathUnsplit(strDirOut,[strPathPre '-2' strTo],'nii.gz');
end
%------------------------------------------------------------------------------%
function [strPathXFM,strPathRef] = GetXFMPath(strDirFunctional,vFrom,vTo)
	strPathXFM	= [];
	
	if ischar(vFrom)
		if ischar(vTo)
			if isequal(vFrom,vTo)
				return;
			end
			
			switch vFrom
				case 'cat'
					strRun	= 'cat';
					vFrom	= 'example_func';
				otherwise
					switch vTo
						case 'cat'
							strRun	= 'cat';
							vTo		= 'example_func';
						otherwise
							strRun	= '01';
					end
			end
		else
			switch vFrom
				case 'cat'
					error('functional to functional transforms are not supported.');
				otherwise
					strRun	= StringFill(vTo,2);
					vTo		= 'example_func';
			end
		end
	elseif ischar(vTo)
		switch vTo
			case 'cat'
				error('functional to functional transforms are not supported.');
			otherwise
				strRun	= StringFill(vFrom,2);
				vFrom	= 'example_func';
		end
	else
		error('functional to functional transforms are not supported.');
	end
	
	strDirXFM	= DirAppend(strDirFunctional,['feat-' strRun],'reg');
	strPathXFM	= PathUnsplit(strDirXFM,[vFrom '2' vTo],'mat');
	strPathRef	= PathUnsplit(strDirXFM,vTo,'nii.gz');
end
%------------------------------------------------------------------------------%

end
