## Semantic Co-segmentation in Videos
* This repository includes the codes for our weakly-supervised video co-segmention. Please cite our paper if you use our code and model for your research.

* This code has been tested on Ubuntu 14.04 and MATLAB 2015a.

* Contact: Guangyu Zhong (guangyuzhonghikari at gmail dot com)

## Paper
Semantic Co-segmentation in Videos.
Yi-Hsuan Tsai*, Guangyu Zhong* and Ming-Hsuan Yang.
European Conference on Computer Vision (ECCV), 2016. (* indicates equal contribution)


## Installation
* Download and unzip the code.

* Install the attached caffe branch, as instructed at http://caffe.berkeleyvision.org/installation.html.

* Download the CNN model for feature extraction at http://vllab1.ucmerced.edu/~ytsai/CVPR16/pascal_segmentation.zip, then unzip the model folder under the **caffe-cedn-dev/examples** folder.

## Usage
* Put your own videos in "Youtube_input" or another folder (you may need to change the corresponding paths).

* run demo_semantic_cosegment.m to generate tracklets.

* run demo_tracklets_feature.m to extract features for each tracklet.

* run demo_tracklets_submodular.m to select and merge tracklets.

## Note
* Currently this package only contains the implementation of our weakly-supervised video co-segmentation part.

## Citation
* Please cite our paper if you find this work is useful.
```
@inproceedings{tsai2016semantic,
  title={Semantic Co-segmentation in Videos},
  author={Tsai, Yi-Hsuan and Zhong, Guangyu and Yang, Ming-Hsuan},
  booktitle={European Conference on Computer Vision},
  year={2016},
}
```
## Pipeline
* Step 0: generate tracklets.
![Pipeline](https://cloud.githubusercontent.com/assets/4355920/19338138/4be0c182-911b-11e6-96b5-d61ec2a6c1cb.png)
* Step 1 & 2: feature extraction and co-selection
![Co-selection](https://cloud.githubusercontent.com/assets/4355920/19338139/4be17794-911b-11e6-94f6-a87e49900b4f.png)

## Results
* Check more results in our [supplementary video](https://youtu.be/yLGsTz6fvWM).
![Results](https://cloud.githubusercontent.com/assets/4355920/19338134/3bf55f12-911b-11e6-8f18-09fe77772404.png)







