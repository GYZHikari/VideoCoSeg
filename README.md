## Semantic Co-segmentation in Videos
* This repository includes the codes for our weakly-supervised video co-segmention. Please cite our paper if you use our code and model for your research.

* This code has been tested on Ubuntu 14.04 and MATLAB 2015a.

* Contact: Guangyu Zhong (guangyuzhonghikari at gmail dot com)

## Paper
Semantic Co-segmentation in Videos <br />
Yi-Hsuan Tsai*, Guangyu Zhong* and Ming-Hsuan Yang <br /> 
European Conference on Computer Vision (ECCV), 2016. (* indicates equal contribution)


## Installation
* Download and unzip the code.

* Install the attached caffe branch, as instructed at http://caffe.berkeleyvision.org/installation.html.

* Download the CNN model for feature extraction at https://dl.dropboxusercontent.com/u/73240677/CVPR16/pascal_segmentation.zip, then unzip the model folder under the **caffe-cedn-dev/examples** folder.

## Usage
* Put your own videos in "Youtube_input" or another folder (you may need to change the corresponding paths).

* run demo_semantic_cosegment.m to generate tracklets.

* run demo_tracklets_feature.m to extract features for each tracklet.

* run demo_tracklets_submodular.m to select and merge tracklets.

## Note
* Currently this package only contains the implementation of our weakly-supervised video co-segmentation part and the performacne is a bit worse than the one reported in the paper.

## Citation
* Please cite our paper if you find this work is useful.
```
]@inproceedings{tsai2016semantic,
  title={Semantic Co-segmentation in Videos},
  author={Tsai, Yi-Hsuan and Zhong, Guangyu and Yang, Ming-Hsuan},
  booktitle={European Conference on Computer Vision},
  year={2016},
}
```







