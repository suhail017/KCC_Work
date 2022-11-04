% for i=1:height(derecho_dataset)
%     I = derecho_dataset.imageFilename{i};
% bbox = derecho_dataset.Derecho{i};
% annotatedImage = insertShape(I,"Rectangle",bbox);
% annotatedImage = imresize(annotatedImage,2);
% figure
% imshow(annotatedImage) 
% end



x1 = [0 1 2];
y1 = [0 1 0];
x2 = [2 3 4];
y2 = [1 2 1];
polyin = polyshape({x1,x2},{y1,y2});
[xlim,ylim] = boundingbox(polyin);
plot(polyin)
hold on
plot(xlim{2},ylim{2},'r*',xlim{2},fliplr(ylim{2}),'r*')