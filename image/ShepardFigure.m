function [im,msk,hF] = ShepardFigure(k,varargin)
% ShepardFigure
% 
% Description:	render a Shepard/Metzler figure
% 
% Syntax:	[im,msk,hF] = ShepardFigure(k,<options>)
% 
% In:
% 	k	- the figure number (1-8)
%	<options>:
%		tx:				('') a string specifying the transformations to perform
%						on the figure. takes the form
%							'<x1>[<n1>] <x2>[<n2>] ... <xN>[<nN>]'
%						where <xK> is the operation and possible <nK> is the
%						parameter for the operation. possible operations are:
%							RX:	rotate around x-axis nK degrees
%							RY:	rotate around y-axis nK degrees
%							RZ:	rotate around z-axis nK degrees
%							RB:	"back" rotate nK degrees
%							RF:	"forward" rotate nK degrees
%							RL:	"left" rotate nK degrees
%							RR:	"right" rotate nK degrees
%							FX:	flip along x-axis (no parameter)
%							FY:	flip along y-axis (no parameter)
%							FZ:	flip along z-axis (no parameter)
%						e.g. 'RX-90 RF45.5 FX' rotate -90 degrees around the
%						x-axis, then rotates forward 45.5 degrees, then flips
%						along the x-axis.
%		figure_size:	(500) the figure size, in pixels
%		view:			([30 15 0]) the rotation to introduce around each axis
%						for the viewpoint, in degrees
%		background:		([0.5 0.5 0.5]) the background color
%		axis_radius:	(3.5) the axis radius from the origin to include in the
%						viewport
%		thickness:		(0.5) the line thickness (maybe in points? not sure)
% 
% Out:
% 	im	- the figure
%	msk	- a binary mask of the figure
%	hF	- the handle to the figure containing the Shepard/Metzler figure
% 
% Updated: 2015-02-10
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent figs xCube yCube zCube szCube pCube;

if isempty(figs)
	figs	=	{
					[0 0 1;  0 0 0; -1 0 0; -2 0 0; -3 0 0; -3 0 1; -3 0 2; -3 0 3; -3 -1 3; -3 -2 3]
					[0 1 0;  0 0 0; -1 0 0; -2 0 0; -3 0 0; -3 0 1; -3 0 2; -3 0 3; -3 -1 3; -3 -2 3]
					[0 0 -1; 0 0 0; -1 0 0; -2 0 0; -3 0 0; -3 0 1; -3 0 2; -3 0 3; -3 1 3; -3 2 3]
					[0 1 0;  0 0 0; -1 0 0; -2 0 0; -3 0 0; -3 0 1; -3 0 2; -3 0 3; -4 0 3; -5 0 3]
					[0 0 0; -1 0 0; -2 0 0; -3 0 0; -3 0 1; -3 0 2; -3 0 3; -3 1 3; -3 2 3; -4 2 3]
					[0 0 0; 0 1 0; 0 2 0; 0 3 0; -1 3 0; -2 3 0; -2 3 1; -2 3 2; -2 3 3; -2 4 3]
					[0 -1 0; 0 -2 0; 0 0 0; -1 0 0; -2 0 0; -3 0 0; -3 0 1; -3 0 2; -3 0 3; -3 1 3; -3 2 3]
					[0 -1 0; 0 -2 0; 0 0 0; -1 0 0; -2 0 0; -2 0 1; -2 0 2; -2 0 3; -2 1 3; -2 2 3]
				};
	
	xCube	=	[
					0 1 1 0 0 0
					1 1 0 0 1 1
					1 1 0 0 1 1
					0 1 1 0 0 0
				] - 0.5;
	yCube	=	[
					0 0 1 1 0 0
					0 1 1 0 0 0
					0 1 1 0 1 1
					0 0 1 1 1 1
				] - 0.5;
	zCube	=	[
					0 0 0 0 0 1
					0 0 0 0 0 1
					1 1 1 1 0 1
					1 1 1 1 0 1
				] - 0.5;
	
	szCube	= size(xCube);
	pCube	= [reshape(xCube,[],1) reshape(yCube,[],1) reshape(zCube,[],1)];
end

%parse the input
	opt	= ParseArgs(varargin,...
			'tx'			, ''			, ...
			'figure_size'	, 500			, ...
			'view'			, [30 15 0]		, ...
			'background'	, [0.5 0.5 0.5]	, ...
			'axis_radius'	, 3.5			, ...
			'thickness'		, 0.5			  ...
			);
	
	fig	= figs{k};
	
	cTX	= split(opt.tx,' ');
	cTX	= cellfun(@(tx) regexp(tx,'(?<op>(R[XYZBFLR]|F[XYZ]))(?<param>[-]?\d*\.?\d*)','names'),cTX,'uni',false);
	nTX	= numel(cTX);
	
	if any(cellfun(@isempty,cTX))
		error('Malformed transform string.');
	end
	
	rotView	= d2r(opt.view);

%prepare the figure
	hF	= figure;
	set(hF,...
		'color'				, [0.5 0 0]	, ...
		'PaperPosition'		, [0 0 1 1]	, ...
		'inverthardcopy'	, 'off'		, ...
		'visible'			, 'off'		  ...
		);
	
	hA	= axes;
	set(hA,...
		'position'	, [0 0 1 1]	  ...
		);

%draw each cube
	nCube	= size(fig,1);
	
	fig_shift		= repmat((max(fig) + min(fig))/2,[nCube 1]);
    fig_shifted		= fig - fig_shift;
    
	for kC=1:nCube
		%get the cube coordinates
			p		= pCube;
			for kXYZ=1:3
				p(:,kXYZ)	= p(:,kXYZ) + fig_shifted(kC,kXYZ);
			end
			
			%perform the operations
				for kTX=1:nTX
					op		= cTX{kTX}.op;
					param	= str2num(cTX{kTX}.param);
					
					switch op(1)
						case 'R' %rotate
							kRot	= switch2(op(2),'X',1,'Y',2,'Z',3,'R',1,'L',1,'B',2,'F',2);
							rotSign	= switch2(op(2),'L',-1,'F',-1,1);
							
							if isempty(kRot)
								error('Malformed transform string.');
							end
							
							rot			= repmat({0},[3 1]);
							rot{kRot}	= rotSign*d2r(param);
							
							p	= RotatePoints(p,rot{:});
						case 'F' %flip
							kFlip	= switch2(op(2),'X',1,'Y',2,'Z',3);
							
							if isempty(kFlip)
								error('Malformed transform string.');
							end
							
							p(:,kFlip)	= -p(:,kFlip);
						otherwise
							error('Malformed transform string.');
					end
				end
				
			%rotate for the viewpoint
				p	= RotatePoints(p,rotView(1),rotView(2),rotView(3));
			
			x	= reshape(p(:,1),szCube);
			y	= reshape(p(:,2),szCube);
			z	= reshape(p(:,3),szCube);
		
		%draw each cube face
		for kF=1:6
			hP	= patch(x(:,kF),y(:,kF),z(:,kF),[1 1 1]);
			set(hP,'LineWidth',opt.thickness);
		end
	end

%fix the view settings
	%axis vis3d;
	axis off;
	axis equal;
	view(0,0);
	set(hA,...
		'xlim'	, [-opt.axis_radius opt.axis_radius]	, ...
		'ylim'	, [-opt.axis_radius opt.axis_radius]	, ...
		'zlim'	, [-opt.axis_radius opt.axis_radius]	  ...
		);
	
	pos			= get(hF,'position');
	pos(3:4)	= opt.figure_size;
	set(gcf,'position',pos);

%extract the figure image
	im	= im2double(hardcopy(hF,'-Dopengl',sprintf('-r%d',opt.figure_size)));
	
	if nargout>2
		set(hF,'visible','on');
	else
		close(hF);
	end
	
	im	= uint8(2*im(:,:,1));

%calculate the figure mask
	msk	= im~=1;

%set the image colors
	nColBack			= numel(opt.background);
	colBack				= im2double(opt.background);
	
	colEdge	= zeros(1,nColBack);
	colFore	= ones(1,nColBack);
	
	im	= ind2im(im,[colEdge; colBack; colFore]);
