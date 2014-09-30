% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef CausalSimulator < handle
	% CausalSimulator:  Parent class for study of causal flows
	%   TODO: Add detailed comments

	properties (SetAccess = protected)
		baseParams
		sourceParams
		destParams
		sourceToDestRescaling
	end
	properties
		autoShowResults = true
	end

	methods
		function obj = CausalSimulator(baseParams)
			if nargin > 0
				obj.baseParams = baseParams;
				obj.generateRegionParams;
			end
		end
		function generateRegionParams(obj)
			obj.sourceParams = CausalRegionParams(obj.baseParams);
			obj.destParams = CausalRegionParams(obj.baseParams);
			[obj.destParams,obj.sourceToDestRescaling] = ...
				obj.destParams.splitRecurDiagonal;
		end
		function M = makeColumnMeansZero(~,M)
			M = M - repmat(mean(M),size(M,1),1);
		end
		function [srcF,dstF] = makeFunctionalSigs(obj)
			preW = obj.baseParams.sourceToDestWeights;
			W = preW * diag(obj.sourceToDestRescaling);
			nt = obj.baseParams.numTimeSteps;
			nf = obj.baseParams.numFuncSigs;
			srcF = zeros(nt,nf);
			dstF = zeros(nt,nf);
			prevSrc = zeros(nf,1);
			prevDst = zeros(nf,1);
			for i = 1:nt
				currSrc = obj.sourceParams.applyRecurrence(prevSrc);
				currDst = obj.destParams.applyRecurrence(prevDst) + ...
					W * prevSrc;
				srcF(i,:) = currSrc';
				dstF(i,:) = currDst';
				prevSrc = currSrc;
				prevDst = currDst;
			end
			srcF = obj.massageFunctionalSigs(srcF);
			dstF = obj.massageFunctionalSigs(dstF);
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
					srcP = data.source.pcaSigs(:,i);
					dstP = data.dest.pcaSigs(:,j);
					data.wStar(i,j) = GrangerCausality(srcP,dstP);
				end
			end
		end
		function performFunctionalSynthesis(obj,data)
			[data.source.funcSigs, data.dest.funcSigs] = ...
				obj.makeFunctionalSigs;
		end
		function performPCA(obj,data)
			obj.performRegionPCA(data.source);
			obj.performRegionPCA(data.dest);
		end
		function performRegionPCA(~,region)
			[region.pcaCoeff, region.pcaSigs] = pca(region.voxelSigs);
		end
		function performVoxelSynthesis(obj,data)
			Vs = obj.sourceParams.voxelMixer;
			Vd = obj.destParams.voxelMixer;
			data.source.voxelSigs = data.source.funcSigs * Vs;
			data.dest.voxelSigs = data.dest.funcSigs * Vd;
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
			disp(['Source funcSigs vs. source pcaSigs ' ...
				'(with zero column as separator):']);
			Sf = SimStatic.clipmat(data.source.funcSigs,...
				maxDisplayRows,maxDisplayCols);
			Sp = SimStatic.clipmat(data.source.pcaSigs,...
				maxDisplayRows,maxDisplayCols);
			disp([Sf zeros(size(Sf,1),1) Sp]);
			obj.showRatios(data);
			maxWStarRowsAndCols = 7;
			disp('Granger Causality scores among top components:');
			disp(SimStatic.clipmat(data.wStar,...
				maxWStarRowsAndCols,maxWStarRowsAndCols));
		end
	end

	methods (Static)
		function runExampleSuite
			rng('default');
			params = CausalBaseParams(1);
			AltCausalSimulator1_Mean(params).runTest;
			AltCausalSimulator2_Ortho(params).runTest;
			AltCausalSimulator3_Descend.runShrink(100,50);
			AltCausalSimulator3_Descend.runUnshrink(100);
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

