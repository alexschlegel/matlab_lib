function [stl,p] = STLTranslate(stl,p,varargin)
% STLTranslate
% 
% Description:	translate an STL object
% 
% Syntax:	[stl,p] = STLTranslate(stl,p,[strType]='relative')
% 
% In:
% 	stl			- an STL object
%	p			- a 3-element point
%	[strType]	- the type of translation to perform:
%					'relative':	move all points by p
%					'center':	center model on point p
% 
% Out:
% 	stl	- the STL object with points translated
%	p	- the vector by which the STL object was translated
% 
% Updated:	2009-06-09
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
strType	= ParseArgs(varargin,'relative');

sP	= size(p);
p	= reshape(p,1,1,3);

nVertex	= size(stl.Vertex,1);

switch lower(strType)
	case 'relative'
		pRep		= repmat(p,[nVertex 3 1]);
		stl.Vertex	= stl.Vertex + pRep;
	case 'center'
		%get the center of the mesh
			pCenter	= mean(reshape(stl.Vertex,[],3),1);
			pCenter	= reshape(pCenter,1,1,3);
		%get the translation
			p	= p - pCenter;
		%translate
			pRep		= repmat(p,[nVertex 3 1]);
			stl.Vertex	= stl.Vertex + pRep;
	otherwise
		error(['"' strType '" is an invalid translation type']);
end

p	= reshape(p,sP);
