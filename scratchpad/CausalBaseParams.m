% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef CausalBaseParams
	% CausalBaseParams:  Base parameters for causal flow
	%   TODO: Add detailed comments

	properties
		numTimeSteps
	end
	properties (SetAccess = private)
		noisiness
		numFuncSigs
		numVoxelSigs
		numTopComponents
		sourceToDestWeights
	end

	methods
		function obj = CausalBaseParams(noisiness)
			obj.noisiness = noisiness;
			obj = obj.defineInitialParams;
		end
		function obj = defineInitialParams(obj)
			obj = obj.defineSizeParams;
			obj.sourceToDestWeights = obj.generateSourceToDestWeights;
		end
		function obj = defineSizeParams(obj)
			obj = obj.defineStandardSizeParams;
		end
		function obj = defineStandardSizeParams(obj)
			obj.numTimeSteps = 100;
			obj.numFuncSigs = 10;
			obj.numVoxelSigs = 500;
			obj.numTopComponents = 10;
		end
		function obj = defineTinySizeParams(obj)
			obj.numTimeSteps = 10;
			obj.numFuncSigs = 3;
			obj.numVoxelSigs = 5;
			obj.numTopComponents = 3;
		end
		function W = generateSourceToDestWeights(obj)
			nf = obj.numFuncSigs;
			W = zeros(nf);
			for i = 1:nf
				rawRow = randn(1,nf);
				% Normalize rawRow so absolute sum across row equals 1
				absSum = sum(abs(rawRow));
				if absSum > 0
					W(i,:) = rawRow / absSum;
				else
					% Sum of raw row is zero (extremely unlikely under
					% current assumptions, but better safe than sorry)
					W(i,:) = ones(1,nf) / nf;
				end
			end
		end
	end
end
