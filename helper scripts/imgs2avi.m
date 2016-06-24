path = '../datastore/CarDetectStereo/';
imageNames = dir(fullfile(path,'mono_results/','*.jpg'));
imageNames = {imageNames.name}';
outputVideo = VideoWriter(fullfile(path,'out.avi'));
open(outputVideo)
for i = 1:length(imageNames)
   img = imread(fullfile(path,'mono_results/',imageNames{i}));
   writeVideo(outputVideo,img)
end

close(outputVideo)
