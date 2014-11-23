% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef CausalBaseParams
	% CausalBaseParams:  Base parameters for causal flow
	%   TODO: Add detailed comments

	properties
		sourceNoisiness
		destNoisiness
		numTimeSteps
		numFuncSigs
		numVoxelSigs
		numTopComponents
	end
	methods
		function obj = CausalBaseParams(varargin)
			obj = obj.defineInitialParams(varargin{:});
			obj.validate;
		end
		function obj = defineInitialParams(obj,varargin)
			[opt,optcell] = Opts.getOpts(varargin);
			obj.sourceNoisiness		= opt.sourceNoisiness;
			obj.destNoisiness		= opt.destNoisiness;
			obj.numTimeSteps		= opt.numTimeSteps;
			obj.numFuncSigs			= opt.numFuncSigs;
			obj.numVoxelSigs		= opt.numVoxelSigs;
			obj.numTopComponents	= opt.numTopComponents;
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
