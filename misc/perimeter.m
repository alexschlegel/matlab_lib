function [p,k] = perimeter(x)
% perimeter
% 
% Description:	get the perimeter of an array
% 
% Syntax:	[p,k] = perimeter(x)
% 
% In:
% 	x	- an ND array
% 
% Out:
% 	p	- the values along the perimeter
%	k	- the indices of the values in p
% 
% Updated: 2012-07-07
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
s	= size(x);
nd	= numel(s);

k	= arrayfun(@GetPerimeterKs,(1:nd)','UniformOutput',false);
k	= cat(1,k{:});
k	= mat2cell(k,size(k,1),ones(nd,1));
k	= unique(sub2ind(s,k{:}));

p	= x(k);


%------------------------------------------------------------------------------%
function k = GetPerimeterKs(d)
	sD	= s(d);
	sO	= s([1:d-1 d+1:end]);
	kD	= (1:s(d))';
	
	b	= cellfun(@str2num,num2cell(dec2bin((0:2.^(numel(s)-1)-1)')));
	nB	= size(b,1);
	kO	= 1 + repmat(sO-1,[nB 1]).*b;
	
	k	= [];
	for kB=1:nB
		k	= [k; repmat(kO(kB,1:d-1),[sD 1]) kD repmat(kO(kB,d:end),[sD 1])];
	end
end
%------------------------------------------------------------------------------%

end
