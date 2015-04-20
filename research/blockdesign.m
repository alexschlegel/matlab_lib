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
% Updated: 2015-04-20
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
	C	= bls(nBlock);
	
	if isodd(nBlock)
		C	= [C; C(:,end:-1:1)];
	end
%add rows until we have the desired number of runs
	[nRow,nCol]	= size(C);
	
	%attempt to add random permutations
		nNeeded	= nRun - nRow;
		C		= [C; genperm(nBlock,nNeeded,'exclude',C,'seed',false)];
	
	%add random duplicates if we still don't have enough
		[nRow,nCol]	= size(C);
		
		if nRow < nRun
			warning('Cannot generate %d runs of unique combinations of %d blocks.',nRun,nCol);
			
			while nRow<nRun
				nNeeded	= min(nRow,nRun-nRow);
				kRepeat	= randFrom(1:nRow,[nNeeded 1]);
				C		= [C; C(kRepeat,:)];
				nRow	= size(C,1);
			end
		end
%map to the conditions
	C	= block(C);
%randomize across rows
	C	= randomize(C,1,'rows','seed',false);
%keep the requested runs
	C	= C(1:nRun,:);

%generate the parameter orders
	%get the conditions as integers
		[bC,CInt]	= ismember(C,c);
	
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
					for kC=1:nCondition
					%randomize the order for each condition
						param.(strField)(kR,CInt(kR,:)==kC)	= randomize(pChoose,'seed',false);
					end
				end
			elseif divides(nValue,nRep*nRun)
			%balance by experiment
				pChoose	= repto(p,[nRep*nRun 1]);
				
				for kC=1:nCondition
				%randomize the order for each condition
					param.(strField)(CInt==kC)	= randomize(pChoose,'seed',false);
				end
			else
			%just choose randomly (actually the same as the previous case)
				pChoose	= repto(p,[nRep*nRun 1]);
				
				for kC=1:nCondition
				%randomize the order for each condition
					param.(strField)(CInt==kC)	= randomize(pChoose,'seed',false);
				end
			end
	end
