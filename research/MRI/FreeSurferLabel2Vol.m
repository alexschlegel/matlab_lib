function [bSuccess,strPathOut] = FreeSurferLabel2Vol(cPathLabel,varargin)
% FreeSurferLabel2Vol
% 
% Description:	convert a FreeSurfer label to a binary volume
% 
% Syntax:	[bSuccess,strPathOut] = FreeSurferLabel2Vol(strSubject,cName,[cHemi]='both',<options>) OR
%			[bSuccess,strPathOut] = FreeSurferLabel2Vol(cPathLabel,<options>)
% 
% In:
% 	strSubject	- the name of the FreeSurfer subject
%	cName		- the label name or cell of label names to make a union mask
%	[cHemi]		- the hemisphere(s) to include, either 'lh', 'rh', 'both', or a
%				  cell of hemispheres
% 	cPathLabel	- the path to the label file or a cell of paths to make a union
%				  mask
%	<options>:
%		outdir:			(<base of inputs>) the output directory
%		output:			(<auto>) the output file path.  overrides <outdir>.
%		template:		(<auto>) the path to the template volume.  if this is
%						unspecified then the labels must be in a subject's label
%						directory and the mri/brain.mgz file must exist.
%		xfm:			(<none>) a transform to apply to the mask (either FLIRT
%						or FNIRT)
%		ref:			([]) specify the reference volume if a transform should
%						be applied to the label mask
%		fillthresh:		(0.5) each voxel must be filled by at least this fraction
%						with vertices in order to be counted as part of the mask
%		subjectroot:	(<FreeSurferDirSubject default>) the root FreeSurfer
%						subjects directory
%		force:			(true) true to force conversion even if the output
%						already exists
%		silent:			(false) true to suppress status messages
% 
% Out:
% 	bSuccess	- true if the conversion was successful
%	strPathOut	- the output mask volume path
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
bSuccess	= false;

%parse inputs based on the call type
	cOpt	=	{
					'outdir'		, []	, ...
					'output'		, []	, ...
					'template'		, []	, ...
					'xfm'			, []	, ...
					'ref'			, []	, ...
					'fillthresh'	, 0.5	, ...
					'subjectroot'	, []	, ...
					'force'			, true	, ...
					'silent'		, false	  ...
				};

	%subject code
		reSubject	= ['^\d{2}[A-Za-z]{3}\d{2}[A-Za-z]{2,3}'];
		
	if ischar(cPathLabel) && (~isempty(regexp(cPathLabel,reSubject)) || ~FileExists(cPathLabel))
	%first call type
		strSubject			= cPathLabel;
		[cName,cHemi,opt]	= ParseArgs(varargin,'','both',cOpt{:});
		cName				= reshape(ForceCell(cName),[],1);
		cHemi				= reshape(ForceCell(conditional(isequal(lower(cHemi),'both'),{'lh','rh'},cHemi)),[],1);
		
		cPathLabel	= cellfun(@(n) cellfun(@(h) FreeSurferPathLabel(strSubject,n,h,'subjectroot',opt.subjectroot,'error',false),cHemi,'UniformOutput',false),cName,'UniformOutput',false);
		cPathLabel	= append(cPathLabel{:});
	else
	%second call type
		opt			= ParseArgs(varargin,cOpt{:});
		cPathLabel	= ForceCell(cPathLabel);
	end
%check for input files
	if ~all(FileExists(cPathLabel))
		status('Specified labels are invalid.','warning',true,'silent',opt.silent);
	end

%get the transform suffix
	strSuffixXFM	= conditional(~isempty(opt.xfm),['-' PathGetFilePre(opt.xfm,'favor','nii.gz')],'');
%get the output path
	strDirBase	= PathGetBase(cPathLabel);
	strDirOut	= unless(opt.outdir,strDirBase);
	
	if isempty(opt.output)
		cLabelPre	= cellfun(@PathGetFilePre,cPathLabel,'UniformOutput',false);
		strFilePre	= [join(cLabelPre,'_') strSuffixXFM];
		strPathOut	= PathUnsplit(strDirOut,strFilePre,'nii.gz');
	else
		strPathOut	= opt.output;
	end

%get the template volume path
	if isempty(opt.template)
		cDirLabel		= DirSplit(PathGetDir(strDirBase));
		strDirSubject	= DirUnsplit(cDirLabel(1:end-1));
		strDirMRI		= DirAppend(strDirSubject,'mri');
		strPathTemplate	= PathUnsplit(strDirMRI,'brain','mgz');
	else
		strPathTemplate	= opt.template;
	end
%convert the label
	if opt.force | ~FileExists(strPathOut)
		%append the labels
			nLabel	= numel(cPathLabel);
			cLabel	= [repmat({'--label'},[1 nLabel]); reshape(cPathLabel,1,[])]; 
		%labels to vol
			if CallProcess('mri_label2vol',{...
					cLabel{:}										, ...
					'--temp'		, ['"' strPathTemplate '"']	, ...
					'--fillthresh'	, opt.fillthresh				, ...
					'--o'			, ['"' strPathOut '"']			, ...
					'--identity'									},...
					'silent'		, opt.silent					  ...
					);
				status('Could not convert labels to volumes using mri_label2vol.','warning',true,'silent',opt.silent);
			end
		%binarize the volume if multiple labels were specified
			if nLabel>1
				nii			= NIfTI.Read(strPathOut);
				nii.data	= nii.data>0;
				NIfTI.Write(nii,strPathOut);
			end
		%transform to the output space
			if ~isempty(opt.xfm)
				switch lower(PathGetExt(opt.xfm,'favor','nii.gz'))
					case 'mat'
						b	= FSLRegisterFLIRT(strPathOut,opt.ref,...
								'output'	, strPathOut			, ...
								'xfm'		, opt.xfm				, ...
								'interp'	, 'nearestneighbour'	, ...
								'force'		, true					, ...
								'silent'	, opt.silent			  ...
								);
					case 'nii.gz'
						b	= FSLRegisterFNIRT(strPathOut,opt.ref,...
								'output'	, strPathOut	, ...
								'warp'		, opt.xfm		, ...
								'force'		, true			, ...
								'silent'	, opt.silent	  ...
								);
						%threshold the mask
							nii			= NIfTI.Read(strPathOut);
							nii.data	= double(nii.data);
							nii.data	= reshape(im2bw(nii.data(:),graythresh(nii.data)),size(nii.data));
							NIfTI.Write(nii,strPathOut);
					otherwise
						error(['"' tostring(opt.xfm) '" is not a recognized transform.']);
				end
				if ~b
					status('Could not apply the transform to the label mask.','warning',true,'silent',opt.silent); 
				end
			end
	end
%success!
	bSuccess	= true;
