% config
clc; clear;

deepLearnignNetworkName = "csp-darknet53-coco";
classes = ["kolo", "kwadrat", "trojkat"];
inputSize = [224 224 3];
modelToLoad = "";

% 
% imds = load("imageLabelingSession.mat");
% imds = imds.imageLabelingSession;
% % classes = imds.ROILabelSet.DefinitionStruct.Name(:);



% imds = load("data\noweDane_224_224.mat");
imds = load("ds.mat");
imds = imds.gTruth;
data = [];
% data(end) = imds.DataSource.Source;
% data(end) = cell2mat(imds.LabelData.kolo);
% imds = combine(imds.DataSource.Source, imds.LabelData(:, 1));

imds2 = imageDatastore(imds.DataSource.Source);
blds = boxLabelDatastore(imds.LabelData);
ds = combine(imds2,blds);


trainingDataForEstimation = transform(ds,@(data)preprocessData(data,inputSize));
numAnchors = 9;
[anchors, meanIoU] = estimateAnchorBoxes(trainingDataForEstimation,numAnchors);
area = anchors(:,1).*anchors(:,2);
[~,idx] = sort(area,"descend");
anchors = anchors(idx,:);
anchorBoxes = {anchors(1:3,:);anchors(4:6,:); anchors(7:9,:)};

disp("Wczytano dane...");

if modelToLoad == ""
    detector = yolov4ObjectDetector(deepLearnignNetworkName, classes,anchorBoxes ,InputSize=inputSize);
    analyzeNetwork(detector.Network) % analiza sieci, widok warstw
else
    m = load(fulfil("data", "models", modelToLoad));
    detector = m.detector;
end


disp("Wczytano sieć...");

options = trainingOptions("sgdm", ...
    InitialLearnRate=0.0002, ...
    MiniBatchSize=4,...
    MaxEpochs=40, ...
    BatchNormalizationStatistics="moving",...
    ResetInputNormalization=false,...
    VerboseFrequency=30, ...
    Plots="training-progress");

disp("Uczenie");
[detector,info] = trainYOLOv4ObjectDetector(ds,detector,options);
