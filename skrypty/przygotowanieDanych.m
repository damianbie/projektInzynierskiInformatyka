% automatyczne generowanie danych do uczenia sieci
clc; clear;  close all;

% i = insertImageInPos(i, x, alfa, 100, 150);
% i = imgaussfilt(i, 2);


videoFiles = ["data/vid/w1.3gp", "data/vid/w2.3gp"];
pathToSaveImages = "data/test2";
outputImageSize = [224, 224];
filterToOutputImage = fspecial("motion", 2, 2);

dataKolo = {};
dataKwadrat = {};
dataTrojkat = {};
dataFileNames = "";

for vidName = videoFiles
    vid = VideoReader(vidName);
    for fIndX = 1 : 2 : vid.NumFrames
        frame = read(vid, fIndX);

        % resize image to final training size
        frame = imresize(frame, outputImageSize);

        % add masks to image
        rr = randi([1, 1]);
        maskSize = [];
        if(rr == 1) % kwadrat
            [x, map, alpha] = imread("data\mask\kw_mask.png");   
            maskSize = size(x);
        elseif (rr == 2)
            [x, map, alpha] = imread("data\mask\kw_mask.png");
            maskSize = size(x);
        elseif (rr == 3)
            [x, map, alpha] = imread("data\mask\kw_mask.png");
            maskSize = size(x);
        end
        
        posX = randi([0, outputImageSize(1) - maskSize(1)]);
        posY = randi([0, outputImageSize(2) - maskSize(2)]);

        if(rr == 1)
            dataKolo(end + 1) = {[]};
            dataKwadrat(end + 1) = {[posX, posY, maskSize(1), maskSize(2)]};
            dataTrojkat(end + 1) = {[]};
        elseif (rr == 2)
            dataKolo(end + 1) = [posX, posY, maskSize(1), maskSize(2)];
            dataKwadrat(end + 1) = [];
            dataTrojkat(end + 1) = [];
        elseif (rr == 3)
            dataKolo(end + 1) = [];
            dataKwadrat(end + 1) = [];
            dataTrojkat(end + 1) = [posX, posY, maskSize(1), maskSize(2)];
        end

        frame = insertImageInPos(frame, x, alpha, posX, posY);      

        % add filter to image
        if exist("filterToOutputImage" ,"var") == true
            frame = imfilter(frame, filterToOutputImage);
        end

        path = sprintf("%s/%i-%i.jpg", pathToSaveImages,randi(300), fIndX);
        dataFileNames = dataFileNames + path + ";";

        imwrite(frame, path)
    end
end
labels = labelDefinitionCreator();
addLabel(labels, "kolo", "Rectangle");
addLabel(labels, "kwadrat", "Rectangle");
addLabel(labels, "trojkat", "Rectangle");
labelData = table(dataKolo', dataKwadrat', dataTrojkat', 'VariableNames',{'kolo', 'kwadrat', 'trojkat'});

t = split(dataFileNames, ";");
t(end) = [];
f =  matlab.io.datastore.FileSet(t);
imds = imageDatastore(f);
ds = groundTruthDataSource(t);

gTruth = groundTruth(ds, create(labels), labelData);
save("ds", "gTruth");

