classdef NGram < SoundGen.Generate.Generator
% SoundGen.Generate.NGram
% 
% Description:	n-gram string generator.  generates based on the frequency of
%				occurence of n-grams within the corpus cluster string
% 
% Syntax:	g = SoundGen.Generate.NGram(parent,<options>)
% 
% 			subfunctions:
%				Run	- run the generate process
% 			 
% 			properties:
%				n				- the n-gram length
%				result			- an Sx1 generated cluster string array assigned
%								  during a call to Run
%				intermediate	- a struct of intermediate processing results
%								  (read only)
%				ran				- true if the generator has already run
%				silent			- true if processes should be silent
% 
% In:
%	parent	- the parent SoundGen.System object
%	<options>:
%		generate_n:	(5) the ngram length
%		silent:		(false) true if processes should be silent
%
% Updated: 2012-11-02
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		n	= 0;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		function g = set.n(g,n)
			if isnat(n)
				g.n		= n;
				g.ran	= false;
			else
				error('Invalid generate n.');
			end
		end
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function g = NGram(parent,varargin)
			g	= g@SoundGen.Generate.Generator(parent,varargin{:});
			
			opt	= ParseArgs(varargin,...
					'generate_n'	, 5	  ...
					);
			
			g.n	= opt.generate_n;
		end
	end
	methods (Static)
		
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	methods
		
	end
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	
	
	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Access=private)
		
	end
	%PRIVATE METHODS-----------------------------------------------------------%
	
end
