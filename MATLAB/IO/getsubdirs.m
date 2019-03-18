function [sub_dirs] = getsubdirs(input_path)
% GETSUBDIRS returns a cell containing the subdirectories located in the
% folder "input_path".
d = dir(input_path);
isub = [d(:).isdir]; % returns logical vector
sub_dirs = {d(isub).name}';
sub_dirs(ismember(sub_dirs,{'.','..'})) = [];

end
