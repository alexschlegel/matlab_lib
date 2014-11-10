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
			fprintf('Source noisiness = %d\n',...
				obj.baseParams.sourceNoisiness);
			fprintf('Destination noisiness = %d\n',...
				obj.baseParams.destNoisiness);
			fprintf('Voxel-mixing freedom = %d\n', obj.voxelPolicy.freedom);
			falseTrue = {'false','true'};
			fprintf('Is destination balanced = %s\n',...
				falseTrue{obj.sigGen.isDestBalancing+1});
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
		function runDensityExample
			voxelFreedom = 1.000;
			isDestBalancing = false;
			dimsList = {1, 2, [1 2]};
			for i = 1:numel(dimsList)
				rng('default');
				data = CausalSimulator.runDensityTest(...
					dimsList{i},voxelFreedom,isDestBalancing);
				dataGrid(i,:) = data;
			end
			for i = 1:numel(dataGrid)
				figGrid(i) = dataGrid(i).showWStarGrayscale;
			end
			figGrid = reshape(figGrid,size(dataGrid));
			% (Can also use subplot to make a grid of plots in one figure)
			set(figGrid, 'Position', [0 0 150 100]);
			multiplot(figGrid);  %was: multiplot(reshape(1:15,5,3)');
			colormap('gray');
		end
		function data = runDensityTest(whichDims,voxelFreedom,...
				isDestBalancing)
			bp = CausalBaseParams;
			bp.sourceNoisiness = 1000;
			bp.destNoisiness = 1000;
			nf = bp.numFuncSigs;
			for i = 1:5
				W = zeros(nf);
				if whichDims == 1
					W(1:i,1) = ones(i,1);
				elseif whichDims == 2
					W(1,1:i) = ones(1,i);
				elseif whichDims == [1 2]
					W(1:i,1:i) = diag(ones(i,1));
				else
					error('Invalid dimensions.');
				end
				data(i) = CausalSimulator.runW(bp,W,...
					voxelFreedom,isDestBalancing);
			end
		end
		function runNineSourceGraphs
			for i = 1:9
				rng('default');
				srcDstIndexPairs = {[i (i+1)]};
				CausalSimulator.runSparse(srcDstIndexPairs,0.000,false);
			end
		end
		function runPolicyContrast
			srcDstIndexPairs = {[3 4],[6 7]};
			%srcDstIndexPairs = {[7 10]};
			%srcDstIndexPairs = {[3 9],[7 10]};
			%srcDstIndexPairs = {[3 4],[6 7],[9 10]};
			%srcDstIndexPairs = {[1 2],[2 3],[3 4],[4 5],[5 6]};
			for destBalancing = 0:1
				for voxelFreedom = 0.000:1.000
					rng('default');
					CausalSimulator.runSparse(srcDstIndexPairs,...
						voxelFreedom,destBalancing);
				end
			end
		end
		function [data,figHandle] = runSparse(srcDstIndexPairs,...
				voxelFreedom,isDestBalancing)
			if ~iscell(srcDstIndexPairs) || ~isvector(srcDstIndexPairs)
				error('First argument is not a cell vector.');
			end
			bp = CausalBaseParams;
			bp.sourceNoisiness = 1000;
			bp.destNoisiness = 1000;
			nf = bp.numFuncSigs;
			W = zeros(nf);
			for i = 1:numel(srcDstIndexPairs)
				srcDst = srcDstIndexPairs{i};
				if numel(srcDst) ~= 2
					error('Source-dest pair must be 2-element array.');
				end
				if min(srcDst) < 1 || max(srcDst) > nf
					error('Source or dest index out of range.');
				end
				W(srcDst(1),srcDst(2)) = 1;
			end
			data = CausalSimulator.runW(bp,W,voxelFreedom,isDestBalancing);
			figHandle = data.showWStarGrayscale;
		end
		function data = runW(baseParams,W,voxelFreedom,isDestBalancing)
			baseParams.validateW(W);  % (redundant, but not harmful)
			sigGen = SigGen(baseParams,W,isDestBalancing);
			voxPol = VoxelPolicy(baseParams,voxelFreedom);
			data = CausalSimulator(sigGen,voxPol).runTest;
			%figHandle = data.showWStarGrayscale;
			%figHandle = SimStatic.showMatrixGrayscale(data.wStar);
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

