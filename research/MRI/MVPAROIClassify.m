function res = MVPAROIClassify(varargin)
% MVPAROIClassify
% 
% Description:	perform an ROI classification analysis. PCA (via FSL's MELODIC)
%				is optionally performed on each ROI's dataset first.
% 
% Syntax:	res = MVPAROIClassify(<options>)
% 
% In:
% 	<options>:
%		<+ options for MRIParseDataPaths>
%		<+ options for FSLMELODIC/fMRIROI>
%		<+ options for MVPAClassify>
%		melodic:	(true) true to perform MELODIC on the extracted ROIs before
%					classification
%		comptype:	('pca') (see FSLMELODIC)
%		targets:	(<required>) a cell specifying the target for each sample,
%					or a cell of cells (one for each dataset)
%		chunks:		(<required>) an array specifying the chunks for each sample,
%					or a cell of arrays (one for each dataset)
%		nthread:	(1) the number of threads to use
%		force:		(true) true to force classification if the outputs already
%					exist
%		force_pre:	(false) true to force preprocessing steps if the output
%					already exists
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	res	- a struct of results (see MVPAClassify)
%
% Example:
%	cMask	= {'dlpfc';'occ';'ppc'};
%	res = MVPAROIClassify(...
%			'dir_data'			, strDirData	, ...
%			'subject'			, cSubject		, ...
%			'mask'				, cMask			, ...
%			'targets'			, cTarget		, ...
%			'chunks'			, kChunk		, ...
%			'spatiotemporal'	, true			, ...
%			'target_blank'		, 'Blank'		, ...
%			'output_dir'		, strDirOut		, ...
%			'nthread'			, 11			  ...
%			);
% 
% Updated: 2015-03-25
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
s	= struct(...
		'default'	, struct(...
						'dim'	, []	  ...
						),...
		'opt'		, struct(...
						'mvpa'	, struct	  ...
						),...
		'f'			, struct(...
						'ParseROIs'	, @ParseROIs	  ...
						)...
			);

vargin	= optadd(varargin,...
			'type'	, 'roiclassify'	  ...
			);

res	= MVPAROIClassifyHelper(s,vargin{:});

%------------------------------------------------------------------------------%
function [cPathDataROI,cNameROI,sMaskInfo] = ParseROIs(sPath)
	cSession					= sPath.functional_session;
	[cPathDataROI,cNameMask]	= varfun(@(x) ForceCell(x,'level',2),sPath.functional_roi,sPath.mask_name);
	
	cNameROI	= cellfun(@(s,cm) cellfun(@(m) sprintf('%s-%s',s,m),cm,'uni',false),cSession,cNameMask,'uni',false);
	
	sMaskInfo	= struct(...
					'name'	, {cNameMask{1}}	  ...
					);
%------------------------------------------------------------------------------%
function cMask = ParseMaskLabel(sMaskInfo)
	cMask	= reshape(cMaskInfo.name,[],1);
%------------------------------------------------------------------------------%
