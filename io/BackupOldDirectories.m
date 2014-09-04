function [cDirBackup,cDirBackupErr,cDirDelete,cDirDeleteErr] = BackupOldDirectories(varargin)
% BackupOldDirectories
% 
% Description:	backup directories containing old information
% 
% Syntax:	[cDirBackup,cDirBackupErr,cDirDelete,cDirDeleteErr] = BackupOldDirectories(<options>)
% 
% In:
%	<options>:
%		'prompt':	(true) true to prompt user before performing actions
%		'copy':		(true) true to copy the _old directories to the backup
%					location
%		'delete':	(true) true to delete backed up folders
% 
% Out:
%	cDirBackup		- a cell of directories successfully backed up
%	cDirBackupErr	- a cell of directories not successfully backed up
%	cDirDelete		- a cell of directories successfully deleted
%	cDirDeleteErr	- a cell of directories not successfully deleted
% 
% Updated: 2014-01-29
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
strDirOld	= '_old';

opt	= ParseArgsOpt(varargin,...
		'prompt'	, true	, ...
		'copy'		, true	, ...
		'delete'	, true	  ...
		);

strDirSrc	= '/home/alex/backup_src/';
strDirDst	= DirAppend('/home/alex',strDirOld);

%find the directories to move
	cDirOld	= FindDirectories(strDirSrc,'^_old$',...
				'subdir'	, true	, ...
				'progress'	, true	  ...
				);
	nDirOld	= numel(cDirOld);
%get the split directory paths
	cDirOldSplit	= cellfun(@DirSplit,cDirOld,'uni',false);
%eliminate olds within olds
	bKeep	= cellfun(@(x) numel(FindCell(x,strDirOld))==1,cDirOldSplit);
	
	cDirOld			= cDirOld(bKeep);
	cDirOldSplit	= cDirOldSplit(bKeep);
	nDirOld			= numel(cDirOld);
%copy the directories
	cDirBackup			= {};
	cDirBackupErr		= {};
	
	bCopy	= false;
	if opt.copy
		if opt.prompt
			strPrompt	= plural(nDirOld,sprintf('Found %d director{y,ies} to backup. List?',nDirOld));
			if askyesno(strPrompt,'title','List Directories?')
				disp(char(cDirOld));
			end
			
			bCopy	= askyesno('Continue with backup?','title','Backup?');
		else
			bCopy	= true;
		end
		
		if bCopy
			%get the destination directories
				cDirTo	= cellfun(@(x) PathChangeBase(x,strDirSrc,strDirDst),cDirOld,'UniformOutput',false);
			%copy the files
				bSuccess	= cellfunprogress(@(x,y) FileCopy(x,y,'createpath',true),cDirOld,cDirTo,'label','Backing up directories','status',1);
			%which ones worked?
				cDirBackup		= cDirOld(bSuccess);
				cDirBackupErr	= cDirOld(~bSuccess);
		end
	end
	
	nDirBackup		= numel(cDirBackup);
	nDirBackupErr	= numel(cDirBackupErr);
	
	strPluralB	= GetPlural(nDirBackup,'ies','y');
	strPluralBE	= GetPlural(nDirBackupErr,'s','');
%delete
	cDirDelete		= {};
	cDirDeleteErr	= {};
	
	bDelete	= false;
	if opt.delete
		if bCopy
			cDirToDelete	= cDirBackup;
		else
			cDirToDelete	= cDirOld;
		end
		nDirToDelete	= numel(cDirToDelete);
		
		if opt.prompt
			strPlural	= GetPlural(nDirToDelete,'ies','y');
			res			= ask([num2str(nDirToDelete) ' director' strPlural ' found to delete.  List?'],'title','List Directories?','choice',{'Yes','No'},'default','Yes');
			if isequal(res,'Yes')
				disp(char(cDirToDelete));
			end
			res			= ask('Continue with deletion?','title','Delete?','choice',{'Yes','No'},'default','Yes');
			
			bDelete	= isequal(res,'Yes');
		else
			bDelete	= true;
		end
		
		if bDelete
			%delete the files
				bSuccess	= cellfunprogress(@(x) rmdir(x,'s'),cDirToDelete,'label','Deleteing source directories','status',true);
			%which ones worked?
				cDirDelete		= cDirToDelete(bSuccess);
				cDirDeleteErr	= cDirToDelete(~bSuccess);
		end
	end
	
	nDirDelete		= numel(cDirDelete);
	nDirDeleteErr	= numel(cDirDeleteErr);
	
	strPluralD	= GetPlural(nDirDelete,'ies','y');
	strPluralDE	= GetPlural(nDirDeleteErr,'s','');
%finished!
	n	= status('Done!');
	if bCopy
		status([num2str(nDirBackup) ' director' strPluralB ' backed up successfully'],n+1);
		status([num2str(nDirBackupErr) ' directory backup' strPluralBE ' failed'],n+1);
	end
	if bDelete
		status([num2str(nDirDelete) ' director' strPluralD ' deleted successfully'],n+1);
		status([num2str(nDirDeleteErr) ' directory deletion' strPluralDE ' failed'],n+1);
	end
