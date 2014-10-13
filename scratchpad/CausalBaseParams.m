% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef CausalBaseParams
	% CausalBaseParams:  Base parameters for causal flow
	%   TODO: Add detailed comments

	properties
		noisiness
		numTimeSteps
		numFuncSigs
		numVoxelSigs
		numTopComponents
	end
	methods
		function obj = CausalBaseParams
			obj = obj.defineInitialParams;
			obj.validate;
		end
		function obj = defineInitialParams(obj)
			obj.noisiness = 1.0e-6;
			obj = obj.defineSizeParams;
		end
		function obj = defineSizeParams(obj)
			obj = obj.defineStandardSizeParams;
		end
		function obj = defineStandardSizeParams(obj)
			obj.numTimeSteps = 1000;
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
		function b = eq(obj1,obj2)
			b = isequal(obj1,obj2);
		end
		function b = ne(obj1,obj2)
			b = ~eq(obj1,obj2);
		end
		function validate(obj)
			%TODO: Automatically validate on assignment to
			% numTopComponents or numFuncSigs?
			if obj.numTopComponents > obj.numFuncSigs
				error('Num top components exceeds num func sigs.');
			end
		end
		function validateW(obj,W)
			obj.validate;
			nf = obj.numFuncSigs;
			if size(W) ~= [nf nf]
				error('W size is incompatible with CausalBaseParams.');
			end
		end
	end
end
