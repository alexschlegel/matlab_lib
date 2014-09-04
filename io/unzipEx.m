function zFiles = unzipEx(strFileZip,varargin)
% UNZIPEX
%
% Description:	an extension to MATLAB's unzip function
%
% Syntax:	[[zFiles]] = unzipEx(strFileZip,strCommand,<args>)
%
% In:
%	strFileZip				- the path to the zip file
%	strCommand/<args>		- the operation to perform on the zip file
%		'extractall'/[strDirOut]=pwd,['include path']: (default)
%			extract all files in the zip file to the specified output directory.
%			optionally give argument 'include path' to include any path
%			information in the output file name
%		'extract'/strFile,[strDirOut]=pwd,['include path']:
%			extract the specified file strFile to the specified output
%			directory.  optionally give argument 'include path' to include any
%			path information in the output file name
%		'view'/['include path']:
%			return a cell containing the contents of the zip file.  optionally
%			give the second argument 'include path' to include any path
%			information in the output file name.
%
% Side-effects:	creates strDirOut if it doesn't exist
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
import java.util.zip.ZipFile;

[strCommand,arg1,arg2,arg3]	= ParseArgs(varargin,'extractall','','','');

z		= ZipFile(strFileZip);

switch strCommand
	case 'extractall'
		zFiles	= zipGetFiles(z);
		nFiles	= numel(zFiles);
		
		bIncludePath	= isequal(lower(arg2),'include path');
		if isempty(arg2)
			arg2	= pwd;
		end
		arg2	= AddSlash(arg2);
		
		wb	= waitbar(0,'Extracting Files');
		for k=1:nFiles
			zEntry	= z.getEntry(zFiles{k});
			
			if ~bIncludePath
				[strPath,strFile,strExt]	= strPathSplit(zFiles{k});
				zFiles{k}					= [strFile '.' strExt];
			end
			
			strFileOut	= [arg2 zFiles{k}];
			ExtractEntry(z,zEntry,strFileOut);
			
			waitbar(k/nFiles,wb);
		end
		close(wb);
		
		interruptibleStreamCopier	= InterruptibleStreamCopier.getInterruptibleStreamCopier;
	case 'extract'
		zEntry	= z.getEntry(arg1);
		
		if ~isempty(zEntry)
			if ~isequal(lower(arg3),'include path')
				[strPath,strFile,strExt]	= strPathSplit(arg1);
				arg1						= [strFile '.' strExt];
			end
			
			if isempty(arg2)
				arg2	= pwd;
			end
			
			strFileOut	= [AddSlash(arg2) arg1];
			ExtractEntry(z,zEntry,strFileOut);
		else
			error(['''' arg1 ''' is not an entry in the specified zip file']);
		end
	case 'view'
		zFiles	= zipGetFiles(z);
		
		if ~isequal(lower(arg1),'include path');
			for k=1:numel(zFiles)
				[strPath,strFile,strExt]	= strPathSplit(zFiles{k});
				zFiles{k}					= [strFile '.' strExt];
			end
		end
	otherwise
		error(['''' strCommand ''' is an invalid command.']);
end

z.close;


%-------------------------------------------------------------------------------
function zFiles = zipGetFiles(z)
	enum	= z.entries;
	
	n		= z.size;
	zFiles	= cell(1,n);
	
	wb	= waitbar(0,'Retrieving Zip File Contents');
	for k=1:n
		zFiles{k}	= char(enum.nextElement.getName);
		
		waitbar(k/n,wb);
	end
	close(wb);
%-------------------------------------------------------------------------------
function ExtractEntry(z,zEntry,strFileOut)
import java.io.* com.mathworks.mlwidgets.io.InterruptibleStreamCopier;

	outFile		= java.io.File(strFileOut);
	
	if zEntry.isDirectory
		outFile.mkdirs;
	else
		outParent	= File(outFile.getParent);
		outParent.mkdirs;
	end
	
	sCopier			= InterruptibleStreamCopier.getInterruptibleStreamCopier;
	outFileStream	= java.io.FileOutputStream(outFile);
	inFileStream	= z.getInputStream(zEntry);
	
	sCopier.copyStream(inFileStream,outFileStream);
	
	inFileStream.close;
	outFileStream.close;
	
	outFile.setLastModified(zEntry.getTime);
%-------------------------------------------------------------------------------
