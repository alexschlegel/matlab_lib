function struct_compare(a,b)
% compare a to the gold standard b. b must have all the fields of a, but
% can be in a different order. Each field must be convertable to double
fn = fieldnames(a);
for i = 1:length(fn)
    x = double(a.(fn{i}));
    [u v w] = size(x);
    if w > 1
        x = reshape( x,[u*w v]);
    end
    y  =  double(b.(fn{i}));
    [u v w] = size(y);
    if w > 1
        y = reshape( y,[u*w v]);
    end
    if any(lre(x,y) < 10 )
        error('%s matrices unequal to 10 digits', fn{i});
    end
end
