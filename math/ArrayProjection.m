function im = ArrayProjection(d,pViewer,dWin,sWin,rWin,sIm,varargin)
% ArrayProjection
% 
% Description:	
% 
% Syntax:	[] = ()
% 
% In:
% 		- 
% 
% Out:
% 		- 
% 
% Side-effects:	
% 
% Assumptions:	
% 
% Notes:	
% 
% Example:	
% 
% Updated: 2012-03-29
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'type'		, 'max'	, ...
		'thresh'	, 0		  ...
		);

s	= size(d);

pViewer	= reshape(pViewer,[],1);

%point at center of the data
	pCenterData	= ArrayCenter(d);
%vector from array center to viewer point
	v2Viewer	= pViewer - pCenterData;
	v2Viewer	= v2Viewer./sqrt(dot(v2Viewer,v2Viewer));
%get the point at the center of the window
	pCenterWin	= pCenterData + dWin.*v2Viewer;
%get vectors pointing in the two image directions
	v23		= v2Viewer(3)/v2Viewer(2);
	vIm1	= [0 -v23/sqrt(v23^2+1) 1/sqrt(v23^2+1)];
	vIm2	= cross(v2Viewer',vIm1);
%rotate the vectors
	vIm1R	= RotatePoints(vIm1,vIm1',vIm2',rWin)';
	vIm2R	= RotatePoints(vIm2,vIm1',vIm2',rWin)';

im		= zeros(sIm);
step	= GetInterval(-1,1,sIm);

pH	= repmat(pCenterWin,[1 sIm]) + sWin .* repmat(vIm1R,[1 sIm]) .* repmat(step,[3 1]);
for kH=1:sIm
	pV	= repmat(pH(:,kH),[1 sIm]) + sWin .* repmat(vIm2R,[1 sIm]) .* repmat(step,[3 1]);
	for kV=1:sIm
		p	= pV(:,kV);
		v	= p - pViewer;
		
		a	= ArrayPierce(d,p,v);
		if isempty(a)
			im(kV,kH)	= 0;
		else
			switch opt.type
				case 'max'
					im(kV,kH)	= max(a);
				case 'first'
					k	= find(a>opt.thresh,5);
					if isempty(k)
						imCur	= 0;
					else
						imCur	= a(k(end));
					end
					
					im(kV,kH)	= imCur;
			end
		end
	end
end
