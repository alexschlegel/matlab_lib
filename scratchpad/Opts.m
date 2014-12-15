% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef Opts
	% Opts:  Options for causal simulator
	%   TODO: Add detailed comments

	properties
	end

	methods (Static)
		function optcell = getDefaultBaseParams
			optcell = {...
				'numFuncSigs'		, 10		, ...
				'numTimeSteps'		, 1000		, ...
				'numTopComponents'	, 10		, ...
				'numVoxelSigs'		, 500		  ...
			};
		end
		function optcell = getDefaultSignalParams
			optcell = {...
				'auxWPolicy'			, 'beta'	, ...
				... %'auxWPolicy'			, 'not'		, ...
				... %'auxWPolicy'			, 'row'		, ...
				... %'auxWPolicy'			, 'col'		, ...
				... %'auxWPolicy'			, 'det'		, ...
				... %'auxWPolicy'			, 'row:abs'	, ...
				... %'auxWPolicy'			, 'col:abs'	, ...
				... %'auxWPolicy'			, 'det:rel'	, ...
				'auxWWeight'			, 1.0		, ...
				'isDestBalancing'		, false		, ...
				'noisinessForDest'		, 1.0e-6	, ...
				'noisinessForSource'	, 1.0e-6	, ...
				'recurStrength'			, 0.8		, ...
				'voxelFreedom'			, 1.000		  ...
			};
		end
		function optcell = getDefaultSimParams
			optcell = {...
				'iterations'		, 1			, ...
				'maxWOnes'			, 4			, ...
				'outlierPercentage'	, 5			, ...
				... %'pcaPolicy'			, 'runPCA'	, ...
				'pcaPolicy'			, 'skipPCA'	, ...
				'rngSeedBase'		, 0			  ...
			};
		end
		function [opt,optcell] = getOptDefaults
			baseParams = Opts.getDefaultBaseParams;
			signalParams = Opts.getDefaultSignalParams;
			simParams = Opts.getDefaultSimParams;

			optcell = { ...
				baseParams{:} ...
				signalParams{:} ...
				simParams{:} ...
			}; %#ok
			opt = struct(optcell{:});
		end
		function [opt,optcell] = getOpts(optvar,varargin)
			[~,defaultDefaults] = Opts.getOptDefaults;
			[~,newDefaults] = ...
				Opts.getOptsInternal(defaultDefaults,varargin);
			[opt,optcell] = ...
				Opts.getOptsInternal(newDefaults,optvar);
		end
		function conflict = optConflict(optStructA,optStructB)
			% TODO: Need to implement; for now, forgive conflicts
			namesA = fieldnames(optStructA);
			for i = 1:numel(namesA)
				name = namesA{i};
				if isfield(optStructB,name)
					valA = optStructA.(name);
					valB = optStructB.(name);
					% TODO: Add code to compare valA, valB;
					% consider, at a minimum, float and char values
				end
			end
			conflict = false;
		end
		function validate(opt)
			if opt.numTopComponents > opt.numFuncSigs
				error('Num top components exceeds num func sigs.');
			end
		end
		function validateW(opt,W)
			Opts.validate(opt);
			nf = opt.numFuncSigs;
			if any(size(W) ~= [nf nf])
				error('W size is incompatible with numFuncSigs.');
			end
		end
	end
	methods (Static, Access = private)
		function [opt,optcell] = getOptsInternal(defaults,optvar)
			if isstruct(defaults)
				defaults = opt2cell(defaults);
			end
			if isstruct(optvar)
				optvar = opt2cell(optvar);
			end
			overriddenKeys = optvar(1:2:end);
			if ~all(cellfun(@(x) ischar(x), overriddenKeys))
				error('Malformed options variable.');
			end
			validKeys = defaults(1:2:end);
			if ~all(ismember(overriddenKeys,validKeys))
				error('Invalid option name.');
			end
			opt = ParseArgs(optvar,defaults{:});
			optcell = opt2cell(opt);
		end
	end
end
