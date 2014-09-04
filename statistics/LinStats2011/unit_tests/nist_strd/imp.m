function ds = imp(fn)

tbl = import_table( fn );
k = find( regexpfind(tbl, '^Data:'),1,'last');
S = regexptok( tbl(k+1:end,:), '(-*[\d\.]+)\s+(-*[\d\.]+)' );
x = str2double(S);

n = regexprep( tbl(k,:), 'Data:', '' );
n = regexptok( n, '\s+(\S+)\s+(\S+)');

x = num2cell(x,1);
ds = dataset( x{:}, 'varnames', n );
