function cPathDICOM = DICOMScale(cPathDICOM,varargin)
% DICOMScale
% 
% Description:	scale the values of a set of DICOM image files
% 
% Syntax:	cPathDICOM = DICOMScale(cPathDICOM,[vMin]=<keep>,[vMax]=<keep>,<options>)
% 
% In:
% 	cPathDICOM	- a string/cell of DICOM directory/file paths
%	[vMin]		- the new minimum intensity value
%	[vMax]		- the new maximum intensity value
%	<options>:
%		'suffix':	('-scaled') the suffix to add to the end of output files or
%					directories.  note that if a directory is passed, the suffix
%					is added only to the directory rather than each individual
%					file.
%		'silent':	(false) true to suppress progress indicators
% 
% Out:
% 	cPathDICOM	- a cell of output file paths
% 
% Side-effects:	saves scaled DICOM files as copies according to the specified
%				suffix
% 
% Updated:	2010-04-17
% Copyright 2010 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.
[vMin,vMax,opt]	= ParseArgs(varargin,[],[],...
		'suffix'	, '-scaled'	, ...
		'silent'	, false		  ...
		);

cPathDICOM	= ForceCell(cPathDICOM);
nPathDICOM	= numel(cPathDICOM);

%get output paths for each input
	if ~opt.silent
		status('Searching for files');
	end
	
	[cPathIn,cPathOut]	= deal({});
	for k=1:nPathDICOM
		if isdir(cPathDICOM{k})
			cPathInCur	= FindFilesByExtension(cPathDICOM{k},'dcm','usequick',true);
			
			strDirOut	= AddSlash(PathAddSuffix(cPathDICOM{k},opt.suffix));
			if ~CreateDirPath(strDirOut)
				error(['Could not create directory path ' strDirOut]);
			end
			
			cPathIn		= [cPathIn; cPathInCur];
			cPathOut	= [cPathOut; cellfun(@(x) [strDirOut PathGetFileName(x)],cPathInCur,'UniformOutput',false)];
		else
			cPathIn		= [cPathIn; cPathDICOM{k}];
			cPathOut	= [cPathOut; PathAddSuffix(cPathDICOM{k},opt.suffix)];
		end
	end
	
%scale each file
	nPath	= numel(cPathIn);
	
	if ~opt.silent
		progress(nPath,'label','Scaling DICOM Image');
	end
	
	for k=1:nPath
		ifo	= dicominfo(cPathIn{k});
		im	= dicomread(ifo);
		
		%get the new range
			if isempty(vMin)
				vMinCur	= double(min(im(:)));
			else
				vMinCur	= vMin;
			end
			
			if isempty(vMax)
				vMaxCur	= double(max(im(:)));
			else
				vMaxCur	= vMax;
			end
		%scale the image
			c	= class(im);
			im	= double(im);
			im	= normalize(im,'min',vMinCur,'max',vMaxCur);
			im	= cast(im,c);
		%save the output image
			dicomwrite(im,cPathOut{k},ifo,'CreateMode','copy');
		
		if ~opt.silent
			progress;
		end
	end
