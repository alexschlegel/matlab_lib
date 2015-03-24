function s = ParseMRIDataPaths(varargin)
% MRIParseDataPaths
% 
% Description:	parse user inputs to construct a set of data paths
% 
% Syntax:	s = ParseMRIDataPaths(<options>)
% 
% In:
%		dir_data:			([]) the root data directory
%		subject:			({}) a cell of subject codes
%		mask:				({}) a cell of mask names
%		dir_functional:		({<dir_data>/functional/<subject>}) a cell of
%							functional data directories. overrides <data_dir>
%							and <subject>.
%		file_functional:	('data_cat') the name of the functional data
%							files
%		path_functional:	({<dir_functional>/<file_functional>.nii.gz}) a cell
%							of paths to functional data. overrides
%							<dir_functional> and <file_functional>.
%		dir_mask:			({<dir_data>/mask/<subject>}) a cell of mask data
%							directories. overrides <dir_data> and <subject>.
%		mask_variant:		([]) the name of a mask variant, if subdirectories
%							of the mask directories exist with the mask variants
%							to use (i.e. <dir_mask>/<mask_variant>/*)
%		path_mask:			({<dir_mask>/[<mask_variant>/]<mask>.nii.gz}) a cell
%							of cells of paths to mask data. overrides <dir_mask>
%							and <masks>.
%		require:			(<none>) a cell of data path types ('functional' or
%							'mask') to require
%		mask_type:			('nested') a string specifying how the <mask>
%							relates to the functional data:
%								nest:	<mask> defines a set of masks for each
%									functional file
%								flat:	each element of <mask> defines a mask
%									for the corresponding element of the
%									functional paths
% 
% Out:
% 	s	- a struct of user-specified path info
% 
% Updated: 2015-03-22
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
s	= struct;

opt	= ParseArgs(varargin,...
		'dir_data'			, ''			, ...
		'subject'			, {}			, ...
		'mask'				, {}			, ...
		'dir_functional'	, []			, ...
		'file_functional'	, 'data_cat'	, ...
		'path_functional'	, []			, ...
		'dir_mask'			, []			, ...
		'mask_variant'		, []			, ...
		'path_mask'			, []			, ...
		'require'			, {}			, ...
		'mask_type'			, 'nest'		  ...
		);

cRequire	= ForceCell(opt.require);
strMaskType	= CheckInput(opt.mask_type,'mask type',{'nest','flat'});

s.opt_extra	= opt.opt_extra;

[cSubject,bNoCellSubject]	= ForceCell(opt.subject);
[cMask,bNoCellMask]			= ForceCell(opt.mask);

%parse the functional data paths
	if isempty(opt.path_functional)
		if isempty(opt.dir_functional)
			cDirFunctional	= cellfun(@(s) conditional(isempty(s),'',DirAppend(opt.dir_data,'functional',s)),cSubject,'uni',false);
			
			s.cell_input.functional	= ~bNoCellSubject;
		else
			[cDirFunctional,bNoCellDir]	= ForceCell(opt.dir_functional);
			
			s.cell_input.functional	= ~bNoCellDir;
		end
		
		cPathFunctional	= cellfun(@(d) conditional(isempty(d),'',PathUnsplit(d,opt.file_functional,'nii.gz')),cDirFunctional,'uni',false);
	else
		[cPathFunctional,bNoCellPath]	= ForceCell(opt.path_functional);
		
		s.cell_input.functional	= ~bNoCellPath;
	end
	
	s.functional			= cPathFunctional;
	s.functional_name		= cellnestfun(@PathGetDataName,s.functional);
	s.functional_session	= cellnestfun(@PathGetSession,s.functional);
	
	assert(~ismember('functional',cRequire) || ~isempty(s.functional),'functional data paths must be specified.');

%parse the mask data paths
	if isempty(opt.path_mask)
		if isempty(opt.dir_mask)
			cDirMask	= cellfun(@(s) conditional(isempty(s),'',DirAppend(opt.dir_data,'mask',s)),cSubject,'uni',false);
			
			s.cell_input.mask	= ~bNoCellSubject;
		else
			[cDirMask,bNoCellDir]	= ForceCell(opt.dir_mask);
			
			s.cell_input.mask	= ~bNoCellDir;
		end
		
		if ~isempty(opt.mask_variant)
			cDirMask	= cellfun(@(d) conditional(isempty(d),'',DirAppend(d,opt.mask_variant)),cDirMask,'uni',false);
		end
		
		switch strMaskType
			case 'nest'
				cPathMask	= cellfun(@(d) cellfun(@(m) conditional(isempty(d) || isempty(m),'',PathUnsplit(d,m,'nii.gz')),cMask,'uni',false),cDirMask,'uni',false);
				cNameMask	= cellfun(@(d) cellfun(@(m) m,cMask,'uni',false),cDirMask,'uni',false);
				
				s.cell_input.mask_inner	= ~bNoCellMask;
			case 'flat'
				if isempty(cMask)
					[cPathMask,cNameMask]	= deal(cell(size(cDirMask)));
				else
					if numel(cMask)==numel(cDirMask)
						cMask	= reshape(cMask,size(cDirMask));
					else
						cMask	= repto(cMask,size(cDirMask));
					end
					cPathMask	= cellfun(@(d,m) conditional(isempty(d) || isempty(m),'',PathUnsplit(d,m,'nii.gz')),cDirMask,cMask,'uni',false);
					cNameMask	= cMask;
				end
				
				s.cell_input.mask_inner	= false;
		end
	else
		if s.cell_input.functional
			s.cell_input.mask_inner	= iscell(opt.path_mask) && any(cellfun(@iscell,opt.path_mask(:)));
		else
			s.cell_input.mask_inner	= false;
		end
		
		maskLevel				= conditional(s.cell_input.functional,2,1);
		[cPathMask,bNoCellPath]	= ForceCell(opt.path_mask,'level',maskLevel);
		
		if isempty(opt.mask)
			cNameMask	= cellnestfun(@PathGetMaskName,cPathMask);
		else
			cNameMask	= opt.mask;
		end
		
		s.cell_input.mask		= ~bNoCellPath;
	end
	
	s.mask			= cPathMask;
	s.mask_name		= cNameMask;
	s.mask_session	= cellnestfun(@PathGetSession,s.mask);
	
	assert(~ismember('mask',cRequire) || ~isempty(s.mask),'mask data paths must be specified.');
