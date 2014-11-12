% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef IntensityPlot
	% IntensityPlot:  Methods for visualing matrix structure
	%   TODO: Add detailed comments

	methods (Static)
		function clims = getGlobalClims(M,outlierPercentage)
			if nargin < 2
				outlierPercentage = 5;
			end
			if outlierPercentage < 0 || outlierPercentage > 30
				error(sprintf('Nonsensical outlier percentage %g',...
					outlierPercentage));
			end
			bottomTailPct = outlierPercentage/2;
			topTailPct = 100-bottomTailPct;
			clims = prctile(M(:),[bottomTailPct;topTailPct]).';
		end
		function figHandle = showGrayscale(M,clims)
			if nargin < 2
				clims = IntensityPlot.getGlobalClims(M);
			end
			figHandle = figure;
			colormap('gray');
			imagesc(M,clims);
		end
	end
end
