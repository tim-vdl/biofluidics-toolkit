function [file_names_with_extension, file_names, file_paths, number_of_files] = get_folder_file_names(input_path, file_extension)
files = dir(fullfile(input_path, file_extension));
file_names_with_extension = {files.name};
extenstion = file_extension(2:end);
file_names = erase(file_names_with_extension, extenstion);
file_paths = fullfile(input_path, file_names_with_extension);
number_of_files = numel(file_names_with_extension);
end

