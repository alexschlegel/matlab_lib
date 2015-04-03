function [Y,t,g] = longitudinal(varargin)
% datagen.longitudinal
% 
% Description:	generate longitudinal data for testing
% 
% Syntax:	[Y,t,g] = datagen.longitudinal(<options>)
% 
% In:
% 	<options>:
%		subjects:			(20) the number of subjects
%		times:				(4) the number of time points
%		groups:				(2) the number of groups
%		mean:				(10) the mean measurement
%		noise_preset:		('noisy') a string specifying presets for the
%							noise options (defaults shown):
%								'perfect':	no noise
%									effect:				1
%									noise_subject:		0
%									noise_time:			0
%									noise_group:		0
%									noise_measurement:	0
%								'clean':	not much noise
%									effect:				1
%									noise_subject:		0.1
%									noise_time:			0.1
%									noise_group:		0.1
%									noise_measurement:	0.1
%								'noisy':	noisy
%									effect:				1
%									noise_subject:		0.2
%									noise_time:			0.2
%									noise_group:		0.2
%									noise_measurement:	0.2
%								'very_noisy':	very noisy
%									effect:				1
%									noise_subject:		1
%									noise_time:			0.3
%									noise_group:		1
%									noise_measurement:	1
%								'noise':	all noise
%									effect:				0
%									noise_subject:		0
%									noise_time:			0.5
%									noise_group:		0
%									noise_measurement:	1
%		effect:				(<see noise_preset>) the effect sizes (what this
%							means depends on the effect function).  either a
%							scalar to set the effect size of the last group, or
%							an array of effect sizes, one for each group.
%		effect_f:			('linear') the effect function.  either a handle
%							to a function that takes an array of times and an
%							effect size, or one of the following:
%								'linear':		linear trend
%								'quadratic':	quadratic trend
%		noise_subject:		(<see noise_preset>) the subject noise, as a
%							multiple of the mean
%		noise_time:			(<see noise_preset>) the variation in measurement
%							times
%		noise_group:		(<see noise_preset>) the group noise, as a multiple
%							of the mean
%		noise_measurement:	(<see noise_preset>) the measurement noise, as a
%							multiple of the mean
%		plot:				(false) true to plot the group trends
% 
% Out:
% 	Y	- an nSubject x nTime array of simulated measurements
%	t	- an nSubject x nTime array of measurements times
%	g	- an nSubject x 1 array of group membership
% 
% Updated: 2015-03-22
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent noise_presets

if isempty(noise_presets)
	noise_presets	= mapping;
	
	noise_presets('perfect')	= struct(...
									'effect'			, 1	, ...
									'noise_subject'		, 0	, ...
									'noise_time'		, 0	, ...
									'noise_group'		, 0	, ...
									'noise_measurement'	, 0	  ...
									);
	noise_presets('clean')		= struct(...
									'effect'			, 1		, ...
									'noise_subject'		, 0.1	, ...
									'noise_time'		, 0.1	, ...
									'noise_group'		, 0.1	, ...
									'noise_measurement'	, 0.1	  ...
									);
	noise_presets('noisy')		= struct(...
									'effect'			, 1		, ...
									'noise_subject'		, 0.2	, ...
									'noise_time'		, 0.2	, ...
									'noise_group'		, 0.2	, ...
									'noise_measurement'	, 0.2	  ...
									);
	noise_presets('very_noisy')	= struct(...
									'effect'			, 1		, ...
									'noise_subject'		, 1	, ...
									'noise_time'		, 0.3	, ...
									'noise_group'		, 1	, ...
									'noise_measurement'	, 1		  ...
									);
	noise_presets('noise')		= struct(...
									'effect'			, 0		, ...
									'noise_subject'		, 0		, ...
									'noise_time'		, 0.5	, ...
									'noise_group'		, 0		, ...
									'noise_measurement'	, 1		  ...
									);
end

%parse the inputs
	opt	= ParseArgs(varargin,...
			'subjects'			, 20		, ...
			'times'				, 4			, ...
			'groups'			, 2			, ...
			'mean'				, 10		, ...
			'noise_preset'		, 'noisy'	, ...
			'effect'			, []		, ...
			'effect_f'			, 'linear'	, ...
			'noise_subject'		, []		, ...
			'noise_time'		, []		, ...
			'noise_group'		, []		, ...
			'noise_measurement'	, []		, ...
			'plot'				, false		  ...
			);
	
	opt.noise_preset	= CheckInput(opt.noise_preset,'noise preset',noise_presets.domain);
	
	cOptNoise	= opt2cell(noise_presets(opt.noise_preset));
	opt			= optadd(opt,cOptNoise{:});

if isscalar(opt.effect)
	opt.effect	= [zeros(opt.groups-1,1); opt.effect];
end
if ischar(opt.effect_f)
	opt.effect_f	= CheckInput(opt.effect_f,'effect function',{'linear','quadratic'});
	
	opt.effect_f	= switch2(opt.effect_f,...
						'linear'	, @(t,e) e.*t		, ...
						'quadratic'	, @(t,e) e.*t.^2	  ...
						);
end


%subject stuff
	sNoiseM	= opt.mean*opt.noise_subject;
	sNoise	= randBetween(-sNoiseM,sNoiseM,[opt.subjects 1]);
	SNoise	= repmat(sNoise,[1 opt.times]);
%generate the groups
	gSet	= repmat((0:opt.groups-1),[ceil(opt.subjects/opt.groups) 1]);
	g		= randFrom(gSet,[opt.subjects 1]);
	
	if opt.groups==2
		g	= logical(g);
	end
	
	gRep	= repmat(g,[1 opt.times]);
	gNoiseM	= opt.mean*opt.noise_group;
	gNoise	= randBetween(-gNoiseM,gNoiseM,[opt.groups 1]);
	GNoise	= gNoise(gRep+1);
%generate the times
	t	= repmat(0:opt.times-1,[opt.subjects 1]) + randBetween(-opt.noise_time,opt.noise_time,[opt.subjects opt.times]);
	
	mNoiseM	= opt.mean*opt.noise_measurement;
	MNoise	= randBetween(-mNoiseM,mNoiseM,[opt.subjects opt.times]);
%generate the data
	Y	= opt.mean + SNoise + GNoise + MNoise + opt.effect_f(t,opt.effect(gRep+1));

if opt.plot
	cLegend	= arrayfun(@(k) ['group ' num2str(k-1)],1:opt.groups,'UniformOutput',false);
	
	%group mean
		mY	= arrayfun(@(k) nanmean(Y(g==k-1,:),1),1:opt.groups,'UniformOutput',false);
		seY	= arrayfun(@(k) nanstderr(Y(g==k-1,:),0,1),1:opt.groups,'UniformOutput',false);
	
		h1	= alexplot(0:opt.times-1,mY,...
				'error'		, seY			, ...
				'xlabel'	, 'time'		, ...
				'ylabel'	, 'measurement'	, ...
				'legend'	, cLegend		  ...
				);
	%scatter
		scT	= arrayfun(@(k) t(g==k-1,:),1:opt.groups,'UniformOutput',false);
		scY	= arrayfun(@(k) Y(g==k-1,:),1:opt.groups,'UniformOutput',false);
		
		h2	= alexplot(scT,scY,...
				'xlabel'	, 'time'		, ...
				'legend'	, cLegend		, ...
				'type'		, 'scatter'		  ...
				);
	
	%combine
		h	= multiplot({h1,h2});
end
