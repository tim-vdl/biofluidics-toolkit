function [file_names,file_paths, number_of_files] = get_folder_file_names(input_path, file_extension)
files = dir(fullfile(input_path, file_extension));
file_names = {files(:).name};
file_paths = fullfile(input_path, file_names);
number_of_files = numel(file_names);
end

