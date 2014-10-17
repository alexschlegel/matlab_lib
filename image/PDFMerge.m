function b = PDFMerge(cPathPDF,strPathOut,varargin)
% PDFMerge
% 
% Description:	merge pdfs
% 
% Syntax:	b = PDFMerge(cPathPDF,strPathOut,<options>)
% 
% In:
% 	cPathPDF	- a cell of paths to PDF files
%	strPathOut	- the output PDF file path
%	<options>:
%		delete:	(false) true to delete the input files
%
% Out:
%	b	- true if the merge was successful
% 
% Updated: 2012-12-08
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'delete'	, false	  ...
		);

%copy or move the files to a temporary location
	strDirTemp	= GetTempDir;
	
	if opt.delete
		cellfun(@(f) movefile(f,strDirTemp),cPathPDF);
	else
		cellfun(@(f) copyfile(f,strDirTemp),cPathPDF);
	end
%merge!
	b	= ~CallProcess('pdftk',{PathUnsplit(strDirTemp,'*','pdf') 'cat' 'output' strPathOut})
%delete the temporary directories
	rmdir(strDirTemp,'s');
