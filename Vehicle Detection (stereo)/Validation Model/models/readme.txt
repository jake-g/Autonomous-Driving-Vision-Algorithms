###########################################################################
#            THE KITTI VISION BENCHMARK SUITE: OBJECT BENCHMARK           #
#              Andreas Geiger    Philip Lenz    Raquel Urtasun            #
#                    Karlsruhe Institute of Technology                    #
#                Toyota Technological Institute at Chicago                #
#                             www.cvlibs.net                              #
###########################################################################

This file describes how to use the pre-trained object detector models that
where used to generate the baseline approach for the KITTI object detection
benchmark and served as input in our joint object and scene layout estimation
paper (see below).

The baseline approach are the "Discriminatively Trained Deformable Part
Models", version 4. (Felzenszwalb et.al., Object Detection with
Discriminatively Trained Part Based Models, PAMI 2010). The source code is 
available for download at http://people.cs.uchicago.edu/~rbg/latent/.

The supervised detector (2) has been trained following the methodology
described in:

@INPROCEEDINGS{Geiger2011NIPS,
  author = {Andreas Geiger and Christian Wojek and Raquel Urtasun},
  title = {Joint 3D Estimation of Objects and Scene Layout},
  booktitle = {Advances in Neural Information Processing Systems (NIPS)},
  year = {2011}
}

Pre-trained model files have the following naming convention:
<object type>_<supervision>_<date trained on>_model.mat
where object type may be car, pedestrian or cyclist.
Supervision corresponds to one of the following numbers:
%   0: Unsupervised
%   2: Classes are provided and fixed during the whole training
where class describes the orientation for an object in the current 
image. The 3D world coordinate system that is used to describe the 
orientation of an object with respect to the current viewing angle is 
given by X pointing forward, Y to the left and Z upwards. For further 
reference, an example for 16 orientation classes is provided by 
orientation.pdf within is this zip file.
