clc; clear; 
close all;

modelAutoLoad = true;
modelSelected = 'detectorDzialajacy.mat';

camAutoConnect = true;
camSelected = 'e2eSoft iVCam';

robotAutoConnect = true;
robotBaudRate = "9600";
robotPort = "COM4";

robotManualModePixToImg1 = [-0.85];
robotManualModePixToImg2 = [.85];

save("settings.mat");