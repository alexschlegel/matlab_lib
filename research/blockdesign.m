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
%	[param]	- a struct specifying other parameters that should be balanced
%			  across the blocks. each field of the struct defines the possible
%			  values of one parameter.
%	<options>:
%		seed:	(randseed2) the seed to use for randomizing
% 
% Out:
% 	C		- an nRun x nBlock array of the conditions to show in each block
%	param	- a struct of nRun x nBlock of the parameter values for each block
% 
% Note:
%	this will not complain if bad design parameters are entered (e.g. more runs
%	than can be handled by a balanced Latin square)
% 
% Updated: 2015-01-26
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[param,opt]	= ParseArgs(varargin,struct,...
				'seed'	, randseed2	  ...
				);

%set the seed
	rng(opt.seed,'twister');

%construct the blocks
	nCondition	= numel(c);
	block		= repmat(reshape(c,1,[]),[1 nRep]);
%randomize them
	block	= randomize(block,'seed',randi(intmax));
	nBlock	= numel(block);

%get a balanced latin square for the blocks
	C	= bls(nBlock);
	
	if isodd(nBlock)
		C	= [C; C(:,end:-1:1)];
	end
%add rows until we have the desired number of runs
	[nRow,nCol]	= size(C);
	
	%make sure we can get the number of runs we need
		if nRun > factorial(nCol)
			error('Cannot generate %d runs of unique combinations of %d blocks.',nRun,nCol);
		end
	
	while nRow<nRun
		CRow	= randperm(nBlock);
		
		if ~ismember(CRow,C,'rows')
			C(end+1,:)	= CRow;
		end
		
		nRow	= size(C,1);
	end
%map to the conditions
	C	= block(C);
%randomize across rows
	C	= randomize(C,1,'rows','seed',randi(intmax));
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
		
		%get the parameter values to choose from in each run
			nValue	= numel(p);
			if nValue < nRep
				pChoose	= repmat(p,[ceil(nRep/nValue) 1]);
			else
				pChoose	= p;
			end
		
		%initialize the parameter array
			param.(strField)				= p(1);
			param.(strField)(nRun,nBlock)	= p(1);
		
		for kR=1:nRun
			%choose the parameters for the current run
				pCur	= randFrom(pChoose,[nRep 1]);
			%randomize among each condition
				for kC=1:nCondition
					param.(strField)(kR,CInt(kR,:)==kC)	= randomize(pCur,'seed',randi(intmax));
				end
		end
	end
	