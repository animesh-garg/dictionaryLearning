% Handles for various file operations.
function file_ops = file_utils()
file_ops.ensure_trailing_slash = @ensure_trailing_slash;
file_ops.filename_only = @filename_only;
file_ops.filename_no_dir = @filename_no_dir;
file_ops.filename_no_suffix = @filename_no_siffix;


function dir = ensure_trailing_slash(dir)
if dir(end) ~= '/'
    dir(end + 1) = '/';
end


function filename = filename_only(full_path)
filename = filename_no_suffix(filename_no_dir(full_path));


function filename = filename_no_dir(full_path)
dir_ind = strfind(full_path, '/');

if(~isempty(dir_ind))
    filename = full_path(max(dir_ind)+1:end);
else
    filename = full_path;
end


function filename = filename_no_suffix(full_name)
dot_ind = find(full_name == '.', 1, 'last'); 

if(~isempty(dot_ind))
    filename = full_name(1:dot_ind-1); 
else
    filename = full_name;
end