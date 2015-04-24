function y = squareform2(x,varargin)
% squareform2
% 
% Description:	like squareform, but also supports cell arrays and conversion of
%				directed distance matrices
% 
% Syntax:	y = squareform2(x,[strTo]=<auto>,<options>)
% 
% In:
% 	x		- either a square matrix representing a directed or undirected
%			  distance matrix, or the vector form of that matrix
%	strTo	- a string specifying the transformation direction (see squareform)
%	<options>:
%		directed:	(<auto>) true to force the input to be treated as a directed
%					distance matrix. if unspecified, vectors will be determined
%					directed or undirected based on length, and matrices based
%					on whether the upper and lower halves are identical.
% 
% Out:
% 	y	- see squareform
% 
% Updated: 2015-04-20
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	sz		= size(x);
	nd		= numel(sz);
	n		= numel(x);
	bSquare	= uniform(sz);
	
	assert(nd==2,'invalid input dimensionality.');
	
	[strTo,opt]	= ParseArgs(varargin,[],...
					'directed'	, []	  ...
					);
	
	if isempty(strTo)
		strTo	= conditional(bSquare,'tovector','tomatrix');
	end
	
	strTo	= CheckInput(strTo,'transformation direction',{'tovector','tomatrix'});

switch strTo
	case 'tovector'
		assert(bSquare,'input must be a square matrix');
		
		if isempty(opt.directed)
			bAll	= true(sz);
			bLower	= tril(bAll,-1);
			xTrans	= x';
			
			switch class(x)
				case 'cell'
					opt.directed	= ~all(cellfun(@isequal,x(bLower),xTrans(bLower)));
				otherwise
					opt.directed	= ~all(x(bLower)==xTrans(bLower));
			end
		end
		
		if opt.directed
			b	= ~logical(eye(sz));
			y	= x(b);
		else
			switch class(x)
				case 'cell'
					sz		= size(x,1);
					k		= triu(reshape(1:numel(x),[sz sz]),1);
					k		= k + k';
					k		= squareform(k,'tovector');
					
					y	= x(k);
				otherwise
					y	= squareform(x,'tovector');
			end
		end
	case 'tomatrix'
		bRow	= sz(2)~=1;
		if bRow
			sz	= sz(end:-1:1);
			x	= x';
		end
		
		assert(sz(2)==1,'input must be a vector');
		
		if isempty(opt.directed)
			m				= ceil(sqrt(2*n));
			opt.directed	= m*(m-1)/2 ~= n;
		end
		
		if opt.directed
			%we should have m^2 - m values
				m	= (1 + sqrt(1+4*n))/2;
				assert(m==fix(m),'vector size is incorrect.');
			
			b		= ~logical(eye(m));
			
			switch class(x)
				case 'cell'
					y	= cell(m);
				otherwise
					y	= zeros(m);
			end
			y(b)	= x;
		else
			switch class(x)
				case 'cell'
					k	= 1:numel(x);
					k	= squareform(k,'tomatrix');
					
					m		= size(k,1);
					y		= cell(m);
					b		= k~=0;
					y(b)	= x(k(b));
				otherwise
					y	= squareform(x,'tomatrix');
			end
		end
end
