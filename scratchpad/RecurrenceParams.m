% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef RecurrenceParams
	% RecurrenceParams:  Parameters for causal flow recurrence
	%   TODO: Add detailed comments
	%
	% Signal indices are
	%   1. Source
	%   2. Dest
	%   3. Non-source (hidden) causal region

	properties
		baseParams
		recurDiagonals
		W
		nonsourceW
	end
	methods
		% isDestBalancing is in process of changing from a boolean
		% to a continuous parameter from 0 to 2 (later on, 0 to 1):
		% 0 = zero nonsourceW
		% 1 = nonsourceW equal to W
		% 2 = nonsourceW only, zero W
		function obj = RecurrenceParams(baseParams,W,varargin)
			[opt,optcell] = Opts.getOpts(varargin); %#ok
			nf = baseParams.numFuncSigs;
			obj.baseParams = baseParams;
			obj.recurDiagonals = repmat(...
				{opt.recurStrength * ones(1,nf)},3,1);
			beta = opt.isDestBalancing / 2;
			alpha = 1 - beta;
			obj.W = alpha * W;
			obj.nonsourceW = beta * W;
		end
	end
end
