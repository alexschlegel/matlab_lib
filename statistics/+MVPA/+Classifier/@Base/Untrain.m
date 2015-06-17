function Untrain(cls)
% Untrain
% 
% Description:	untrain the classifier
% 
% Syntax:	cls.Untrain()
% 
% Updated: 2015-05-21
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
cls.model		= [];
cls.targets		= [];
cls.nFeature	= [];