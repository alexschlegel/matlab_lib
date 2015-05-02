function [b,cPathOut] = FSLBet(cPathIn,varargin)
% FSLBet
% 
% Description:	run FSL's bet tool to extract a brain image
% 
% Syntax:	[b,cPathOut] = FSLBet(cPathIn,<options>)
% 
% In:
% 	strPathIn	- the input path, or a cell of input paths.  if the input is a
%				  4D data set, then bet is performed on the temporal mean of the
%				  absolute value.
%	<options>:
%		output:		(<input>_brain[_mask].nii.gz) the path(s) to the output
%					file(s). "_mask" is appended if the binarize option is true.
%		thresh:		(<0.5 or last>) the fractional intensity threshold
%		prompt:		(<true if <thresh> is not specified> true to display the
%					results of brain extraction and prompt for a new f value. if
%					this is true, only one core is used.
%		binarize:	(false) true to binarize the image after extraction
%		propagate:	(true) true to propagate thresholds to subsequent calls to
%					FSLBet
%		cores:		(1) the number of processor cores to use
%		force:		(true) true to force bet to run even if the output already
%					exists
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	b			- true if the bet and fslview ran successfully
%	strPathOut	- the path to the output volume
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%process the inputs
	opt	= ParseArgs(varargin,...
			'output'	, []	, ...
			'thresh'	, []	, ...
			'prompt'	, []	, ...
			'binarize'	, false	, ...
			'propagate'	, true	, ...
			'cores'		, 1		, ...
			'force'		, true	, ...
			'silent'	, false	  ...
			);
	
	opt.prompt	= unless(opt.prompt,isempty(opt.thresh));
	opt.thresh	= unless(opt.thresh,0.5);
	
	if opt.prompt
		opt.cores	= 1;
	end
	
	[cPathIn,opt.output,bNoCell,dummy]	= ForceCell(cPathIn,opt.output);
	[cPathIn,opt.output]				= FillSingletonArrays(cPathIn,opt.output);
	
	strSuffix	= conditional(opt.binarize,'_brain_mask','_brain');
	cPathOut	= cellfun(@(fi,fo) unless(fo,PathAddSuffix(fi,strSuffix,'favor','nii.gz')),cPathIn,opt.output,'uni',false);

%which data do we need to process?
	sz	= size(cPathIn);
	
	if opt.force
		bDo	= true(sz);
	else
		bDo	= ~cellfun(@FileExists,cPathOut);
	end

%bet them all
	b	= true(sz);
	
	opt		= rmfield(opt,'opt_extra');
	b(bDo)	= MultiTask(@BetOne,{cPathIn(bDo) cPathOut(bDo) opt},...
				'description'	, 'betting data'	, ...
				'uniformoutput'	, true				, ...
				'cores'			, opt.cores			, ...
				'silent'		, opt.silent		  ...
				);

if bNoCell
	cPathOut	= cPathOut{1};
end


%------------------------------------------------------------------------------%
function b = BetOne(strPathIn,strPathOut,opt)
	persistent fThresh;
	
	fThresh	= conditional(opt.propagate,unless(fThresh,opt.thresh),opt.thresh);
	
	b	= false;
	
	if ~FileExists(strPathIn)
		return;
	end
	
	%get the mean of the absolute value if we have a 4D data set
		sz		= NIfTI.GetSize(strPathIn);
		bMean	= numel(sz)>=4 && sz(4)>1;
		if bMean
			status('calculating mean(|d|)','silent',opt.silent);
			
			strPathTemp	= GetTempFile('ext','nii.gz');
			if CallProcess('fslmaths',{strPathIn '-abs' '-Tmean' strPathTemp},'silent',true)
				return;
			end
			
			strPathIn	= strPathTemp;
		end
	%bet until we get a good value
		bGo	= true;
		while bGo
			%run bet
				if CallProcess('bet',{strPathIn strPathOut '-f' fThresh},'silent',true)
					return;
				end
			%prompt for changes
				if opt.prompt
					status('Check fslview for proper intensity threshold.  Loading results...');
					
					if ~FSLView(strPathOut)
						return;
					end
					
					res	= ask('Enter a new threshold or accept:','title','FSLBet','default',fThresh);
					if isempty(res)
						return;
					else
						bGo		= ~isequal(res,fThresh);
						fThresh	= res;
					end
				else
					bGo	= false;
				end
		end
	%binarize
		if opt.binarize && CallProcess('fslmaths',{strPathOut '-bin' strPathOut},'silent',true)
			return;
		end
	%delete intermediate files
		if bMean
			delete(strPathTemp);
		end
	%success!
		b	= true;
%------------------------------------------------------------------------------%
