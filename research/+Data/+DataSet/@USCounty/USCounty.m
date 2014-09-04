classdef USCounty < Data.DataSet
% Data.DataSet.USCounty
% 
% Description:	US counties
% 
% Syntax:	ds = Data.DataSet.USCounty()
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
% Updated: 2013-03-09
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
		function ds = USCounty()
			ds.name	= 'uscounty';
			
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
