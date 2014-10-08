% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef CausalSimulator < handle
	% CausalSimulator:  Parent class for study of causal flows
	%   TODO: Add detailed comments

	properties (SetAccess = private)
		baseParams
		sigGen
		voxelPolicy
	end
	properties
		autoShowResults = true
	end

	methods
		function obj = CausalSimulator(sigGen,voxelPolicy)
			if sigGen.baseParams ~= voxelPolicy.baseParams
				error('Arguments have incompatible baseParams.');
			end
			obj.baseParams = sigGen.baseParams;
			obj.sigGen = sigGen;
			obj.voxelPolicy = voxelPolicy;
		end
		function M = makeColumnMeansZero(~,M)
			M = M - repmat(mean(M),size(M,1),1);
		end
		function F = massageFunctionalSigs(obj,F) %#ok
			% (Action specialized in subclasses)
			%
			%F = obj.makeColumnMeansZero(F);
		end
		function data = performAll(obj)
			data = SimulationData(obj);
			obj.performFunctionalSynthesis(data);
			obj.performVoxelSynthesis(data);
			obj.performPCA(data);
			obj.performCausalityComputation(data);
		end
		function performCausalityComputation(obj,data)
			nc = obj.baseParams.numTopComponents;
			data.wStar = zeros(nc,nc);
			for i = 1:nc
				for j = 1:nc
					%fprintf('Granger for (%d,%d)\n',i,j);
					srcP = data.source.pcaSigs(:,i);
					dstP = data.dest.pcaSigs(:,j);
					data.wStar(i,j) = GrangerCausality(srcP,dstP);
				end
			end
		end
		function performFunctionalSynthesis(obj,data)
			[data.source.funcSigs, data.dest.funcSigs] = ...
				obj.sigGen.genSigs;
		end
		function performPCA(obj,data)
			obj.performRegionPCA(data.source);
			obj.performRegionPCA(data.dest);
		end
		function performRegionPCA(~,region)
			[region.pcaCoeff, region.pcaSigs] = pca(region.voxelSigs);
		end
		function performVoxelSynthesis(obj,data)
			data.source.voxelSigs = obj.voxelPolicy.mixFuncSigs(...
				data.source.funcSigs,1);
			data.dest.voxelSigs = obj.voxelPolicy.mixFuncSigs(...
				data.dest.funcSigs,2);
		end
		function data = runTest(obj)
			data = obj.performAll;
			if obj.autoShowResults
				obj.showResults(data);
			end
		end
		function showParams(obj)
			fprintf('Num time steps = %d\nNum functional sigs = %d\n',...
				obj.baseParams.numTimeSteps, obj.baseParams.numFuncSigs);
			fprintf('Num voxel sigs = %d\nNum top components = %d\n',...
				obj.baseParams.numVoxelSigs,...
				obj.baseParams.numTopComponents);
			fprintf('Noisiness = %d\n', obj.baseParams.noisiness);
			fprintf('Voxel-mixing freedom = %d\n', obj.voxelPolicy.freedom);
		end
		function showRatios(obj,data)
			ratios = data.source.pcaSigs(:,1:obj.baseParams.numFuncSigs) ...
				./ data.source.funcSigs;
			CausalSimulator.showUpperLeftAndMeanAndVariance(ratios,...
				{'Ratios of pcaSigs to funcSigs:',...
				'Means of ratios:',...
				'Variances of ratios:'});
		end
		function showResults(obj,data)
			disp(repmat('=',1,70));
			disp(class(obj));
			obj.showParams;
			disp(repmat('-',1,70));
			maxDisplayRows = 10;
			maxDisplayCols = 3;
			fprintf(...
				'Matrices below are clipped for readability.\n\n');
			%{
			disp(['Source funcSigs vs. source pcaSigs ' ...
				'(with zero column as separator):']);
			Sf = SimStatic.clipmat(data.source.funcSigs,...
				maxDisplayRows,maxDisplayCols);
			Sp = SimStatic.clipmat(data.source.pcaSigs,...
				maxDisplayRows,maxDisplayCols);
			disp([Sf zeros(size(Sf,1),1) Sp]);
			obj.showRatios(data);
			%}
			maxDispDim = 7;
			disp('W:');
			disp(SimStatic.clipmat(obj.sigGen.W,maxDispDim,maxDispDim));
			disp('Granger Causality scores among top components:');
			disp(SimStatic.clipmat(data.wStar,maxDispDim,maxDispDim));
			colsums = sum(data.wStar,1);
			rowsums = sum(data.wStar,2);
			disp('Granger Causality column and (transposed) row sums:');
			disp(SimStatic.clipmat([colsums;rowsums'],2,maxDispDim));
		end
	end

	methods (Static)
		function runExample(baseParams)
			if nargin > 0
				bp = baseParams;
			else
				bp = CausalBaseParams;
				bp.noisiness = 1000;
			end
			sigGen = SigGenTrigBased(bp,diag(ones(1,bp.numFuncSigs)));
			rng('default');
			voxPol = VoxelPolicy(bp,0.000);
			CausalSimulator(sigGen,voxPol).runTest;
			rng('default');
			voxPol = VoxelPolicy(bp,1.000);
			CausalSimulator(sigGen,voxPol).runTest;
		end
		function showUpperLeftAndMeanAndVariance(M,headings)
			disp(headings{1});
			maxDisplayRows = 12;
			maxDisplayCols = 5;
			disp(SimStatic.clipmat(M,maxDisplayRows,maxDisplayCols));
			disp(headings{2});
			disp(SimStatic.clipmat(mean(M),1,maxDisplayCols));
			disp(headings{3});
			disp(SimStatic.clipmat(var(M),1,maxDisplayCols));
		end
	end

end

