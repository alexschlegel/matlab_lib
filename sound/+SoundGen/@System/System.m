classdef System < handle
% SoundGen.System
% 
% Description:	an object for generating sounds given a corpus.  works as
%				follows:
%				- a sound corpus is segmented
%				- segments are clustered into "characters" and thus the corpus
%				  is reduced to a "string"
%				- a new string is randomly generated using the frequencies of
%				  occurence of substrings in the corpus string
%				- characters are remapped to sound segments
%				- these segments are synthesized into a new sound
% 
% Syntax:	sys = SoundGen.System(src,[rate]=<auto>,<options>)
% 
% 			subfunctions:
%				Run			- run the sound generation process
% 				Segment		- segment the input sound
%				Cluster		- cluster the sound segments into
%				Generate	- generate a cluster string array
%				Exemplarize	- pick segment exemplars for a string of clusters
%				Concatenate	- concatenate a string of segment exemplars into a
%							  new audio signal
%				Debug		- return a struct of debug info about the soundgen
%							  process
% 			 
% 			properties:
%				src				- an Nx1 array of the source sound
%				rate			- the sampling rate, in Hz
%				type			- the data type for storing audio data
%				segmenter		- the SoundGen.Segment.* object or handle to the
%								  function that will perform the segmentation
%								  step
%				clusterer		- the SoundGen.Cluster.* object or handle to the
%								  function that will perform the clustering step
%				generator		- the SoundGen.Generate.* object or handle to
%								  the function that will perform the string
%								  generating step
%				exemplarizer	- the SoundGen.Exemplarize.* object or handle to
%								  the function that will perform the
%								  exemplarizing step
%				concatenater	- the SoundGen.Concatenate.* object or handle to
%								  the function that will perform the segment
%								  concatenation step
%				segmented		- true if the audio signal has already been
%								  segmented
%				clustered		- true if the segments have already been
%								  clustered
%				generated		- true if the output string has already been
%								  generated
%				exemplarized	- true if the generated string has already been
%								  exemplarized
%				concatenated	- true if the generated, exemplarized segments
%								  have already been concatenated to form the
%								  output audio signal
%				segment			- an Mx2 array of segments start and end indices
%								  resulting from the segmentation step
%				cluster			- an Mx1 array of the clusters to which each
%								  segment was assigned during the clustering
%								  step
%				gen				- an Sx1 cluster array resulting from the string
%								  generation step
%				exemplar		- an Sx1 segment index array resulting from the
%								  exemplarizing step
%				result			- a Px1 audio signal resulting from the
%								  concatenation step
%				silent			- true if processes should be silent
% 
% In:
%	src		- the input corpus of sounds.  can be an Nx1 signal, an audio file
%			  path, the path to a directory containing audio files (.wav or
%			  .mp3), or a cell of the above
%	[rate]	- the sampling rate, in Hz
%	<options>:
%		type:			('single') the data type for storing audio data
%		segmenter:		('mirsegment') a segmenter preset, a SoundGen.Segment.*
%						object or the handle to a function that will perform the
%						segmentation step. functions should take an Nx1 audio
%						signal, a sampling rate in Hz, and a sequence of
%						'key'/value option pairs and return an Mx2 array of
%						segment start and end indices, monotopically increasing
%						by start index.  presets:
%							'segmenter':	SoundGen.Segment.Segmenter, a simple
%											segmenter that creates one segment
%							'uniform':		SoundGen.Segment.Uniform, creates
%											segments of uniform duration
%							'changedetect':	SoundGen.Segment.ChangeDetect,
%											segments at points in time where the
%											rate of change of some measure
%											passes a threshold
%							'mirsegment':	SoundGen.Segment.MIRSegment,
%											segments using the MIRToolbox's
%											mirsegment function
%		clusterer:		('clusterdata') a clusterer preset, a SoundGen.Cluster.*
%						object or the handle to a function that will perform the
%						clustering step.  functions should take an Nx1 audio
%						signal, a sampling rate in Hz, an Mx2 array of segment
%						start and end indices, and a sequence of 'key'/value
%						option pairs and return an Mx1 cluster string array of
%						the clusters to which each segment was assigned.
%						presets:
%							'clusterer':	SoundGen.Cluster.Clusterer, a simple
%											clusterer that assigns each segment
%											to its own cluster
%							'clusterdata':	SoundGen.Cluster.ClusterData,
%											clusters using MATLAB's clusterdata
%											function
%		generator:		('ngram') a generator preset, a SoundGen.Generate.*
%						object or the handle to a function that will perform the
%						string generation step.  functions should take an Mx1
%						cluster string array (the corpus string), a starting
%						cluster index, the output string duration in seconds),
%						and a sequence of 'key'/value option pairs and return an
%						Sx1 generated cluster string array.  presets:
%							'generator':	SoundGen.Generate.Generator, a
%											simple generator that randomly picks
%											clusters
%							'ngram':		SoundGen.Generate.NGram, generates
%											based on the frequency of occurence
%											of n-grams within the corpus cluster
%											string
%		exmplarizer:	('closest') an exemplarizer preset,
%						SoundGen.Exemplarize.* object or the handle to a
%						function that will perform the exemplarizing step.
%						functions should take an Nx1 audio signal, a sampling
%						rate in Hz, an Mx2 array of segment start and end
%						indices, an Mx1 cluster string array, an Sx1 generated
%						cluster string array, and a sequence of 'key'/value
%						option pairs and return an Sx1 array of exemplar segment
%						indices.  presets:
%							'exemplarizer':	SoundGen.Exemplarize.Exemplarizer,
%											a simple exemplarizer that chooses
%											the first instance of each cluster
%											in the corpus
%							'closest':		SoundGen.Exemplarize.Closest,
%											chooses a candidate exemplar whose
%											preceding segment most closely
%											resembles the current leading edge
%											exemplar
%		concatenater:	('overlapadd') a concatenater preset, a
%						SoundGen.Concatenate.* object or the handle to a
%						function that will perform the segment concatentation
%						step.  functions should take an Nx1 audio signal, a
%						sampling rate in Hz, an Mx2 array of segment start and
%						end indices, an Sx1 array of segment indices, and a
%						sequence of 'key'/value option pairs and return a Px1
%						audio signal.  presets:
%							'concatenater':	SoundGen.Concatenate.Concatenater,
%											a simple concatenater that appends
%											segment arrays
%							'overlapadd'	SoundGen.Concatenate.OverlapAdd,
%											concatenates by adding slighly
%											overlapped signals together
%		silent:			(false) true if processes should be silent
%		<other options>:	any other options to the SoundGen.* operation object
%							constructors
%
% Example:
%	f = '/home/alex/temp/dylancorrina_orig.wav';
%	sys = SoundGen.System(f,44100,'generate_n',4);
%	sys.Run(60*60/sys.segmenter.dur);
%	
%	f = '/home/alex/Music/Hip Hop/Shabazz Palaces';
%	sys = SoundGen.System(f,44100,'cluster_cutof',60,'generate_n',6);
%	sys.Run(60*60/sys.segmenter.dur);
% 
% Updated: 2012-11-19
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		src		= [];
		rate	= 0;
		type	= '';
		
		segmenter		= [];
		clusterer		= [];
		generator		= [];
		exemplarizer	= [];
		concatenater	= [];
		
		segmented		= false;
		clustered		= false;
		generated		= false;
		exemplarized	= false;
		concatenated	= false;
		
		segment		= [];
		cluster		= [];
		gen			= [];
		exemplar	= [];
		result		= [];
		
		silent	= false;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		vargin	= {};
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		function sys = set.src(sys,src)
			ns	= status('constructing audio corpus','silent',sys.silent);
			
			[sys.src,rate]	= p_GetSound(sys,src);
			
			if isempty(sys.rate)
				sys.rate	= rate;
			end
			
			if ~isequal(class(sys.src),sys.type)
				sys.src	= cast(sys.src,sys.type);
			end
			
			sys.segmented	= false;
		end
		function sys = set.rate(sys,rate)
			sys.rate	= rate;
			
			sys.segmented	= false;
		end
		function sys = set.type(sys,type)
			%make sure it's a valid type
				try
					x	= cast(1,type);
				catch me
					error('Invalid data type.');
				end
			
			sys.type	= type;
			
			sys.Recast();
		end
		
		function sys = set.segmenter(sys,segmenter)
			if isa(segmenter,'SoundGen.Segment.Segmenter') || isa(segmenter,'function_handle')
				sys.segmenter	= segmenter;
			elseif ischar(segmenter) && ismember(lower(segmenter),{'segmenter','uniform','changedetect','mirsegment'})
				switch lower(segmenter)
					case 'segmenter'
						sys.segmenter	= SoundGen.Segment.Segmenter(sys,sys.vargin{:});
					case 'uniform'
						sys.segmenter	= SoundGen.Segment.Uniform(sys,sys.vargin{:});
					case 'changedetect'
						sys.segmenter	= SoundGen.Segment.ChangeDetect(sys,sys.vargin{:});
					case 'mirsegment'
						sys.segmenter	= SoundGen.Segment.MIRSegment(sys,sys.vargin{:});
				end
			else
				error('Invalid segmenter.');
			end
		end
		function sys = set.clusterer(sys,clusterer)
			if isa(clusterer,'SoundGen.Cluster.Clusterer') || isa(clusterer,'function_handle')
				sys.clusterer	= clusterer;
			elseif ischar(clusterer) && ismember(lower(clusterer),{'clusterer','clusterdata'})
				switch lower(clusterer)
					case 'clusterer'
						sys.clusterer	= SoundGen.Cluster.Clusterer(sys,sys.vargin{:});
					case 'clusterdata'
						sys.clusterer	= SoundGen.Cluster.ClusterData(sys,sys.vargin{:});
				end
			else
				error('Invalid clusterer.');
			end
		end
		function sys = set.generator(sys,generator)
			if isa(generator,'SoundGen.Generate.Generator') || isa(generator,'function_handle')
				sys.generator	= generator;
			elseif ischar(generator) && ismember(lower(generator),{'generator','ngram'})
				switch lower(generator)
					case 'generator'
						sys.generator	= SoundGen.Generate.Generator(sys,sys.vargin{:});
					case 'ngram'
						sys.generator	= SoundGen.Generate.NGram(sys,sys.vargin{:});
				end
			else
				error('Invalid generator.');
			end
		end
		function sys = set.exemplarizer(sys,exemplarizer)
			if isa(exemplarizer,'SoundGen.Exemplarize.Exemplarizer') || isa(exemplarizer,'function_handle')
				sys.exemplarizer	= exemplarizer;
			elseif ischar(exemplarizer) && ismember(lower(exemplarizer),{'exemplarizer','closest'})
				switch lower(exemplarizer)
					case 'exemplarizer'
						sys.exemplarizer	= SoundGen.Exemplarize.Exemplarizer(sys,sys.vargin{:});
					case 'closest'
						sys.exemplarizer	= SoundGen.Exemplarize.Closest(sys,sys.vargin{:});
				end
			else
				error('Invalid exemplarizer.');
			end
		end
		function sys = set.concatenater(sys,concatenater)
			if isa(concatenater,'SoundGen.Concatenate.Concatenater') || isa(concatenater,'function_handle')
				sys.concatenater	= concatenater;
			elseif ischar(concatenater) && ismember(lower(concatenater),{'concatenater','overlapadd'})
				switch lower(concatenater)
					case 'concatenater'
						sys.concatenater	= SoundGen.Concatenate.Concatenater(sys,sys.vargin{:});
					case 'overlapadd'
						sys.concatenater	= SoundGen.Concatenate.OverlapAdd(sys,sys.vargin{:});
				end
			else
				error('Invalid concatenater.');
			end
		end
		
		function sys = set.segmented(sys,bSegmented)
			if ~bSegmented && sys.segmented
				sys.segment		= [];
				sys.clustered	= false;
				
				if isa(sys.segmenter,'SoundGen.Segment.Segmenter')
					sys.segmenter.ran	= false;
				end
			elseif bSegmented && ~sys.segmented
				error('Set segment to make this property ''true''.');
			end
		end
		function sys = set.clustered(sys,bClustered)
			if ~bClustered && sys.clustered
				sys.cluster		= [];
				sys.generated	= false;
				
				if isa(sys.clusterer,'SoundGen.Cluster.Clusterer')
					sys.clusterer.ran	= false;
				end
			elseif bClustered && ~sys.clustered
				error('Set cluster to make this property ''true''.');
			end
		end
		function sys = set.generated(sys,bGenerated)
			if ~bGenerated && sys.generated
				sys.gen				= [];
				sys.exemplarized	= false;
				
				if isa(sys.generator,'SoundGen.Generate.Generator')
					sys.generator.ran	= false;
				end
			elseif bGenerated && ~sys.generated
				error('Set gen to make this property ''true''.');
			end
		end
		function sys = set.exemplarized(sys,bExemplarized)
			if ~bExemplarized && sys.exemplarized
				sys.exemplar		= [];
				sys.concatenated	= false;
				
				if isa(sys.exemplarizer,'SoundGen.Exemplarize.Exemplarizer')
					sys.exemplarizer.ran	= false;
				end
			elseif bExemplarized && ~sys.exemplarized
				error('Set exemplar to make this property ''true''.');
			end
		end
		function sys = set.concatenated(sys,bConcatenated)
			if ~bConcatenated && sys.concatenated
				sys.result		= [];
				
				if isa(sys.concatenater,'SoundGen.Concatenate.Concatenater')
					sys.concatenater.ran	= false;
				end
			elseif bConcatenated && ~sys.concatenated
				error('Set result to make this property ''true''.');
			end
		end
		function b = get.segmented(sys)
			b	= ~isempty(sys.segment);
		end
		function b = get.clustered(sys)
			b	= ~isempty(sys.cluster);
		end
		function b = get.generated(sys)
			b	= ~isempty(sys.gen);
		end
		function b = get.exemplarized(sys)
			b	= ~isempty(sys.exemplar);
		end
		function b = get.concatenated(sys)
			b	= ~isempty(sys.result);
		end
		
		function sys = set.segment(sys,k)
			if isempty(k)
				sys.segment	= [];
			else
				%make sure we have valid indices
					k	= double(k);
					
					if size(k,2)~=2
						error('segment must be an Mx2 array of start and end indices.')
					elseif any(~isint(k(:)) | k(:)<1 | k(:)>numel(sys.src))
						error('Some segment indices are out of bounds of the audio signal.');
					elseif any(diff(k(:,1))<=0)
						error('segment starting indices must be monotopically increasing.');
					elseif any(diff(k,[],2)<0)
						error('segment end indices must be >= segment start indices.');
					end
					
				sys.segment	= k;
			end
			
			%reset the rest of the process
				sys.clustered	= false;
		end
		function sys = set.cluster(sys,c)
			if isempty(c)
				sys.cluster	= [];
			elseif sys.segmented
			%have we reached this stage?
				%make Mx1
					c	= reshape(c,size(sys.segment,1),1);
				%make sure we have valid cluster numbers
					c	= double(c);
					
					if any(~isnat(c))
						error('Some clusters are not positive integers.');
					end
				
				sys.cluster	= c;
			else
				error('Segmentation must be performed before clustering.');
			end
			
			%reset the rest of the process
				sys.generated	= false;
		end
		function sys = set.gen(sys,str)
			if isempty(str)
				sys.gen	= [];
			elseif sys.clustered
			%have we reached this stage?
				%make Sx1
					str	= reshape(str,[],1);
				%make sure we have a valid string
					str	= double(str);
					
					if any(~ismember(str,unique(sys.cluster)))
						error('Some characters are not valid clusters.');
					end
				
				sys.gen	= str;
			else
				error('Clustering must be performed before generation.');
			end
			
			%reset the rest of the process
				sys.exemplarized	= false;
		end
		function sys = set.exemplar(sys,str)
			if isempty(str)
				sys.exemplar	= [];
			elseif sys.generated
			%have we reached this stage?
				%make Sx1
					str	= reshape(str,numel(sys.gen),1);
				%make sure we have a valid string
					str	= double(str);
					
					if any(~isnat(str) | str>size(sys.segment,1))
						error('Some exemplars are not valid segment indices.');
					end
				
				sys.exemplar	= str;
			else
				error('Generation must be performed before exemplarizing.');
			end
			
			%reset the rest of the process
				sys.concatenated	= false;
		end
		function sys = set.result(sys,res)
			if isempty(res)
				sys.result	= [];
			elseif sys.exemplarized
				%make Px1
					res	= reshape(res,[],1);
				%make sure we have a valid audio signal
					res	= cast(res,sys.type);
				
				sys.result	= res;
			else
				error('Exemplarizing must be performed before concatenation.');
			end
		end
		
		function sys = set.silent(sys,silent)
			sys.silent	= silent;
			
			if isa(sys.segmenter,'SoundGen.Segment.Segmenter')
				sys.segmenter.silent	= silent;
			end
			if isa(sys.clusterer,'SoundGen.Cluster.Clusterer')
				sys.clusterer.silent	= silent;
			end
			if isa(sys.generator,'SoundGen.Generate.Generator')
				sys.generator.silent	= silent;
			end
			if isa(sys.exemplarizer,'SoundGen.Exemplarize.Exemplarizer')
				sys.exemplarizer.silent	= silent;
			end
			if isa(sys.concatenater,'SoundGen.Concatenate.Concatenater')
				sys.concatenater.silent	= silent;
			end
		end
		
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function sys = System(src,varargin)
			[rate,opt]	= ParseArgs(varargin,[],...
							'type'			, 'single'			, ...
							'segmenter'		, 'mirsegment'		, ...
							'clusterer'		, 'clusterdata'		, ...
							'generator'		, 'ngram'			, ...
							'exemplarizer'	, 'closest'			, ...
							'concatenater'	, 'overlapadd'		, ...
							'silent'		, false				  ...
							);
			
			sys.vargin	= varargin;
			
			sys.type	= opt.type;
			
			sys.segmenter		= opt.segmenter;
			sys.clusterer		= opt.clusterer;
			sys.generator		= opt.generator;
			sys.exemplarizer	= opt.exemplarizer;
			sys.concatenater	= opt.concatenater;
			
			sys.silent	= opt.silent;
			
			sys.rate	= rate;
			sys.src		= src;
		end
	end
	methods (Static)
		
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	methods
		
	end
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	
	
	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Access=private)
		function Recast(sys)
			if ~isempty(sys.src)
				sys.src	= cast(sys.src,type);
			end
			if ~isempty(sys.result)
				sys.result	= cast(sys.result,type);
			end
		end
	end
	%PRIVATE METHODS-----------------------------------------------------------%
	
end
