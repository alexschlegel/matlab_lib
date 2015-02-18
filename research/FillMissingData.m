function [x,kNaN] = FillMissingData(x,varargin)
% FillMissingData
% 
% Description:	interpolate NaN data
% 
% Syntax:	x = FillMissingData(x,[dim]=1,[strInterp]='mid')
% 
% In:
% 	x			- an array of data with missing values set to NaN
%	[dim]		- the dimension across which to interpolate.  set to the string
%				  'n' to interpolate points in a multidimensional array.
%	[strInterp]	- the interpolation method.  either an argument to interp1 or one
%				  of the following:
%					'mid': use the midpoint of the surrounding values
%					'mean': use the mean of all non-NaN values in the
%						interpolation dimension
% 
% Out:
% 	x		- x with missing data filled in
%	kNaN	- the indices of the missing data
% 
% Updated: 2015-2-17
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[dim,strInterp]	= ParseArgs(varargin,1,'mid');

if isequal(dim,'n')
	error('not implemented!');
else
	s	= size(x);
	nd	= numel(s);
	
	%get the vectors to interpolate
		kNaN	= find(isnan(x));
		nNaN	= numel(kNaN);
		
		if nNaN==0
			return;
		end
		
		cKNaN		= cell(nd,1);
		[cKNaN{:}]	= ind2sub(s,kNaN);
		kDimNaN		= num2cell(cKNaN{dim});
		cKNaN		= arrayfun(@(varargin) num2cell(cat(1,varargin{:})),cKNaN{:},'UniformOutput',false);
		
		xInterp	= cellfun(@(k) reshape(x(k{1:dim-1},(1:s(dim)),k{dim+1:end}),[],1),cKNaN,'UniformOutput',false);
	%interp
		x(kNaN)	= cellfun(@InterpOne,xInterp,kDimNaN);
end

%------------------------------------------------------------------------------%
function xF = InterpOne(xInterp,kDimNaN)
	switch lower(strInterp)
		case 'mid'
			kFPre	= find(~isnan(xInterp(1:kDimNaN-1)),1,'last');
			kFPost	= kDimNaN + find(~isnan(xInterp(kDimNaN+1:end)),1,'first');
			
			if ~isempty(kFPre)
				if ~isempty(kFPost)
					xF	= (xInterp(kFPre) + xInterp(kFPost))/2;
				else
					xF	= xInterp(kFPre);
				end
			elseif ~isempty(kFPost)
				xF	= xInterp(kFPost);
			else
				xF	= 0;
			end
		case 'mean'
			xF = unless(nanmean(xInterp),0);
		otherwise
			k	= (1:numel(xInterp))';
			b	= ~isnan(xInterp);
			xF	= interp1(k(b),xInterp(b),kDimNaN,strInterp,'extrap');
	end
end
%------------------------------------------------------------------------------%

end
