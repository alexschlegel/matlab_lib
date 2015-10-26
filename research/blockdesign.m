function [C,param] = blockdesign(c,nRep,nRun,varargin)
% blockdesign
% 
% Description:	generate the condition order for a block-design experiment 
% 
% Syntax:	[C,param] = blockdesign(c,nRep,nRun,[param]=struct,<options>)
% 
% In:
% 	c		- an array of conditions
%	nRep	- the number of repetitions of each condition per run
%	nRun	- the number of runs
%	[param]	- a struct specifying other parameters to generate. each field of
%			  the struct defines the possible values of one parameter. values
%			  are balanced by run, experiment, or are not balanced, depending on
%			  the number of possible parameter values.
%	
%	<options>:
%		seed:	(randseed2) the seed to use for randomizing. set to false to
%				skip seeding of the random number generator.
% 
% Out:
% 	C		- an nRun x nBlock array of the conditions to show in each block
%	param	- a struct of nRun x nBlock of the parameter values for each block
% 
% Note:
%	this will not complain if bad design parameters are entered (e.g. more runs
%	than can be handled by a balanced Latin square)
% 
% Updated: 2015-10-26
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the input
	[param,opt]	= ParseArgs(varargin,struct,...
					'seed'	, []	  ...
					);
	
	if isempty(opt.seed)
		opt.seed	= randseed2;
	end

%seed the random number generator
	if notfalse(opt.seed)
		rng(opt.seed,'twister');
	end

%construct the blocks
	nCondition	= numel(c);
	block		= repmat(reshape(c,1,[]),[1 nRep]);
%randomize them
	block	= randomize(block,'seed',false);
	nBlock	= numel(block);

%get a balanced latin square for the blocks
	kC	= bls(nBlock);
	
	if isodd(nBlock)
		kC	= [kC; kC(:,end:-1:1)];
	end
%add rows until we have the desired number of runs
	[nRow,nCol]	= size(kC);
	
	%attempt to add random permutations
		nNeeded	= nRun - nRow;
		if nNeeded>0
			kC	= [kC; genperm(nBlock,nNeeded,'exclude',kC,'seed',false)];
		end
	
	%add random duplicates if we still don't have enough
		[nRow,nCol]	= size(kC);
		
		if nRow < nRun
			warning('Cannot generate %d runs of unique combinations of %d blocks.',nRun,nCol);
			
			while nRow<nRun
				nNeeded	= min(nRow,nRun-nRow);
				kRepeat	= randFrom(1:nRow,[nNeeded 1]);
				kC		= [kC; kC(kRepeat,:)];
				nRow	= size(kC,1);
			end
		end
%randomize across rows
	kC	= randomize(kC,1,'rows','seed',false);
%keep the requested runs
	kC	= kC(1:nRun,:);
%map to the conditions
	C	= block(kC);

%generate the parameter orders
	cField	= fieldnames(param);
	nField	= numel(cField);
	
	for kF=1:nField
		strField	= cField{kF};
		p			= reshape(param.(strField),[],1);
		nValue		= numel(p);
		
		%initialize the parameter array
			param.(strField)				= p(1);
			param.(strField)(nRun,nBlock)	= p(1);
		
		%balance according to the number of possible values
			if divides(nValue,nRep)
			%balance by run
				pChoose	= repto(p,[nRep 1]);
				
				for kR=1:nRun
				%generate parameters for each run
					for kO=1:nCondition
					%randomize the order for each condition
						param.(strField)(kR,kC(kR,:)==kO)	= randomize(pChoose,'seed',false);
					end
				end
			elseif divides(nValue,nRep*nRun)
			%balance by experiment
				pChoose	= repto(p,[nRep*nRun 1]);
				
				for kO=1:nCondition
				%randomize the order for each condition
					param.(strField)(kC==kO)	= randomize(pChoose,'seed',false);
				end
			else
			%just choose randomly
				pChoose	= repto(p,[nRep*nRun*nCondition 1]);
				pChoose	= randomize(pChoose,'seed',false);
				
				nPer	= nRep*nRun;
				kEnd	= 0;
				for kO=1:nCondition
				%randomize the order for each condition
					kStart	= kEnd+1;
					kEnd	= kStart+nPer-1;
					
					param.(strField)(kC==kO)	= pChoose(kStart:kEnd);
				end
			end
	end
