function res = MVPAROIDCClassify(varargin)
% MVPAROIDCClassify
% 
% Description:	perform an ROI directed connectivity analysis, in which
%				classification is performed on directed connectivity (DC)
%				patterns from one ROI to another. PCA (via FSL's MELODIC) is
%				performed on each ROI's dataset first, in order to control the
%				size of feature spaces. DC classification is performed for every
%				pair in the set of specified masks.
% 
% Syntax:	res = MVPAROIDCClassify(<options>)
% 
% In:
% 	<options>:
%		<+ options for MRIParseDataPaths>
%		<+ options for FSLMELODIC/fMRIROI>
%		<+ options for MVPAClassify>
%		melodic:	(true) true to perform MELODIC on the extracted ROIs before
%					classification
%		comptype:	('pca') (see FSLMELODIC)
%		dim:		(10) (see FSLMELODIC)
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
%	res = MVPAROIDCClassify(...
%			'dir_data'			, strDirData	, ...
%			'subject'			, cSubject		, ...
%			'mask'				, cMask			, ...
%			'targets'			, cTarget		, ...
%			'chunks'			, kChunk		, ...
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
						'dim'	, 10	  ...
						),...
		'opt'		, struct(...
						'mvpa'	, struct(...
									'dcclassify'	, true	   ...
									)...
						),...
		'f'			, struct(...
						'ParseROIs'			, @ParseROIs		, ...
						'ParseMaskLabel'	, @ParseMaskLabel	  ...
						)...
			);

vargin	= optadd(varargin,...
			'type'	, 'roidcclassify'	  ...
			);

res	= MVPAROIClassifyHelper(s,vargin{:});

%------------------------------------------------------------------------------%
function [cPathDataROI,cNameROI,sMaskInfo] = ParseROIs(sPath)
%construct every unidirectional pair of ROIs
	cSession					= sPath.functional_session;
	[cPathDataROI,cNameMask]	= varfun(@(x) ForceCell(x,'level',2),sPath.functional_roi,sPath.mask_name);
	
	[cPathDataROI,kShake]	= cellfun(@(cf) handshakes(cf,'ordered',true),cPathDataROI,'uni',false);
	cNameROI				= cellfun(@(s,cm,ks) arrayfun(@(k) sprintf('%s-%s-%s',s,cm{ks(k,:)}),(1:size(ks,1))','uni',false),cSession,cNameMask,kShake,'uni',false);
	
	sMaskInfo	= struct(...
					'name'	, {cNameMask{1}}	, ...
					'shake'	, {kShake{1}}		  ...
					);
%------------------------------------------------------------------------------%
function cMask = ParseMaskLabel(sMaskInfo)
	cMask	= reshape(sMaskInfo.name,1,[]);
	cMask	= cMask(sMaskInfo.shake);
%------------------------------------------------------------------------------%
