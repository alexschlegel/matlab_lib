function varargout = StatSimpleRegression(x,cPathNII,varargin)
% StatSimpleRegression
% 
% Description:	calculate a simple regression from an x parameter and a set of
%				NIfTI files
% 
% Syntax:	[cPath1,...,cPathN] = StatSimpleRegression(x,cPathNII,[cDirOut]=<auto>,<options>)
% 
% In:
% 	x			- the x parameter (models data as nii = b + m*x), or a cell of
%				  x parameters (one for each set of cPathNII data)
%	cPathNII	- a cell of NIfTI files representing measurements at each value
%				  of x.  can also be a cell of cells to calculate more than one
%				  regression on x
%	[cDirOut]	- an output directory or cell of directories.  defaults to the
%				  base directory of the inputs
%	<options>:
%		output:		({'r','p','m','b'}) the regression parameter brains to save:
%						r:	the correlation coefficient
%						p:	the significance value of r
%						m:	the best-fit slope
%						b:	the best-fit y-intercept
%		prefix:		('corr') the prefix for output files
%		mask:		(<none>) a path/cell of paths to mask files
%		force:		(true) true to force regression calculation if output files
%					already exist
%		nthread:	(1) number of threads to use
%		silent:		(false) true to suppress output messages
% 
% Out:
% 	cPathK	- the path/cell of paths to the Kth best-fit parameter output
%			  specified in the output option
% 
% Notes:	files are only saved if the corresponding output argument is
%			specified
% 
% Updated: 2014-03-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[cDirOut,opt]	= ParseArgs(varargin,[],...
					'output'	, {'r','p','m','b'}	, ...
					'prefix'	, 'corr'			, ...
					'mask'		, []				, ...
					'force'		, true				, ...
					'nthread'	, 1					, ...
					'silent'	, false				  ...
					);

%cellify
	opt.output	= ForceCell(opt.output);
	
	x					= ForceCell(x);
	[cPathNII,bNoCell]	= ForceCell(cPathNII,'level',2);
	
	if isempty(cDirOut)
		cDirOut	= cellfun(@PathGetBase,cPathNII,'UniformOutput',false);
	else
		cDirOut	= ForceCell(cDirOut,'level',2);
	end
	if isempty(opt.mask)
		opt.mask	= repmat({[]},size(cPathNII));
	else
		opt.mask	= ForceCell(opt.mask,'level',2);
	end
	
	[x,cPathNII,cDirOut,opt.mask]	= FillSingletonArrays(x,cPathNII,cDirOut,opt.mask);
	bNoCell							= bNoCell && numel(cPathNII)==1;
%calculate and save each
	nOut	= numel(opt.output);
	
	x	= reshape(x,[],1);
	if numel(x)==0
		[varargout{:}]	= deal([]);
		return;
	end
	
	[varargout{:}]	= MultiTask(@RegressOne,cPathNII,cDirOut,opt.mask,'description','Calculating simple regressions','nthread',opt.nthread,'silent',opt.silent);
%uncellify
	if bNoCell
		varargout	= cellfun(@(x) x{1},varargout,'UniformOutput',false);
	end


%------------------------------------------------------------------------------%
function varargout = RegressOne(cPathNII,strDirOut,strPathMask)
	%get the data to read
		bExist		= FileExists(cPathNII);
		if ~any(bExist)
			[varargout{:}]	= deal([]);
			return;
		end
		
		xCur		= x(bExist);
		cPathNII	= cPathNII(bExist);
	%load the data
		d		= cellfun(@(f) NIfTIRead(f),cPathNII,'UniformOutput',false);
		niiOut	= d{1};
		d		= cellfun(@(nii) nii.data,'UniformOutput',false);
		d		= stack(d{:});
	%apply the mask
		if ~isempty(strPathMask)
			m		= single(GetFieldPath(NIfTIRead(strPathMask),'data'));
			m(m==0)	= NaN;
			d		= d.*m;
			
			clear m;
		end
	%calculate the regression
		[r,stat]	= corrcoef2(x,d);
		cOut		= cellfun(@(f) stat.(f),opt.output,'uni',false);
	%save the outputs
		cPathOut	= cell(nOut,1);
		for kN=1:nOut
			cPathOut{kN}	= PathUnsplit(strDirOut,[opt.prefix '-' opt.output{kN}],'nii.gz');
			niiOut.data		= cOut{kN};
			
			NIfTIWrite(niiOut,cPathOut{kN});
		end
	%set the outputs
		varargout	= cPathOut;
%------------------------------------------------------------------------------%

end
