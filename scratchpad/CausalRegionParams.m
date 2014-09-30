% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef CausalRegionParams
	% CausalRegionParams:  Per-region, per-trial parameters for causal flow
	%   TODO: Add detailed comments

	properties
		baseParams
		recurDiagonal
		noiseWeights
		voxelMixer
	end

	methods
		function obj = CausalRegionParams(baseParams)
			obj.baseParams = baseParams;
			obj = obj.initTrialParams;
		end
		function sample = applyRecurrence(obj,prevSample)
			sample = diag(obj.recurDiagonal) * prevSample + ...
				SimStatic.makeNoise(obj.noiseWeights);
		end
		function obj = initTrialParams(obj)
			nf = obj.baseParams.numFuncSigs;
			nv = obj.baseParams.numVoxelSigs;
			noisiness = obj.baseParams.noisiness;
			[alpha, beta] = SimStatic.generateRandomAddends(ones(nf,1));
			obj.recurDiagonal = (1 - noisiness) + (noisiness * alpha);
			obj.noiseWeights = noisiness * beta;
			obj.voxelMixer = randn(nf,nv);
		end
		function [obj,splitoff] = splitRecurDiagonal(obj)
			[obj.recurDiagonal,splitoff] = ...
				SimStatic.generateRandomAddends(obj.recurDiagonal);
		end
	end
end
