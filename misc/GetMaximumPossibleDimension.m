function d = GetMaximumPossibleDimension(varargin)
% GetMaximumPossibleDimension
% 
% Description:	get the maximum possible dimension size that the current free
%				memory will allow for a set of arrays that share that dimension
%				size
% 
% Syntax:	d = GetMaximumPossibleDimension(s1,[type1]='double',[n1]=1,...,sN,typeN,nN,<options>)
% 
% In:
% 	sK		- the size of the Kth matrix without the dimension in
%			  question
%	[typeK]	- the Kth data type
%	[nVarK]	- specify if nVarK of the Kth matrix need to be created with
%			  the specified size
%	<options>:
%		'maximize':	(false) true to do a test to maximize d (takes longer).
%		'desired':	(inf) the desired dimension size.  if the function
%					determines that this size is possible it stops
% 
% Out:
% 	d	- the minimum of the 'desired' option and the maximum possible dimension
%		  given current free memory
% 
% Example:  If I want to have four stacks of 720x1280x3 images in memory at once
%			and want to know the maximum possible number of images I can stack,
%			I would call:
%				d = GetMaximumPossibleDimension([720 1280 3],'double',4);
%			for four 720x1280x3 stacks along with 10 at 72x128x3:
%				d = GetMaximumPossibleDimension([720 1280 3],'double',4,[72 128 3],'double',10);
%
% Notes:	if the 'maximize' option is false, this function assumes
%			conservatively that each successive initialization of a matrix
%			decreases the maximum possible single matrix size by the amount of
%			memory occupied by the matrix, so that the actual memory available
%			for all arrays is the memory available for a single array.
%
% Updated:	2009-04-07
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get the start of the option block
	cOpt	= {'maximize','desired'};
	kOpt	= nargin+1;
	for k=1:nargin
		if ischar(varargin{k}) && ismember(varargin{k},cOpt)
			kOpt	= k;
			break;
		end
	end
	vOpt	= varargin(kOpt:end);
%process the options
	opt	= ParseArgsOpt	(vOpt						, ...
								'maximize'	, false	, ...
								'desired'	, inf	  ...
						);

%number of matrix sets
	nSet	= ceil(numel(varargin(1:kOpt-1))/3);

%get the memory occupied by a single 'plane' of each matrix specification
	[mPlane,nVar]	= deal(zeros(nSet,1));
	for kS=1:nSet
		kArgStart	= (kS-1)*3+1;
		kArgEnd		= min(numel(varargin),kArgStart+2);
		
		[s,vType,nVar(kS)]	= ParseArgs(varargin(kArgStart:kArgEnd),1,'double',1);
		
		%get the size of a single element of the data type
			B	= GetMemorySizeOfElement(vType);
		%get the size of a single 'plane' of the array
			mPlane(kS)	= prod(s)*B;
	end

%get the largest dimension based on individual matrix size limits
	m			= memory;
	mMaxSingle	= m.MaxPossibleArrayBytes;
	dMaxSingle	= min(floor(mMaxSingle./mPlane));
%get the largest dimension based on total memory available
	%see note above
		%mMaxGroup	= m.MemAvailableAllArrays;
		mMaxGroup	= mMaxSingle;
	dMaxGroup	= floor(mMaxGroup/sum(mPlane.*nVar));

%get the size of the maximum dimension given these constraints
	d	= min(dMaxSingle,dMaxGroup);
	if d>=opt.desired
		d	= opt.desired;
		return;
	end

%should we maximize the dimension?
	if opt.maximize
		%sort mPlane descending
			[mPlane,kDescend]	= sort(mPlane,1,'descend');
			nVar				= nVar(kDescend);
		%double d until we get a memory error
			dMin	= d;
			dCur	= d;
			while TestDResult(mPlane,nVar,dCur)
				if dCur>=opt.desired
					d	= opt.desired;
					return;
				end
				
				dCur	= 2*dCur;
			end
			dMax	= dCur;
			dCur	= round((dMin+dMax)/2);
		%do a binary search to find the maximum value of d
			nD	= dMax-dMin+1;
			wb	= waitbar(0,['Testing d=' num2str(dCur)]);
			
			while dCur~=dMin && dCur~=dMax
				if TestDResult(mPlane,nVar,dCur)
					if dCur>=opt.desired
						d	= opt.desired;
						return;
					end
					
					dMin	= dCur;
				else
					dMax	= dCur;
				end
				
				dCur	= round((dMin+dMax)/2);
				waitbar((nD-(dMax-dMin))/nD,wb,['Testing d=' num2str(dCur)]);
			end
			close(wb);
		%the last one that worked is dMin
			d	= dMin;
	end

%------------------------------------------------------------------------------%
function b = TestDResult(mPlane,nVar,d)
%test the d result to see if the matrices can actually be created
	c	= cell(sum(nVar),1);
	
	try
		kC	= 0;
		
		nSet	= numel(mPlane);
		for kS=1:nSet
			for kV=1:nVar(kS)
				kC	= kC+1;
				
				c{kC}	= zeros(mPlane(kS),d,'uint8');
			end
		end
		
		b	= true;
	catch
		b	= false;
	end
%------------------------------------------------------------------------------%
