%% reading the csv file
%clear all
%close all

folder = "C:\Users\smahmud\Desktop\MCS Dataset\images\Derecho_bounding_box_gan_data";
filepattern = fullfile(folder,'*.csv');
files= dir(filepattern);
filename_sorted = natsortfiles({files.name});
M=zeros(length(files),1);
xy = cell(length(files),1);
for k=1:length(files)
    %filename = filename_sorted;
    fullfilename = fullfile(files(k).folder,filename_sorted{k});
    M = readmatrix(fullfilename);
    xy{k} = M(:,2:3);
   
end



%% Converting the polygons shape into the rectangular

xlim = cell(length(files),1);
ylim = cell(length(files),1);
shape= cell(length(files),1);
for i=1:length(files)
    shape= xy{i,1};
    polyin(i) = polyshape({shape(:,1)},{shape(:,2)});
    polyin = polyin(:);
    [xlim{i},ylim{i}] = boundingbox(polyin(i));
    xmin{i} = xlim{i}(:,1);
    ymax{i} = ylim{i}(:,1); % Need to fixed that due to the bounding box issue
    width{i} = xlim{i}(:,2)-xlim{i}(:,1);
    height{i} = ylim{i}(:,2)-ylim{i}(:,1);
     bb{i} = [xmin{i} ymax{i} width{i} height{i}];
     bb = bb(:);
end

%% Converting them into bound box shapes

% %xlim_mat = cell2mat(xlim);
% xmin = xlim_mat(:,2);
% ylim_mat = cell2mat(ylim);
% ymax = ylim_mat();
% width = xlim(:,2) - xlim(:,1);
% height = ylim_mat(:,2) - ylim_mat(:,1);
% 
% for i =1:length(xmin)
%     bb{i} = [xmin(i) ymax(i) width(i) height(i)];
% end
% bb = bb(:);

for s = 1:i
annotedImage=insertShape(imread(derecho_dataset.imageFilename{s}),"rectangle",derecho_dataset.Derecho{s});
imshow(annotatedImage)
end