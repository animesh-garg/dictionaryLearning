% Reads all the .txt files from the given directory and builds a struct
% array with fields orig_text and text (see polit_scripty.m for details on
% P).  Note: The txt files should be in the format output by
% get_debates.py.
function P = read_data(infolder)
file_ops = file_utils();
infolder = file_ops.ensure_trailing_slash(infolder);
files = dir([infolder '*.txt']);
num_files = numel(files);
P = repmat(struct('name', '', 'data', []), num_files, 1);

for i = 1:num_files
  fid = fopen([infolder files(i).name], 'r');
  disp([infolder files(i).name]);
  [~, P(i).name, ~] = fileparts(files(i).name);
  
  tline = fgetl(fid);
  idx = 0;
  while ischar(tline)
    idx = idx + 1;
    P(i).data(idx).orig_text = tline;
    fgetl(fid);
    tline = fgetl(fid);
    first_text = 1;
    while ischar(tline) && ~isempty(strtrim(tline))
      if first_text
        P(i).data(idx).text = tline;
        first_text = 0;
      else
        P(i).data(idx).text = [P(i).data(idx).text ' ' tline];
      end
      tline = fgetl(fid);
    end
    
    if ischar(tline)
      tline = fgetl(fid);
    end
  end
  
  fclose(fid);
end