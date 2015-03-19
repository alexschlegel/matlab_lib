function [w,stat] = svr(x,y,varargin)
% svr
% 
% Description:	use support vector regression to predict a continuous
%				multidimensional variable
% 
% Syntax:	[w,stat] = svr(x,y,<options>)
% 
% In:
% 	x	- an N x M array of N M-dimensional predictor patterns
%	y	- an N x K array of N K-dimensional continuous values to predict
% 
% Out:
% 	w	- the N x K predicted values of y 
% 
% Updated: 2015-03-06
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent strTemplate;

if isempty(strTemplate)
	strPathTemplate	= PathAddSuffix(mfilename('fullpath'),'','template');
	strTemplate		= fget(strPathTemplate);
end

[N,M]	= size(x);
K		= size(y,2);

%save the data to a temporary file
	strPathData		= GetTempFile('ext','mat');
	strPathOut		= PathAddSuffix(strPathData,'output');
	strPathScript	= PathAddSuffix(strPathData,'script','py');
	
	%reshape for python
		X	= x;
		Y	= y';
	
	save(strPathData,'X','Y');

%fill and save the script template
	s.creation_time	= FormatTime(nowms);
	s.path_data		= strPathData;
	s.path_out		= strPathOut;
	
	strScript	= StringFillTemplate(strTemplate,s);
	
	fput(strScript,strPathScript);

%call the python script
	[ec,str]	= RunBashScript(['python ' strPathScript],'silent',true);
	
	if ec~=0
		DeleteFiles;
		error(str);
	end

%get the results
	res	= load(strPathOut);
	
	w	= res.W';

%calculate stats
	[cY,cW]	= varfun(@(x) mat2cell(x,N,ones(K,1))',y,w);
	
	[r,stat]	= cellfun(@(y,w) corrcoef2(y,w'),cY,cW);
	
	stat	= restruct(stat);
	stat.r	= r;

%delete the temporary files
	DeleteFiles;

%------------------------------------------------------------------------------%
function DeleteFiles
	delete(strPathData);
	delete(strPathOut);
	delete(strPathScript);
end
%------------------------------------------------------------------------------%

end
