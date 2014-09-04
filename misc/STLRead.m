function [stl,strType] = STLRead(strPathSTL)
% STLRead
% 
% Description:	read the specified STL file into a struct
% 
% Syntax:	[stl,strType] = STLRead(strPathSTL)
% 
% In:
% 	strPathSTL	- path to the STL file
% 
% Out:
% 	stl		- a struct with the following elements:
%			Header:	the header as a string
%			Normal: an nFacet x 3 array of the normal vectors for each facet
%			Vertex: an nFacet x 3 x 3 array of the vertices of each facet.
%					.Vertex(k1,k2,:) is the k2th vertex of the k1th facet
%	strType	- the type of the STL file (either 'binary' or 'ascii')
% 
% Updated:	2009-06-13
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%determine the type of the file (binary or ascii)
	[strType,strSTL]	= STLGetType(strPathSTL);
	
if isequal(strType,'binary')
	%open the file
		fid	= fopen(strPathSTL,'r');
	
	%read the header
		stl.Header	= reshape(char(fread(fid,80,'uchar')),1,[]);
			
	%get the number of facets
		nFacet		= fread(fid,1,'uint32');
		stl.Normal	= zeros(nFacet,3);
		stl.Vertex	= zeros(nFacet,3,3);
		
	%read the rest of the file as 12 32-bit floats (3 for normal, 9 for vertices)
	%followed by two unnused bytes
		for kF=1:nFacet
			coord	= fread(fid,12,'float32');
			dummy	= fread(fid,1,'uint16');
			
			stl.Normal(kF,:)	= coord(1:3);
			stl.Vertex(kF,:,:)	= reshape(coord(4:12),1,3,3);
		end
		
	%i think i'm reading the file wrong
		stl.Vertex	= permute(stl.Vertex,[1 3 2]);
		
	%close the file
		fclose(fid);
else
	%break up the STL contents by line
		if strfind(strSTL,[13 10])
			cSTL	= split(strSTL,char([13 10]));
		elseif strfind(strSTL,10)
			cSTL	= split(strSTL,char(10));
		else
			error('No line breaks found in the STL file');
		end
		
	%get the header
		stl.Header	= StringFill(cSTL{1},80,' ','right');
		
	%get rid of the first and last lines
		cSTL([1 end])	= [];
		
	%process each facet
		nFacet	= numel(cSTL)/7;
		if nFacet~=floor(nFacet)
			error('Incorrect number of lines found in STL file');
		end
		
		stl.Normal	= zeros(nFacet,3);
		stl.Vertex	= zeros(nFacet,3,3);
		
		reNormal	= 'facet normal\s+(?<c1>[-.\de]+)\s+(?<c2>[-.\de]+)\s+(?<c3>[-.\de]+)';
		reVertex	= 'vertex\s+(?<c1>[-.\de]+)\s+(?<c2>[-.\de]+)\s+(?<c3>[-.\de]+)';
		for kF=1:nFacet
			nOffset	= 7*(kF-1);
			kNormal	= nOffset + 1;
			kVertex	= nOffset + (3:5);
			
			sNormal	= regexp(cSTL{kNormal},reNormal,'names');
			if isempty(sNormal) || isempty([sNormal.c1 sNormal.c2 sNormal.c3])
				cSTL{kNormal}
				error(['Error in STL file at line ' num2str(kNormal) '.  Expected "facet normal * * *".']);
			else
				c1	= str2num(sNormal.c1);
				c2	= str2num(sNormal.c2);
				c3	= str2num(sNormal.c3);
				
				stl.Normal(kF,:)	= [c1 c2 c3];
			end
			
			for kV=1:3
				sV	= regexp(cSTL{kVertex(kV)},reVertex,'names');
				if isempty(sV) || isempty([sV.c1 sV.c2 sV.c3])
					error(['Error in STL file at line ' num2str(kVertex(kV)) '.  Expected "vertex * * *".']);
				else
					c1	= str2num(sV.c1);
					c2	= str2num(sV.c2);
					c3	= str2num(sV.c3);
					
					stl.Vertex(kF,kV,:)	= reshape([c1 c2 c3],1,1,3);
				end	
			end
		end
end
	