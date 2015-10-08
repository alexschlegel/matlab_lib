classdef construct < stimulus.image.base
% stimulus.image.construct
% 
% Description:	create a construct figure
% 
% Syntax: obj = stimulus.image.construct([param1,val1,...,paramN,valN])
% 
% Methods:
%	generate:	generate a stimulus
%	validate:	validate a set of parameter values
% 
% Properties:
%	param:	a property collection of parameters that the generator function will
%			use to generate the stimulus. includes:
%				d: (0.05) the difficulty level (0->1)
%				part: (<random>) a 4-element array of part indices, or a single
%					index to return just that part's image. overrides <d>.
%				style: ('figure') the style of image to construct:
%					'figure':	assemble into a figure
%					'part':		a row of parts
%				pad: (0.25) the padding between parts for part figures, as a
%					fraction of the part size
%			<see also stimulus.image.base>
% 
% In:
%	[paramK]	- the Kth parameter whose value should be set explicitly
%	[valK]		- the explicit value of parameter paramK (or empty to skip
%				  skip setting the value)
% 
% Updated:	2015-10-06
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%PROPERTIES---------------------------------------------------------------------
	%CONSTANT
		properties (Constant, GetAccess=protected)
			N_PART	= 100;
		end
%/PROPERTIES--------------------------------------------------------------------

%METHODS------------------------------------------------------------------------
	%CONSTRUCTOR
		methods (Access=public)
			function obj = construct(varargin)
				obj = obj@stimulus.image.base();
				
				%set some parameter defaults
					add(obj.param,'d','generic',{0.05});
					add(obj.param,'part','generic',{@(varargin) obj.pick_parts(obj.param.d,varargin{:})});
					add(obj.param,'style','generic',{'figure'});
					add(obj.param,'pad','generic',{0.25});
				
				%parse the inputs
					obj.parseInputs(varargin{:});
			end
		end
	
	%PRIVATE
		methods (Access=protected)
			%-------------------------------------------------------------------
			function kPart = pick_parts(obj,d,varargin)
				opt	= ParseArgs(varargin,...
						'exclude'	, []	  ...
						);
				
				%possible parts to choose from
					rngMax = min(obj.N_PART, 2 + floor(d*(obj.N_PART-1)));
					rngMin = max(1, rngMax - 25);
					rngMean = (rngMin + rngMax)/2;
				
				%choose parts that have a mean d close the midpoint of our part range
					sumPart	= 0;
					nPick	= 4;
					kPart	= NaN(nPick,1);
					
					for kP=1:nPick
						if kP==nPick
						%get close to the midpoint
							pMid = rngMean*nPick - sumPart;
							
							pRange	= [];
							r		= -0.5;
							while isempty(pRange)
								r		= r+1;
								pMin	= max(rngMin,floor(pMid-r));
								pMax	= min(rngMax,ceil(pMid+r));
								
								pRange	= pMin:pMax;
								
								if pMin==rngMin && pMax==rngMax
									break;
								end
								
								pRange	= setdiff(pMin:pMax,opt.exclude);
							end
							
							
							if isempty(opt.exclude)
								kPart(end)	= randi([pRange(1) pRange(end)]);
							else
								kPart(end)	= randFrom(pRange,'exclude',opt.exclude);
							end
						else
						%choose a part that allows us to reach the midpoint by the end
							nLeft	= nPick - kP;
							partMin	= max(rngMin,ceil(nPick*rngMean - sumPart - rngMax*nLeft));
							partMax	= min(rngMax,floor(nPick*rngMean - sumPart - rngMin*nLeft));
							
							endMin	= (sumPart + partMin + rngMin*nLeft)/nPick;
							endMax	= (sumPart + partMax + rngMax*nLeft)/nPick;
							
							if isempty(opt.exclude)
								kPart(kP)	= randi([partMin partMax]);
							else
								kPart(kP)	= randFrom(partMin:partMax,'exclude',opt.exclude);
							end
							sumPart		= sumPart + kPart(kP);
						end
					end
				
				%randomize the order
					kPart = randomize(kPart,'seed',false);
			end
			%-------------------------------------------------------------------
			
			[mask,ifo] = generate_mask(obj,ifo)
		end
%/METHODS-----------------------------------------------------------------------

end
