classdef File < PTB.Object
% PTB.File
% 
% Description:	use to save and read files
% 
% Syntax:	f = PTB.File(parent)
% 
% 			subfunctions:
% 				Start(<options>):	initialize the object
%				End:				end the object
%				GetDirectory:		get the path to a named directory
%				SetDirectory:		set the path to a name directory
%				Get:				get the path to a named file
%				Set:				set the path to a named file
%				Exists:				check to see if a named file exists
%				Write:				write data to a named file
%				Append:				append data to a named text file
%				AppendLine:			append a line to a named text file
%				Read:				read data from a named file
%				Open:				open a file for fast writing later
%				Close:				close a file opened with PTB.File.Open
% 
% In:
%	parent	- the parent object
% 	<options>:
%	 	dir_base:	(<auto>) the base directory for files
% 
% Updated: 2015-03-11
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=private, GetAccess=private)
		
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function f = File(parent)
			f	= f@PTB.Object(parent,'file');
		end
		%----------------------------------------------------------------------%
		function Start(f,varargin)
		% initialize the file object
			opt	= ParseArgs(varargin,...
					'dir_base'	, []	  ...
					);
			
			if ~IsWritable(f.GetDirectory('base'))
			%no working base directory
				if ~isempty(opt.dir_base)
				%use the specified base directory
					f.SetDirectory('base',opt.dir_base,'replace',false);
				else
				%get the default base directory
					global strDirBase;
					
					if IsWritable(strDirBase)
					%someone set a base directory
						strDir	= strDirBase;
					elseif IsWritable(pwd)
					%just use the current directory
						strDir	= pwd;
					else
						strDirHome		= GetDirUser;
						strDirHomeTemp	= DirAppend(strDirHome,'temp');
						
						if IsWritable(strDirHomeTemp)
						%use the user's home/temp directory
							strDir	= strDirHomeTemp;
						elseif IsWritable(strDirHome)
						%just the user's home directory
							strDir	= strDirHome;
						elseif IsWritable(tempdir)
						%use the temp directory
							strDir	= tempdir;
						else
						%die!
							error('Could not find a writable base directory.');
						end
					end
					
					f.SetDirectory('base',strDir,'replace',false);
				end
			end
			
			strDirBase	= f.GetDirectory('base');
			f.SetDirectory('data',DirAppend(strDirBase,'data'),'replace',false);
			f.SetDirectory('code',DirAppend(strDirBase,'code'),'replace',false);
			f.SetDirectory('analysis',DirAppend(strDirBase,'analysis'),'replace',false);
		end
		%----------------------------------------------------------------------%
		function End(f,varargin)
		% end the file object
			%close all open files
				fid		= f.parent.Info.Get('file','fid');
				if ~isempty(fid)
					fid		= struct2array(fid);
					nFID	= numel(fid);
					
					for kF=1:nFID
						try
							%don't use f.Close here so that we treat it as opened
							%if we start back up again
							fclose(fid(kF));
						catch me
						end
					end
				end
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
