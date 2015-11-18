function [stim,ifo] = distractor(obj,varargin)
% stimulus.base.distractor
% 
% Description:	generate a distractor stimulus
% 
% Syntax: [stim,ifo] = obj.distractor([nDistractor]=1,[param1,val1,...,paramN,valN])
% 
% In:
%	nDistractor	- the number of distractors to generate
%	[paramK]	- the Kth parameter whose value should be overridden
%	[valK]		- the new explicit value of parameter paramK
% 
% Out:
%	stim	- the distractor stimulus, or a cell of stimuli if <n_distractor> is
%			  specified explicitly
%	ifo		- a struct of extra info about the stimulus, or a struct array for
%			  multiple stimuli
% 
% Updated:	2015-11-17
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
ifo	= struct;

%parse the inputs
	[nDistractor,opt]	= ParseArgs(varargin,[]);
	
	bMultiStim	= ~isempty(nDistractor);
	if ~bMultiStim
		nDistractor	= 1;
	end

%get the parameter values
	cOpt	= opt2cell(opt.opt_extra);
	param	= obj.get_parameters(cOpt{:});

%change the parameters for the distractors
	param	= obj.distract_parameters(nDistractor,param);

%generate the stimulus
	[stim,ifo]	= arrayfun(@(p) obj.generate_inner(struct('param',p)),param,'uni',false);
	
	if bMultiStim
		ifo	= cat(1,ifo{:});
	else
		stim	= stim{1};
		ifo		= ifo{1};
	end
