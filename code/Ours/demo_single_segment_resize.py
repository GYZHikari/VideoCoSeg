#!/usr/bin/python2.7
import numpy as np
import Image
import caffe
import os
import scipy
import sys
from scipy import io

def returnmax(L):
    """

    Returns
    -------
    object
    """
    return max(L)
caffe.set_mode_gpu();
caffe.set_device(0);

save_path = '/home/guangyuzhong/Coseg/Data/Youtube_Objects/fcn/'
# load net
net = caffe.Net('/home/guangyuzhong/caffe-future/python/fcn-8s-pascal-deploy.prototxt', '/home/guangyuzhong/caffe-future/python/fcn-8s-pascal.caffemodel', caffe.TEST)

if __name__ == '__main__':
    img_path = sys.argv[1]
    img_name = sys.argv[2]
    save_img_name = sys.argv[3]
    save_mat_name = sys.argv[4]
        #if im.size[0] > 640 or im.size[1] > 800:
    #    scale = float(800)/float(max(im.size))
    #    im = scipy.misc.imresize(im, scale)
    gt1 = sys.argv[5]
    gt2 = sys.argv[6]
    gt1 = int(float(gt1))
    gt2 = int(float(gt2))
    im = Image.open(img_path + img_name)
    #if im.size[0] > 640 or im.size[1] > 800:
        #scale = float(800)/float(max(im.size))
    #    im = scipy.misc.imresize(im, scale)
    gt = [0, 0]
    gt[0] = gt1
    gt[1] = gt2
    im = scipy.misc.imresize(im, gt)
    in_ = np.array(im, dtype=np.float32)
    in_ = in_[:, :, ::-1]
    in_ -= np.array((104.00698793, 116.66876762, 122.67891434))
    in_ = in_.transpose((2, 0, 1))
    
    # shape for input (data blob is N x C x H x W), set data
    net.blobs['data'].reshape(1, *in_.shape)
    net.blobs['data'].data[...] = in_
    # run net and take argmax for prediction
    net.forward()
    out = net.blobs['upscore'].data[0].argmax(axis=0)
    rescaled = out.astype(np.uint8)
    result = Image.fromarray(rescaled)
    #save_fcn_name = save_path + '0' + img_name[5:len(img_name) - 4] + '_fcn.png'
    #save_fcn_mat = save_path + '0' + img_name[5:len(img_name) - 4] + '_fcn.mat'
    result.save(save_img_name)
    out_sub_label = net.blobs['upscore'].data[0]
    scipy.io.savemat(save_mat_name, {"fcn": out_sub_label})
    # for h in range(0, out_sub_label.shape[0]):
    #     txt_name = save_path + '0' + img_name[5:len(img_name) - 4] + '_' + str(h) + '_fcn.txt'
    #     np.savetxt(txt_name, out_sub_label[h])





