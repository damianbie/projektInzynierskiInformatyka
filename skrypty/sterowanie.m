

%pobranie kamery do sterowania 
webcamlist
% cam = webcam(1);
cam = ipcam("http://192.168.0.100:8080/video");
detector = 0;


imageSizeToReScale = detector.InputSize;

while true
    %pobranie zdjecia z kamery
%     imgFromCam = snapshot(cam) .* 2;
%     imshow(imgFromCam);
%     title("Zdjęcie z kamery");

    imSize = size(imgFromCam);
    imgFromCam = imresize(imgFromCam,[imageSizeToReScale(1)/imSize(1), imageSizeToReScale(2)/imSize(2)]);


    [bboxes, scores, labels] = detec(detector, imgFromCam);
    

end


clear cam;