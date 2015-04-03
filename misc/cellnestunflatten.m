function cn = cellnestunflatten(cf,uf)
% cellnestunflatten
% 
% Description:	unflatten a nested cell previously flattened with
%				cellnestunflatten
% 
% Syntax:	cn = cellnestunflatten(cf,uf)
% 
% Updated: 2015-03-22
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if isequalwithequalnans(uf.s,NaN)
	cn	= cf{1};
elseif isstruct(uf.s)
	cn	= reshape(mat2cell(cf,[uf.s.n],1),size(uf.s));
	cn	= cellfun(@cellnestunflatten,cn,num2cell(uf.s),'uni',false);
else
	cn	= reshape(cf,uf.s);
end
