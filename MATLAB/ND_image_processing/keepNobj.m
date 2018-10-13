function bin2 = keepNobj(bin,N)

props   = regionprops(logical(bin),'Area');
if numel(props)>1
    areas   = sort(cell2mat(struct2cell(props)),'descend');
    
    bin2    = bwareaopen(bin,areas(N));
else
    bin2 = bin;
end