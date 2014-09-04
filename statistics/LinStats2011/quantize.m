function q = quantize(x, s)
%QUANTIZE round a number to specified number of significant digits.
%
%Q = QUANTIZE(X) returns a m x n matrix, Q, equal in size to X with values
%of X rounded to 4 signficant digits.
%
%Q = QUANTIZE(X,S) returns Q with values in X rounded to S signficant
%digits. Values of S <= 0 return 0; 
%
%
%Example
%   format long g  % do this to prevent matlab from quantizing the display
%   quantize( 1234.56, 3) % = 1230
%   quantize( 1234.56, 5) % = 1234.6
%   quantize( 123456.789) % = 123500  ( default is four significant digits )
%   quantize( -.12345678 ) % = -.1235
%   quantize( .0012345 ) % = .0012         

% Copyright 2011 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%

% find zeros and replace with nan to avoid log(0) warnings
z = x == 0;
x(x==0) = nan;

if nargin < 2
    s = 4;
elseif ~isscalar(s) || s ~= floor(s);
    error('linstats:quantize:InvalidArgument', 'S, the number of signficant digits, must be an integer scalar' );
end


% get the "order" of x, with values < 1 = order 1
o = max(10.^(floor(log10(abs(x)))+1),1);

% divide x by the order to put first digit to the right of the decimal
x = x./o;

% calculate y so that x*y puts the signficant digits to the left
% of the decimal
y = 10.^s;

% round x, truncated the portion to the right of the decimal and 
% shift x back to the right of the decimal
q = round(x.*y)/y;

% shift x back to its original order
q = q.*o;

% change nan values that were orginally 0 back to 0.
q(z) = 0;


