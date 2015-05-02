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
%		cores:		(1) the number of processor cores to use
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
%			'dir_out'			, strDirOut		, ...
%			'cores'				, 11			  ...
%			);
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
param	= struct(...
			'default'		, struct('dim',10)	, ...
			'opt'			, struct(...
								'mvpa'	, struct(...
											'dcclassify'	, true	   ...
											)...
								),...
			'parseInput'	, @ParseInput	  ...
			);

vargin	= optadd(varargin,...
			'type'	, 'roidcclassify'	  ...
			);

res	= MVPAROIClassifyHelper(param,vargin{:});

%------------------------------------------------------------------------------%
function sData = ParseInput(sPath)
	%construct every pair of ROIs
		[sData.cPathDataROI,kShake]	= cellfun(@(cf) handshakes(cf,'ordered',true),sPath.functional_roi,'uni',false);
	%wrap each pair in a cell
		sData.cPathDataROI	= cellfun(@(cROI) mat2cell(cROI,ones(size(cROI,1),1),2),sData.cPathDataROI,'uni',false);
	%ROI names
		sData.cNameROI	= cellfun(@GetROINames,sPath.functional_session,sPath.mask_name,kShake,'uni',false);
	
	cMask		= reshape(sPath.mask_name{1},1,[]);
	sData.cMask	= cMask(kShake{1});
%------------------------------------------------------------------------------%
function cNameROI = GetROINames(strSession,cNameMask,kShake)
	kPair		= reshape(1:size(kShake,1),[],1);
	cNameROI	= arrayfun(@(k) GetROIName(strSession,cNameMask,kShake(k,:)),kPair,'uni',false);
%------------------------------------------------------------------------------%
function strNameROI = GetROIName(strSession,cNameMask,kPair) 
	strNameROI	= sprintf('%s-%s-%s',strSession,cNameMask{kPair});
%------------------------------------------------------------------------------%
