classdef DataSet < handle
% Data.DataSet
% 
% Description:	base class for data sets
% 
% Syntax:	ds = Data.DataSet()
% 
% 			subfunctions:
%				Load		- load existing data
%				Save		- save data to file
%				Update		- update the dataset
%				Parse		- parse downloaded data
%				Download	- download the raw data
% 
% 			properties:
% 				name:		dataset name
%				data_dir:	the data directory
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
		name		= 'dataset';
		data_dir	= '';
		data_path	= '';
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
% 		function p = set.xStim(p,xStim)
% 			p.xStim	= xStim;
% 			p.x		= reshape(unique(xStim),[],1);
			
% 			p_GetFit(p);
% 		end
		function strDirData = get.data_dir(ds)
			strDirData	= DirAppend(Data.Path.Data,ds.name);
		end
		function strPathData = get.data_path(ds)
			strPathData	= PathUnsplit(ds.data_dir,'data','mat');
		end
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function ds = DataSet()
			
		end
		function Init(ds)
			CreateDirPath(ds.data_dir);
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
