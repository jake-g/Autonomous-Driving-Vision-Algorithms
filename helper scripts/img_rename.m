function img_rename(img_dir, ext)

    % Renames file to frame name
    files = dir([img_dir '/*' ext]);
    disp('Renaming Images based off frame...')
    for i=1:length(files)
      orig_name = files(i).name;
      new_name = [sprintf('%010d', i-1), ext]
      movefile([img_dir, '/', orig_name], [img_dir, '/', new_name]);
    end
    
end