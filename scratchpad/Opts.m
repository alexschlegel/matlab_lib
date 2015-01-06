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
				'lizierNorm'			, true		, ...
				... % To override both 'noiseAtDest' and 'noiseAtSource'
				... % with the same value, just override 'noise' (which
				... % is handled by propagateNoiseOverride below).
				'noiseAtDest'			, 1.0e-6	, ...
				'noiseAtSource'			, 1.0e-6	, ...
				'recurStrength'			, 0.8		, ...
				'voxelFreedom'			, 1.000		, ...
				'zScoreSigs'			, false		  ...
			};
		end
		function optcell = getDefaultSimParams
			optcell = {...
				'iterations'		, 1			, ...
				'maxWOnes'			, 4			, ...
				'outlierPercentage'	, 5			, ...
				'pcaPolicy'			, 'skipPCA'	, ...
				... %'pcaPolicy'			, 'runPCA'	, ...
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
			conflict = false;
			namesA = fieldnames(optStructA);
			for i = 1:numel(namesA)
				name = namesA{i};
				if strcmp(name,'opt_extra')
					continue;
				end
				if isfield(optStructB,name)
					valA = optStructA.(name);
					valB = optStructB.(name);
					if (isfloat(valA) || islogical(valA)) && ...
							(isfloat(valB) || islogical(valB))
						conflict = (valA ~= valB);
					elseif ischar(valA) && ischar(valB)
						conflict = ~strcmp(valA,valB);
					elseif isfloat(valA) || islogical(valA) || ischar(valA)
						conflict = true;
					else
						error('Unsupported opt data type %s',class(valA));
					end
				end
				if conflict
					break;
				end
			end
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
			optvar = Opts.propagateNoiseOverride(optvar);
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
		function optcell = propagateNoiseOverride(optcell)
			noiseKeyOrdinal = find(strcmp(optcell(1:2:end),'noise'));
			if numel(noiseKeyOrdinal) > 1
				error('Multiple noise keys');
			end
			if ~isempty(noiseKeyOrdinal)
				valueIndex = 2*noiseKeyOrdinal;
				keyIndex = valueIndex-1;
				noiseVal = optcell{valueIndex};
				optcell = [optcell(1:(keyIndex-1)) ...
					{'noiseAtDest',noiseVal,'noiseAtSource',noiseVal} ...
					optcell((valueIndex+1):end)];
			end

		end
	end
end
