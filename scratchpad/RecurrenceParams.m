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
			[opt,optcell] = Opts.getOpts(varargin);
			nf = baseParams.numFuncSigs;
			obj.baseParams = baseParams;
			obj.recurDiagonals = repmat(...
				{opt.recurStrength * ones(1,nf)},3,1);
			switch opt.auxWPolicy
				case 'beta'
					obj = obj.genAlphaBetaW(W,optcell{:});
				otherwise
					obj.W = W;
					obj = obj.genAuxW(optcell{:});
			end
		end
		function obj = genAlphaBetaW(obj,W,varargin)
			[opt,optcell] = Opts.getOpts(varargin); %#ok
			beta = opt.isDestBalancing / 2;
			alpha = 1 - beta;
			obj.W = alpha * W;
			obj.nonsourceW = beta * W;
		end
		function obj = genAuxW(obj,varargin)
			[opt,optcell] = Opts.getOpts(varargin); %#ok
			% TODO: Use split() here instead of regexprep:
			policyStem = regexprep(opt.auxWPolicy,':.*$','');
			policySuffix = regexprep(opt.auxWPolicy,'^[^:]*','');
			switch policySuffix
				case ''
					isRelative = ~strcmp(policyStem,'det');
				case ':abs'
					isRelative = false;
				case ':rel'
					isRelative = true;
				otherwise
					error('Invalid auxWPolicy suffix "%s".',policySuffix);
			end
			randAuxW = randn(size(obj.W));
			switch policyStem
				case 'not'
					obj.nonsourceW = ...
						RecurrenceParams.generateComplementaryAuxW(...
							opt.auxWPolicy,opt.auxWWeight,obj.W);
				case 'row'
					obj.nonsourceW = ...
						RecurrenceParams.normalizeAuxWByRowOrCol(...
							randAuxW,2,opt.auxWWeight,isRelative,obj.W);
				case 'col'
					obj.nonsourceW = ...
						RecurrenceParams.normalizeAuxWByRowOrCol(...
							randAuxW,1,opt.auxWWeight,isRelative,obj.W);
				case 'det'
					obj.nonsourceW = ...
						RecurrenceParams.normalizeAuxWByDet(...
							randAuxW,opt.auxWWeight,isRelative,obj.W);
				otherwise
					error('Invalid auxWPolicy stem "%s".',policyStem);
			end
		end
	end
	methods (Static)
		function auxW = generateComplementaryAuxW(auxWPolicy,auxWWeight,W)
			if length(split(auxWPolicy,':')) > 1
				error('Invalid auxWPolicy "%s".',auxWPolicy);
			end
			if any(W < 0)
				error('For "not" policy, W cannot have negative elements.');
			end
			if any(W > auxWWeight)
				error('For "not" policy, W cannot have %s %g.',...
					'elements greater than auxWWeight',auxWWeight);
			end
			auxW = auxWWeight - W;
		end
		function auxW = normalizeAuxWByDet(auxW,auxWWeight,isRelative,W)
			auxDet = det(auxW);
			if abs(auxDet) < 1e-6
				error('Determinant of auxW is too close to zero.');
			end
			detMultiplier = auxWWeight / auxDet;
			if isRelative
				detMultiplier = detMultiplier * det(W);
			end
			scalarMultiplier = abs(detMultiplier) ^ (1/size(auxW,1));
			auxW = auxW * scalarMultiplier;
		end
		function auxW = normalizeAuxWByRowOrCol(auxW,summationDim,...
				auxWWeight,isRelative,W)
			auxSums = sum(auxW,summationDim);
			repDims = size(auxW) ./ size(auxSums);
			if isRelative
				targetWeights = auxWWeight .* sum(W,summationDim);
			else
				targetWeights = auxWWeight .* ones(size(auxSums));
			end
			% Goal here is to multiply rows or columns by constants to
			% yield target weights, but for the cases where those
			% multiplicative constants would be too large, we first
			% tweak the applicable rows or columns with additive constants.
			maxMultiplier = 1e3;  % (Arbitrary; should perhaps be a param)
			shortfalls = abs(targetWeights) - abs(maxMultiplier * auxSums);
			auxSigns = sign(auxSums) + (sign(auxSums) == 0);
			tweaks = sign(targetWeights) .* auxSigns .* ...
				max(0,shortfalls) / abs(maxMultiplier * prod(repDims));
			auxW = auxW + repmat(tweaks,repDims);
			% Recompute auxSums to reflect tweaks, then normalize
			auxSums = sum(auxW,summationDim);
			multipliers = targetWeights ./ auxSums;
			auxW = auxW .* repmat(multipliers,repDims);
		end
	end
end
