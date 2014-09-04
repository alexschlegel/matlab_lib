classdef Info < PTB.Object
% Info
% 
% Description:	object to share information among PTB classes
% 
% Syntax:	ifo = PTB.Info(parent,<options>)
% 
% 			subfunctions:
%				Start:		start the object
%				End:		end the object
%				SetName:	set the name of the info struct
%				Set:		set an info value
%				Unset:		unset an info value
%				Get:		get an info value
%				SetAll:		replace the entire info struct
%				GetAll:		get the entire info struct
%				Save:		save the info struct to file
%				AutoSave:	start autosaving the info struct
%				Load:		load the info struct from file
% 
% In:
%	parent	- the parent object
% 	<options>:
% 
% Updated: 2011-12-24
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
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
		function ifo = Info(parent)
			ifo	= ifo@PTB.Object(parent,'info');
		end
		%----------------------------------------------------------------------%
		function Start(ifo,varargin)
			%initialize the global info struct
			global PTBIFO;
			
				if isempty(PTBIFO) || isequal(PTBIFO,struct)
					ifo.Clear;
				else
					res	= ifo.parent.Prompt.Ask('Session info exists in memory.  Reuse or clear it?','choice',{'reuse','clear'});
					if ~isequal(res,'reuse')
						ifo.Clear;
					end
				end
		end
		%----------------------------------------------------------------------%
		function End(ifo,varargin)
			%save one last time
				ifo.Save;
				
				strStatus	= ['session info struct saved to: "' ifo.parent.File.Get('session') '"'];
				ifo.parent.Status.Show(strStatus,'time',false);
				
				ifo.Clear;
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	methods
		
	end
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	
	
	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Access=private)
		
	end
	%PRIVATE METHODS-----------------------------------------------------------%
	
end
