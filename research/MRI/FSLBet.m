function [bSuccess,cPathOut] = FSLBet(cPathIn,varargin)
% FSLBet
% 
% Description:	run FSL's bet tool to extract a brain image
% 
% Syntax:	[bSuccess,cPathOut] = FSLBet(cPathIn,<options>)
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
%					this is true, only one thread is used.
%		binarize:	(false) true to binarize the image after extraction
%		propagate:	(true) true to propagate thresholds to subsequent calls to
%					FSLBet
%		nthread:	(1) the number of threads to use
%		force:		(true) true to force bet to run even if the output already
%					exists
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	bSuccess	- true if the bet and fslview ran successfully
%	strPathOut	- the path to the output volume
% 
% Updated: 2014-10-09
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
persistent fThresh;

opt	= ParseArgs(varargin,...
		'output'	, []	, ...
		'thresh'	, []	, ...
		'prompt'	, []	, ...
		'binarize'	, false	, ...
		'propagate'	, true	, ...
		'nthread'	, 1		, ...
		'force'		, true	, ...
		'silent'	, false	  ...
		);
opt.prompt	= unless(opt.prompt,isempty(opt.thresh));
opt.thresh	= unless(opt.thresh,unless(fThresh,0.5));

[cPathIn,opt.output,bNoCell,dummy]	= ForceCell(cPathIn,opt.output);
[cPathIn,opt.output]				= FillSingletonArrays(cPathIn,opt.output);

strSuffix	= conditional(opt.binarize,'_brain_mask','_brain');
cPathOut	= cellfun(@(fi,fo) unless(fo,PathAddSuffix(fi,strSuffix,'favor','nii.gz')),cPathIn,opt.output,'uni',false);

if opt.prompt
	opt.nthread	= 1;
end

bSuccess	= MultiTask(@BetOne,{cPathIn, cPathOut},...
				'description'	, 'betting data'	, ...
				'uniformoutput'	, true				, ...
				'nthread'		, opt.nthread		, ...
				'silent'		, opt.silent		  ...
				);

if bNoCell
	cPathOut	= cPathOut{1};
end


%------------------------------------------------------------------------------%
function bSuccess = BetOne(strPathIn, strPathOut)
	if ~opt.force && FileExists(strPathOut)
		bSuccess	= true;
		return;
	end
	
	bSuccess	= false;
	
	if ~FileExists(strPathIn)
		return;
	end
	
	%get the mean of the absolute value if we have a 4D data set
		hdr		= FSLReadHeader(strPathIn);
		bMean	= hdr.dim4>1;
		if bMean
			status('Calculating mean(|d|)','silent',opt.silent);
			
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
				if CallProcess('bet',{strPathIn strPathOut '-f' opt.thresh},'silent',true)
					return;
				end
			%prompt for changes
				if opt.prompt
					status('Check fslview for proper intensity threshold.  Loading results...');
					
					if ~FSLView(strPathOut)
						return;
					end
					
					res	= ask('Enter a new threshold or accept:','title','FSLBet','default',opt.thresh);
					if isempty(res)
						return;
					else
						bGo			= ~isequal(res,opt.thresh);
						opt.thresh	= res;
					end
				else
					bGo	= false;
				end
		end
	%update fThresh
		if opt.propagate
			fThresh	= opt.thresh;
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
		bSuccess	= true;
end
%------------------------------------------------------------------------------%

end
