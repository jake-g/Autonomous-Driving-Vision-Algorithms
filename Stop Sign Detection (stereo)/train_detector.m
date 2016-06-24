%****************************************************************************
% Train Detector
% University of Washington
% EcoCAR 3 ADAS Team
% Novin Changizi
%*****************************************************************************

clearvars;
load posStopsSave;
negativeFolder = '../datastore/StopSignDetect/stripped/nonStopSigns';

stages = 6;
FAR = 0.2;
detectorName = strcat('stopSignDetector_',num2str(stages),'_',num2str(FAR*100),'.xml');

trainCascadeObjectDetector(detectorName,posStops,negativeFolder,'FalseAlarmRate',FAR,'NumCascadeStages',stages);
