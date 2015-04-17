function PhotoRenamer(strDirPhoto)
% PhotoRenamer
% 
% Description:	show each photo in a folder and prompt for a new file name
% 
% Syntax:	PhotoRenamer(strDirPhoto)
% 
% Updated: 2015-04-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
cPathPhoto	= FindFilesByExtension(strDirPhoto,'jpg');
nPhoto		= numel(cPathPhoto);

progress('action','init','total',nPhoto,'label','Renaming photos');
for kP=1:nPhoto
	im	= imread(cPathPhoto{kP});
	
	hF	= figure;
	imshow(im);
	
	strFileOld		= PathGetFilePre(cPathPhoto{kP});
	strFilePrompt	= sprintf('%s_',FormatTime(PhotoDate(cPathPhoto{kP}),'yyyymmdd'));
	strFile			= ask(sprintf('Old file name: %s\nNew file name (blank to keep):',strFileOld),...
						'title'		, mfilename		, ...
						'default'	, strFilePrompt	  ...
						);
	
	if isempty(strFile) && ~ischar(strFile)
		return;
	end
	
	if ~isempty(strFile)
		[strDir,dummy,strExt]	= PathSplit(cPathPhoto{kP});
		strPathOut				= PathUnsplit(strDir,strFile,strExt);
		
		movefile(cPathPhoto{kP},strPathOut);
	end
	
	close(hF);
	
	progress;
end

end
