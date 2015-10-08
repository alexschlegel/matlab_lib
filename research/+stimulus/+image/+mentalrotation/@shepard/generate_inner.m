function [stim,ifo] = generate_inner(obj,ifo)
% stimulus.image.construct.generate_inner
% 
% Description:	generate the Shepard & Metzler stimulus
% 
% Syntax: [stim,ifo] = obj.generate_inner(ifo)
% 
% In:
%	ifo	- the info struct
% 
% Out:
%	stim	- the stimulus
%	ifo		- the updated info struct
% 
% Updated:	2015-10-06
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

fig		= obj.stim_param.fig{ifo.param.figure};
rotView	= d2r(ifo.param.view);

%prepare the figure
	hF	= figure('visible','off');
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
			p		= obj.stim_param.cube.p;
			for kXYZ=1:3
				p(:,kXYZ)	= p(:,kXYZ) + fig_shifted(kC,kXYZ);
			end
			
			%perform the operations
				nTX	= numel(ifo.param.txParsed);
				
				for kTX=1:nTX
					op	= ifo.param.txParsed{kTX}.op;
					prm	= str2num(ifo.param.txParsed{kTX}.param);
					
					switch op(1)
						case 'R' %rotate
							kRot	= switch2(op(2),'X',2,'Y',3,'Z',1,'R',1,'L',1,'B',3,'F',3);
							rotSign	= switch2(op(2),'L',-1,'B',-1,1);
							
							assert(~isempty(kRot),'malformed transform string');
							
							rot			= repmat({0},[3 1]);
							rot{kRot}	= rotSign*d2r(prm);
							
							p	= RotatePoints(p,rot{:});
						case 'F' %flip
							kFlip	= switch2(op(2),'X',1,'Y',2,'Z',3);
							
							assert(~isempty(kFlip),'malformed transform string');
							
							p(:,kFlip)	= -p(:,kFlip);
						otherwise
							error('malformed transform string');
					end
				end
				
			%rotate for the viewpoint
				p	= RotatePoints(p,rotView(1),rotView(2),rotView(3));
			
			x	= reshape(p(:,1),obj.stim_param.cube.size);
			y	= reshape(p(:,2),obj.stim_param.cube.size);
			z	= reshape(p(:,3),obj.stim_param.cube.size);
		
		%draw each cube face
			for kF=1:6
				hP	= patch(x(:,kF),y(:,kF),z(:,kF),[1 1 1]);
				set(hP,'LineWidth',ifo.param.thickness);
			end
	end

%fix the view settings
	%axis vis3d;
	axis off;
	axis equal;
	view(0,0);
	set(hA,...
		'xlim'	, [-ifo.param.axis_radius ifo.param.axis_radius]	, ...
		'ylim'	, [-ifo.param.axis_radius ifo.param.axis_radius]	, ...
		'zlim'	, [-ifo.param.axis_radius ifo.param.axis_radius]	  ...
		);
	
	pos			= get(hF,'position');
	pos(3:4)	= ifo.param.size;
	set(gcf,'position',pos);

%extract the figure image
	stim	= im2double(hardcopy(hF,'-Dopengl',sprintf('-r%d',ifo.param.size)));
	
	close(hF);
	
	stim	= uint8(2*stim(:,:,1));

%calculate the figure mask
	ifo.mask	= stim~=1;

%set the image colors
	stim	= ind2im(stim,[ifo.param.edge; ifo.param.background; ifo.param.foreground]);
