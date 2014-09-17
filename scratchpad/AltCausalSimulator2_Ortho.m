% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef AltCausalSimulator2_Ortho < CausalSimulator
	% AltCausalSimulator2_Ortho:  CausalSimulator w/ orthogonal signals
	%   TODO: Add detailed comments

	methods
		function obj = AltCausalSimulator2_Ortho
			obj = obj@CausalSimulator;
		end
		function M = makeColumnsOrthogonal(~,M)
			cols = size(M,2);
			for j = 2:cols
				for k = 1:j-1
					% Subtract from jth column its projection on kth column
					M(:,j) = M(:,j) - ...
						((M(:,j)'*M(:,k)) / (M(:,k)'*M(:,k))) * M(:,k);
				end
			end
			% disp('Orthogonalized matrix:');
			% disp(M'*M);
		end
		function F = massageFunctionalSigs(obj,F)
			F = obj.makeColumnMeansZero(F);
			F = obj.makeColumnsOrthogonal(F);
		end
	end

end

