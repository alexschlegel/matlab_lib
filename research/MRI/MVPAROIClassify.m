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
%	res = MVPAROIClassify(...
%			'dir_data'			, strDirData	, ...
%			'subject'			, cSubject		, ...
%			'mask'				, cMask			, ...
%			'targets'			, cTarget		, ...
%			'chunks'			, kChunk		, ...
%			'spatiotemporal'	, true			, ...
%			'target_blank'		, 'Blank'		, ...
%			'dir_out'			, strDirOut		, ...
%			'cores'				, 11			  ...
%			);
% 
% Updated: 2015-12-09
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
param	= optstruct(struct,struct);

vargin	= optadd(varargin,...
			'type'	, 'roiclassify'	  ...
			);

res	= MVPAROIClassifyHelper(param,vargin{:});
