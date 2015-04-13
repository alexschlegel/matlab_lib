function d = fmri(varargin)
% datagen.fmri
% 
% Description:	generate simulated fMRI data
% 
% Syntax:	d = fmri(<options>)
% 
% In:
% 	<options>:
%		design:				('block') the experimental design type. only 'block'
%							is supported.
%		conditions:			(2) the number of conditions, or a cell of condition
%							names
%		block_duration:		(10) the duration of each experimetal block, in TRs
%		rest_duration:		(10) the duration of each interleaving rest period,
%							in TRs
%		reps:				(4) the number of repetitions of each condition to
%							include in each run
%		runs:				(10) the number of runs to simulate
%		space:				(100) a size array specifying the size of the data
%							space (i.e. number of features)
%		effect_type:		('univariate') the type of effect to simulate. one
%							of or a cell of the following:
%								'univariate': simulate a mean activity
%									difference between conditions
%								'multivariate': simulate a pattern difference
%									between conditions
%		effect_size:		(2) the signal to noise ratio of the effect
%		effect_fraction:	(0.5) the fraction of feature in which to insert the
%							effect
%		mean:				(1000) the mean baseline signal value
%		mean_effect:		(20) the base mean for the effect
%		chunk:				('run') the type of chunking to use (for the
%							attributes file). one of the following:
%								'run': chunk by run
%								'block': chunk by block
%		subject				('test') the subject code
%		output_dir:			(<none>) a directory in which to save the simulated
%							data. if specified, saves a (space) x [1 x 1] x
%							(nTR) 4D NIfTI dataset and an attributes file.
% 
% Out:
% 	d	- a struct of simulated data and associated information
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'design'			, 'block'		, ...
			'conditions'		, 2				, ...
			'block_duration'	, 10			, ...
			'rest_duration'		, 10			, ...
			'reps'				, 4				, ...
			'runs'				, 10			, ...
			'space'				, 100			, ...
			'effect_type'		, 'univariate'	, ...
			'effect_size'		, 2				, ...
			'effect_fraction'	, 0.5			, ...
			'mean'				, 1000			, ...
			'mean_effect'		, 20			, ...
			'chunk'				, 'run'			, ...
			'subject'			, 'test'		, ...
			'output_dir'		, []			  ...
			);
	
	opt.design	= CheckInput(opt.design,'design',{'block'});
	
	if isscalar(opt.conditions)
		opt.conditions	= arrayfun(@(c) sprintf('C%d',c),(1:opt.conditions)','uni',false);
	end
	opt.conditions	= ForceCell(opt.conditions);
	
	if isscalar(opt.space)
		opt.space	= [opt.space 1];
	end
	
	opt.effect_type	= ForceCell(opt.effect_type);
	opt.effect_type	= cellfun(@(et) CheckInput(et,'effect_type',{'univariate','multivariate'}),opt.effect_type,'uni',false);
	
	opt.chunk	= CheckInput(opt.chunk,'chunk',{'run','block'});
	
	d	= struct('param',opt);
	
%generate the data
	switch opt.design
		case 'block'
			d	= GenerateData_Block(d);
	end

%save the data and attributes
	if ~isempty(d.param.output_dir)
		d	= SaveData(d);
		d	= SaveAttributes(d);
	end


%------------------------------------------------------------------------------%
function d = GenerateData_Block(d)
	%experiment design
		nCondition	= numel(d.param.conditions);
		
		d.design.block	= blockdesign(1:nCondition,d.param.reps,d.param.runs);
		
		ev			= arrayfun(@(r) block2ev(d.design.block(r,:),d.param.block_duration,d.param.rest_duration),1:d.param.runs,'uni',false);
		d.design.ev	= cat(1,ev{:});
		
		d.design.event	= ev2event(d.design.ev);
		
		d.design.target	= ev2target(d.design.ev,d.param.conditions);
		
		nEvent	= size(d.design.event,1);
		durRun	= size(d.design.ev,1)/d.param.runs;
		durExp	= size(d.design.ev,1);
		
		d.t	= reshape(1:durExp,[],1);
	%chunks
		switch d.param.chunk
			case 'run'
				d.design.chunk	= reshape(repmat(1:d.param.runs,[durRun 1]),[],1);
			case 'block'
				d.design.chunk	= sum(d.design.ev.*repmat(1:nEvent,[durRun 1]),2);
		end
	
	%mean value
		nFeature	= prod(d.param.space);
		xMean		= repmat(d.param.mean + randn(1,nFeature)*d.param.mean/10,[durExp 1]);
	%effect
		%choose the features in which to insert the effect
			nFeatureEffect	= round(d.param.effect_fraction*nFeature);
			kFeatureEffect	= randomize((1:nFeature))';
			kFeatureEffect	= kFeatureEffect(1:nFeatureEffect);
		
		mEffect		= d.param.mean_effect*sqrt(nFeature)/nFeatureEffect;
		cXEffect	= {};
		
		if ismember('univariate',d.param.effect_type)
			xEffectCur	= zeros(durExp,nFeatureEffect);
			for kC=1:nCondition
				bBlock	= d.design.ev(:,kC)==1;
				
				xEffectCur(bBlock,:)	= xEffectCur(bBlock,:) + kC*mEffect;
			end
			
			cXEffect{end+1}	= xEffectCur;
		end
		
		if ismember('multivariate',d.param.effect_type)
			%generate a pattern for each condition
				pat	= mEffect*randn(nCondition,nFeatureEffect);
			%make sure each pattern has zero mean
				pat	= pat - repmat(mean(pat,2),[1 nFeatureEffect]);
			
			xEffectCur	= zeros(durExp,nFeatureEffect);
			for kC=1:nCondition
				bBlock	= d.design.ev(:,kC)==1;
				dur		= sum(bBlock);
				
				xPattern				= repmat(pat(kC,:),[dur 1]);
				xEffectCur(bBlock,:)	= xEffectCur(bBlock,:) + xPattern;
			end
			
			cXEffect{end+1}	= xEffectCur;
		end
		
		xEffect						= zeros(durExp,nFeature);
		xEffect(:,kFeatureEffect)	= sum(cat(3,cXEffect{:}),3);
	%noise
		mNoise	= d.param.mean_effect/d.param.effect_size;
		xNoise	= mNoise*randn(durExp,nFeature);
	
	d.part	= struct(...
				'mean'		, xMean		, ...
				'effect'	, xEffect	, ...
				'noise'		, xNoise	  ...
				);
	
	d.data	= reshape(xMean + xEffect + xNoise, [durExp d.param.space]);
%------------------------------------------------------------------------------%
function d = SaveData(d)
	data	= d.data;
	sz		= size(data);
	nd		= numel(sz);
	
	%permute the time dimension to the end
		data	= permute(data,[nd 1:nd-1]);
		sz		= sz([end 1:end-1]);
	%make sure we have a 4D array
		if nd<4
			sz		= [sz(1:end-1) ones(1,4-nd) sz(end)];
			nd		= 4;
			data	= reshape(data,sz);
		end
	
	%make the NII struct
		nii	= NIfTI.Create(data);
	
	%save it
		d.path.data	= PathUnsplit(d.param.output_dir,d.param.subject,'nii.gz');
		NIfTI.Write(nii,d.path.data);
%------------------------------------------------------------------------------%
function d = SaveAttributes(d)
	d.path.attr	= PathUnsplit(d.param.output_dir,d.param.subject,'attr');
	
	attr.target	= d.design.target;
	attr.chunk	= d.design.chunk;
	
	strAttr	= struct2table(attr,'heading',false);
	
	fput(strAttr,d.path.attr);
%------------------------------------------------------------------------------%
