function [bSuccess,strPathSTL] = FSLTract2STL(strDirDTI,strNameTract,varargin)
% FSLTract2STL
% 
% Description:	save an isosurface from a probtrackx distribution as an STL file
% 
% Syntax:	[bSuccess,strPathSTL] = FSLTract2STL(strDirDTI,strNameTract,<options>)
% 
% In:
% 	strDirDTI		- the DTI data directory path
%	strNameTract	- the name of the tract (i.e. the name of the tract folder in
%					  <strDirDTI>.probtrackX/)
%	<options>:
%		isoval:			(<auto>) the isosurface value
%		isoval_method:	('abs') one of the following to specify what the <isoval>
%						method signifies:
%							'abs':	<isoval> is the isosurface value
%							'prctile':	the isosurface value is calculated as
%								the <isoval>th percentile of non-zero tract
%								values
%							'mask':	all non-zero values are used
%		isoval_sample:	(<isovalue default>) the 'sample' option to the isovalue
%						function.  used if <isoval> is not specified.
%		useroi:			(true) true to use the roi.nii.gz file instead of
%						fdt_paths.nii.gz if it exists
%		space:			('diffusion') one of the following to specify the output
%						space:
%							'diffusion':	same space as tractography
%							'freesurfer':	output in freesurfer surface space.
%								<dir_fs> must be specified.
%		dir_fs:			(<none>) the subject's FreeSurfer directory.  must be
%						specified if space is 'freesurfer' 
%		output:			(<dir_tract>/<tractname>_<isoval>[-<space>].nii.gz) the
%						output file path
%		force:			(true) true to save the STL even if the output file
%						already exists
%		forceprep:		(false) true to force preparatory processes (e.g.
%						calculating the FA/FS registration)
%		silent:			(false) true to suppress status messages
% 
% Out:
% 	bSuccess	- true if the STL file was successfully created
%	strPathSTL	- the path to the STL file
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
bSuccess	= false;
strPathSTL	= [];

opt	= ParseArgs(varargin,...
		'isoval'		, []			, ...
		'isoval_method'	, 'abs'			, ...
		'isoval_sample'	, []			, ...
		'useroi'		, true			, ...
		'space'			, 'diffusion'	, ...
		'dir_fs'		, []			, ...
		'output'		, []			, ...
		'force'			, true			, ...
		'forceprep'		, false			, ...
		'silent'		, false			  ...
		);

strDirTract	= FSLDirTract(strDirDTI,strNameTract);

%get the tract data to use
	if opt.useroi
		strPathROI	= FSLPathTractROI(strDirDTI,strNameTract);
		bROI		= FileExists(strPathROI);
	else
		bROI	= false;
	end
	
	if bROI
		status('using roi.nii.gz','silent',opt.silent);
		
		strPathTract	= strPathROI;
	else
		status('using fdt_paths.nii.gz','silent',opt.silent);
		
		strPathTract	= FSLPathTract(strDirDTI,strNameTract);
	end

	if ~FileExists(strPathTract)
		status(['Probtrackx output does not exist at: ' strPathTract],'warning',true,'silent',opt.silent);
		return;
	end
%get the input data
	switch lower(opt.space)
		case 'diffusion'
			strSuffixSpace	= '';
			M				= [];
		case 'freesurfer'
		%convert the tract to FreeSurfer space
			strSuffixSpace	= '-freesurfer';
			
			%calculate the freesurfer->fa transform
				if isempty(opt.dir_fs)
					error('The subject''s FreeSurfer directory must be specified for FreeSurfer space output.');
				end
				
				[b,strPathFS2FA,strPathFA2FS]	= FreeSurfer2FA(opt.dir_fs,strDirDTI,'force',opt.forceprep,'silent',opt.silent);
				if ~b
					status('Could not calculate the FreeSurfer<-->FA registration.','warning',true,'silent',opt.silent); 
					return;
				end
			%transform the tract
				status('converting tract to FreeSurfer space','silent',opt.silent);
				
				strDirMRI		= DirAppend(opt.dir_fs,'mri');
				strPathRef		= PathUnsplit(strDirMRI,'brain','nii.gz');
				strPathTractFS	= PathAddSuffix(strPathTract,'-freesurfer','favor','nii.gz');
				
				if ~FSLXFM(strPathTract,strPathFA2FS,strPathRef,'output',strPathTractFS,'force',opt.forceprep,'silent',opt.silent)
					status('Could not transform the tract to FreeSurfer space.','warning',true,'silent',opt.silent); 
					return;
				end
				
				strPathTract	= strPathTractFS;
				M				= FreeSurferSurfaceMAT(strPathTract);
		otherwise
			error(['"' tostring(opt.space) '" is an unrecognized space.']);
	end
	
	nii	= NIfTI.Read(strPathTract);
%get the isovalue
	if ~isequal(lower(opt.isoval_method),'mask') && isempty(opt.isoval)
		status('automatically determining isovalue','silent',opt.silent);
		
		opt.isoval			= isovalue(nii.data(nii.data~=0),'sample',opt.isoval_sample);
		opt.isoval_method	= 'abs';
		
		status(['isovalue is ' num2str(opt.isoval)],'silent',opt.silent);
	end
	
	switch lower(opt.isoval_method)
		case 'abs'
		%nothing to do
		case 'prctile'
			opt.isoval	= prctile(nii.data(nii.data~=0),opt.isoval);
		case 'mask'
			opt.isoval	= 1-eps;
			nii.data	= nii.data~=0;
		otherwise
			error(['"' tostring(opt.isoval_method) '" is not a recognized isoval method.']);
	end
	
	if isequal(lower(opt.isoval_method),'mask')
		strSuffixIsoval	= '_mask';
	else
		strSuffixIsoval	= ['_' num2str(opt.isoval)];
	end
%construct the isosurface STL
	strPathSTL	= unless(opt.output,PathUnsplit(strDirTract,[strNameTract strSuffixSpace strSuffixIsoval],'stl'));
	
	if opt.force || ~FileExists(strPathSTL)
		status('converting isosurface to STL','silent',opt.silent);
		
		NIfTI.STL(nii,...
			'isoval'	, opt.isoval	, ...
			'prefix'	, strNameTract	, ...
			'mat'		, M				, ...
			'output'	, strPathSTL	  ...
			);
	end

%success!
	bSuccess	= true;
