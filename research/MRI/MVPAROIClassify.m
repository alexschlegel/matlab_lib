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
%			'dir_out'			, strDirOut		, ...
%			'nthread'			, 11			  ...
%			);
% 
% Updated: 2015-03-27
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
						'ParseROIs'			, @ParseROIs		, ...
						'ParseMaskLabel'	, @ParseMaskLabel	  ...
						)...
			);

vargin	= optadd(varargin,...
			'type'	, 'roiclassify'	  ...
			);

res	= MVPAROIClassifyHelper(s,vargin{:});

%------------------------------------------------------------------------------%
function [cPathDataROI,cNameROI,sMaskInfo] = ParseROIs(sPath)
	cPathDataROI	= sPath.functional_roi;
	
	cSession	= sPath.functional_session;
	cNameROI	= cellfun(@GetROINames,sPath.functional_session,sPath.mask_name,'uni',false);
	
	sMaskInfo	= struct(...
					'name'	, {sPath.mask_name{1}}	  ...
					);
%------------------------------------------------------------------------------%
function cNameROI = GetROINames(strSession,cNameMask)
	cNameROI	= cellfun(@(m) GetROIName(strSession,m),cNameMask,'uni',false);
%------------------------------------------------------------------------------%
function strNameROI = GetROIName(strSession,strNameMask) 
	strNameROI	= sprintf('%s-%s',strSession,strNameMask);
%------------------------------------------------------------------------------%
function cMask = ParseMaskLabel(sMaskInfo)
	cMask	= reshape(sMaskInfo.name,[],1);
%------------------------------------------------------------------------------%
