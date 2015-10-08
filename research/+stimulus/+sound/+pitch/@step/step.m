classdef step < stimulus.sound.pitch
% stimulus.sound.pitch.step
% 
% Description:	just a synonym for stimulus.sound.pitch
% 
% Updated:	2015-10-06
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%METHODS------------------------------------------------------------------------
	%CONSTRUCTOR
		methods (Access=public)
			function obj = step(varargin)
				obj = obj@stimulus.sound.pitch(varargin{:});
			end
		end
%/METHODS-----------------------------------------------------------------------

end
