function cPathOut = PDFExtract(strPathPDF,varargin)
% PDFExtract
% 
% Description:	extract images from a PDF file.  requires ImageMagick.
% 
% Syntax:	cPathOut = PDFExtract(strPathPDF,[strDirOut]=<input dir>,<options>)
% 
% In:
% 	strPathPDF	- the path to a PDF file
%	strDirOut	- the output directory
%	<options>:
%		dpi:	(300) the output resolution, in dots per inch
%		ext:	('png') the extension of the output files
%		start:	(1) the first image to extract
%		end:	(<end>) the last image to extract
%		resetn:	(false) true to reset the output numbers to 1-n rather than
%				keeping opt.start-opt.end
%		force:	(true) true to force extraction even if all output files already
%				exist.  if this is false then 'end' must be specified.
% 
% Out:
% 	cPathOut	- a cell or cell of cells of output files
% 
% Updated: 2011-11-01
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[strDirOut,opt]	= ParseArgs(varargin,[],...
					'dpi'		, 300	, ...
					'ext'		, 'png'	, ...
					'start'		, 1		, ...
					'end'		, []	, ...
					'resetn'	, false	, ...
					'force'		, true	  ...
					);
strDirOut	= unless(strDirOut,PathGetDir(strPathPDF));

%get the output file names
	strFilePre	= PathGetFilePre(strPathPDF);
	if ~isempty(opt.end)
		nFill		= numel(num2str(opt.end));
		kOut		= conditional(opt.resetn,1:(opt.end-opt.start+1),opt.start:opt.end)';
		cPathOut	= arrayfun(@(k) PathUnsplit(strDirOut,[strFilePre '-' StringFill(k,nFill)],opt.ext),kOut,'UniformOutput',false);
	else
		cPathOut	= {};
	end

if opt.force || isempty(cPathOut) || ~all(FileExists(cPathOut))
	%we'll extract first to a temporary directory
		strDirTemp	= GetTempDir;
		strTempBase	= PathUnsplit(strDirTemp,PathGetFilePre(strPathPDF));
	%get the script
		strScriptBase	= ['convert -density ' num2str(opt.dpi) ' '];
		if isempty(opt.end)
			bAll		= true;
			strScript	= [strScriptBase strPathPDF ' ' strTempBase '.' opt.ext];
		else
			bAll		= false;
			strStart	= num2str(opt.start-1);
			strEnd		= num2str(opt.end-1);
			strScript	= [strScriptBase strPathPDF '[' strStart '-' strEnd '] ' strTempBase '.' opt.ext];
		end
	%run the script
		[ec,strOutput]	= RunBashScript(strScript);
	%move the files to the destination
		%create the output directory
			CreateDirPath(strDirOut,'error',true);
		%get the actual output files
			cPathOutTemp	= FindFiles(strDirTemp);
			nOut			= numel(cPathOutTemp);
			opt.end			= unless(opt.end,nOut);
		%order by page number
			re				= ['(?<n>\d+)\.' opt.ext '$'];
			n				= cellfun(@(f) str2num(GetFieldPath(regexp(f,re,'names'),'n')),cPathOutTemp);
			[n,kOrder]		= sort(n);
			cPathOutTemp	= cPathOutTemp(kOrder);
			
			if bAll
				cPathOutTemp	= cPathOutTemp(opt.start:end);
			end
		
		if isempty(cPathOut)
			nFill		= numel(num2str(nOut));
			kOut		= conditional(opt.resetn,1:(opt.end-opt.start+1),opt.start:opt.end)';
			cPathOut	= arrayfun(@(k) PathUnsplit(strDirOut,[strFilePre '-' StringFill(k,nFill)],opt.ext),kOut,'UniformOutput',false);
		end
		
		nOut	= min(nOut,numel(cPathOut));
		b		= cellfun(@(f1,f2) movefile(f1,f2,'f'),cPathOutTemp(1:nOut),cPathOut(1:nOut));
	%delete the temp directory
		RunBashScript(['rm -r ' strDirTemp]);
end
