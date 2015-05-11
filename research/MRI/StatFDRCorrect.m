function cPathOut = StatFDRCorrect(cPathP,varargin)
% StatFDRCorrect
% 
% Description:	false discovery rate correct p value volumes
% 
% Syntax:	cPathOut = StatFDRCorrect(cPathP,<options>)
% 
% In:
% 	cPathP	- the path to a NIfTI volume of p values, an FSL directory
%				  containing p volumes from randomise, or a cell of such
%	<options>:
%		output:		(<auto>) the path to the output file(s)
%		mask:		(<none>) the path to a mask to which to restrict the FDR
%					correction, or a cell of mask paths
%		invert:		(<true if fsl-type file, false otherwise>) true if p-values
%					are stored as 1-p
%		dependent:	(false) true if independence or positive correlation should
% 					not be assumed among the p values
%		cores:		(1) the number of processor cores to use
%		force:		(true) true to force recalculation of pre-existing
%					FDR-corrected files
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	cPathOut	- the path/cell of paths to the FDR-corrected p-values
% 
% Updated: 2015-05-07
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'output'	, []	, ...
			'mask'		, []	, ...
			'invert'	, []	, ...
			'dependent'	, false	, ...
			'cores'		, 1		, ...
			'force'		, true	, ...
			'silent'	, false	  ...
			);
	
	bCell	= iscell(cPathP);
	
	[cPathP,cPathOut,cPathMask]	= ForceCell(cPathP,opt.output,opt.mask);
	[cPathP,cPathOut,cPathMask]	= FillSingletonArrays(cPathP,cPathOut,cPathMask);
	nPathP						= numel(cPathP);
	
	bCell	= bCell | nPathP>1;
	
	%parameters to pass on to each call
		param	= rmfield(opt,{'output','mask','cores','force','isoptstruct','opt_extra'});

%parse the file paths
	bCellCell	= false(nPathP,1);
	
	for kP=1:nPathP
		if isdir(cPathP{kP})
			cPathP{kP}	= FindPFiles(cPathP{kP});
		end
		
		bCellCell(kP)	= iscell(cPathP{kP});
		
		[cPathP{kP},cPathOut{kP},cPathMask{kP}]	= ForceCell(cPathP{kP},cPathOut{kP},cPathMask{kP});
		[cPathP{kP},cPathOut{kP},cPathMask{kP}]	= FillSingletonArrays(cPathP{kP},cPathOut{kP},cPathMask{kP});
		
		bCellCell(kP)	= bCellCell(kP) | numel(cPathP{kP})>1;
		
		cPathOut{kP}	= cellfun(@(fi,fo) unless(fo,GetDefaultOutputPath(fi)),cPathP{kP},cPathOut{kP},'uni',false);
	end

%which data do we need to process?
	sz	= size(cPathP);
	
	if opt.force
		bDo	= true(sz);
	else
		bDo	= ~cellfun(@(cf) all(FileExists(cf)),cPathOut);
	end

%correct!
	b	= true(sz);
	
	if any(bDo(:))
		cInput	=	{
						cPathP(bDo)
						cPathOut(bDo)
						cPathMask(bDo)
						param
					};
		
		b(bDo)	= MultiTask(@CorrectOne,cInput,...
					'description'	, 'FDR correcting p-values'	, ...
					'uniformoutput'	, true						, ...
					'cores'			, opt.cores					, ...
					'silent'		, opt.silent				  ...
					);
	end

%uncellify
	for kP=1:nPathP
		if ~bCellCell(kP)
			cPathOut{kP}	= cPathOut{kP}{1};
		end
	end
	
	if ~bCell
		cPathOut	= cPathOut{1};
	end


%------------------------------------------------------------------------------%
function b = CorrectOne(cPathP,cPathOut,cPathMask,param)
	b	= all(cellfun(@(fp,fo,fm) CorrectActuallyOne(fp,fo,fm,param),cPathP,cPathOut,cPathMask));
%------------------------------------------------------------------------------%
function b = CorrectActuallyOne(strPathP,strPathOut,strPathMask,param)
	reFSL	= '(_vox_p_)|(_tfce_p_)';
	
	b	= true;
	
	%load the p values
		nii	= NIfTI.Read(strPathP);
		p	= double(nii.data);
	%invert the p values
		bInvert	= notfalse(param.invert) || (isempty(param.invert) & ~isempty(regexp(strPathP,reFSL)));
		if bInvert
			p	= 1-p;
		end
	%load the mask
		if ~isempty(strPathMask)
			m	= logical(NIfTI.Read(strPathMask,'return','data'));
		else
			m	= [];
		end
	%calculate the adjusted p values
		[dummy,pFDR]	= fdr(p,0.05,...
							'mask'		, m					, ...
							'dependent'	, param.dependent	  ...
							);
	%uninvert
		if bInvert
			pFDR	= 1-pFDR;
		end
	%save the corrected p values
		nii.data	= pFDR;
		NIfTI.Write(nii,strPathOut);
%------------------------------------------------------------------------------%
function cPathP = FindPFiles(strDir)
	reFSL	= '(_vox_p_)|(_tfce_p_)';
	cPathP	= FindFiles(strDir,reFSL);
%------------------------------------------------------------------------------%
function strPathOut = GetDefaultOutputPath(strPathP)
	reFSL		= '(_vox_p_)|(_tfce_p_)';
	
	[strDir,strFilePre,strExt]	= PathSplit(strPathP,'favor','nii.gz');
	
	strFilePreNew	= strrep(strFilePre,'_p_','_fdrcorrp_');
	if isequal(strFilePre,strFilePreNew)
		strFilePreNew	= sprintf('%s_fdrcorrp',strFilePreNew);
	end
	
	strPathOut	= PathUnsplit(strDir,strFilePreNew,strExt);
%------------------------------------------------------------------------------%
