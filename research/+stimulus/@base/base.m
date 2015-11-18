classdef base < handle
% stimulus.base
% 
% Description:	base class for stimulus generating classes
% 
% Syntax: obj = stimulus.base([param1,val1,...,paramN,valN])
% 
% Methods:
%	generate:	generate a stimulus
%	distractor:	generate a distractor stimulus
%	validate:	validate a set of parameter values
% 
% Properties:
%	param:	a property collection of parameters that the generator function will
%			use to generate the stimulus. includes:
%			d:	(0.25) the difficulty of the stimulus to generate. ranges from 0
%				to 1. at stimulus generation, this will be used to determine the
%				value of the difficulty-linked parameter, if one is specified
%				for the stimulus class.
%			exclude: (struct) a struct specifying the values to exclude when
%				choosing parameter values. e.g. if a stimulus class includes a
%				parameter called 'orientation' that is chosen at random from a
%				list of values if no orientation is specified, then setting
%				<exclude> to struct('orientation',3) would specify that a random
%				orientation should be chosen, but excluding 3 as a possible
%				value.
%			seed: (<randseed2>) the seed to use for randomizing, or false to
%				skip seeding the random number generator
% 
% In:
%	[paramK]	- the Kth parameter whose value should be set explicitly
%	[valK]		- the explicit value of parameter paramK (or empty to skip
%				  skip setting the value)
% 
% Updated:	2015-11-17
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%PROPERTIES---------------------------------------------------------------------
	%READ-ONLY
		properties (SetAccess=protected, GetAccess=public)
			param					= [];
			difficulty_param		= [];
			difficulty_param_min	= 0;
			difficulty_param_max	= 1;
			difficulty_param_round	= false;
		end
%/PROPERTIES--------------------------------------------------------------------

%METHODS------------------------------------------------------------------------
	%CONSTRUCTOR
		methods (Access=public)
			function obj = base(varargin)
				obj = obj@handle();
				
				%initialize the parameter collection
					obj.param	= stimulus.property.collection;
				
				%set some parameter defaults
					add(obj.param,'d','generic',{0.25});
					add(obj.param,'exclude','generic',{struct});
					add(obj.param,'seed','generic',{@() randseed2});
				
				%parse the inputs
					obj.parseInputs(varargin{:});
			end
		end
	
	%PRIVATE
		methods (Access=protected)
			function parseInputs(obj,varargin)
				cParam	= varargin(1:2:end);
				cVal	= varargin(2:2:end);
				nParam	= numel(cParam);
				
				for kP=1:nParam
					if ~isempty(cVal{kP})
						add(obj.param,cParam{kP},'generic',{cVal{kP}});
					end
				end
			end
			
			[stim,ifo] = generate_inner(obj,ifo)
			ifo = get_parameters(obj)
		end
%/METHODS-----------------------------------------------------------------------

end
