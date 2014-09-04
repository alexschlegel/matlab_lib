classdef ACS < Data.DataSet
% Data.DataSet.ACS
% 
% Description:	American Community Survey data
% 
% Syntax:	ds = Data.DataSet.ACS()
% 
% 			subfunctions:
%				Load		- load existing data
%				Save		- save data to file
%				Update		- update the dataset
%				Parse		- parse downloaded data
%				Download	- download the raw data
% 
% 			properties:
% 
% In:
%
% Example:
% 
% Updated: 2013-03-10
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		
	end
	properties (SetAccess=protected)
		
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function ds = ACS()
			ds.name	= 'acs';
			
			ds.Init();
		end
	end
	methods (Static)
		
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
