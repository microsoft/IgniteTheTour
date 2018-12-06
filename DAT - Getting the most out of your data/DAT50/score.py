import os
import json
import time
import torch
import requests
import datetime
import numpy as np
from PIL import Image
from models import *
from io import BytesIO
from torch.autograd import Variable
from skimage.transform import resize
from utils.utils import load_classes, load_params, non_max_suppression

from azureml.core.model import Model

def init():
    global model, cuda, classes, img_size
    global use_cuda, conf_thres, nms_thres

    try:
        model_path = Model.get_model_path('YOLOv3')
    except:
        model_path = 'model'

    config_path = os.path.join(model_path, 'yolov3.cfg')
    class_path = os.path.join(model_path,'coco.names')
    weights_path = os.path.join(model_path,'yolov3.weights')
    params_path = os.path.join(model_path,'params.json')

    # get paramters and model
    params = load_params(params_path)
    img_size = params['ImageSize']
    conf_thres =params['Confidence']
    nms_thres = params['NonMaxSuppression']
    use_cuda = params['cuda']
    
    classes = load_classes(class_path)
    model = Darknet(config_path, img_size=img_size)
    model.load_weights(weights_path)

    cuda = torch.cuda.is_available() and use_cuda
    if cuda:
        model.cuda()

    # Set in evaluation mode
    model.eval() 
    

def run(raw_data):
    global model, cuda, classes, conf_thres

    # keep track of time
    prev_time = time.time()

    post = json.loads(raw_data)
    img_path = post['image']
    conf_thres = post['confidence'] if 'confidence' in post else conf_thres

    input_img, img_shape = convert(img_path, img_size)

    Tensor = torch.cuda.FloatTensor if cuda else torch.FloatTensor

    # Configure input
    input_imgs = Variable(torch.unsqueeze(input_img, 0).type(Tensor))

    # Get detections
    with torch.no_grad():
        detections = model(input_imgs)
        # only first (since single image inference)
        detections = non_max_suppression(detections, 80, conf_thres, nms_thres)[0]

    # The amount of padding that was added
    pad_x = max(img_shape[0] - img_shape[1], 0) * (img_size / max(img_shape))
    pad_y = max(img_shape[1] - img_shape[0], 0) * (img_size / max(img_shape))
    # Image height and width after padding is removed
    unpad_h = img_size - pad_y
    unpad_w = img_size - pad_x

    items = []
    if detections is not None:
        for x1, y1, x2, y2, conf, cls_conf, cls_pred in detections:
            prediction = {}
            # predictions
            label = classes[int(cls_pred)]
            confidence = cls_conf.item()

            # Rescale coordinates to original dimensions
            box_h = ((y2 - y1) / unpad_h) * img_shape[0]
            box_w = ((x2 - x1) / unpad_w) * img_shape[1]
            y1 = ((y1 - pad_y // 2) / unpad_h) * img_shape[0]
            x1 = ((x1 - pad_x // 2) / unpad_w) * img_shape[1]

            prediction['label'] = label
            prediction['confidence'] = confidence
            prediction['x'] = x1.item()
            prediction['y'] = y1.item()
            prediction['width'] = box_w.item()
            prediction['height'] = box_h.item()
            items.append(prediction)


    # Log progress
    current_time = time.time()
    inference_time = datetime.timedelta(seconds=current_time - prev_time)

    payload = {}
    payload['image'] = img_path
    payload['time'] = inference_time.total_seconds()
    payload['predictions'] = items

    return json.dumps(payload)


def convert(img_path, img_size):
    img = np.array([0])

    # Extract image (from web or path)
    if(img_path.startswith('http')):
        response = requests.get(img_path)
        img = np.array(Image.open(BytesIO(response.content)))
    else:
        img = np.array(Image.open(img_path))

    h, w, _ = img.shape
    dim_diff = np.abs(h - w)
    # Upper (left) and lower (right) padding
    pad1, pad2 = dim_diff // 2, dim_diff - dim_diff // 2
    # Determine padding
    pad = ((pad1, pad2), (0, 0), (0, 0)) if h <= w else ((0, 0), (pad1, pad2), (0, 0))
    # Add padding
    input_img = np.pad(img, pad, 'constant', constant_values=127.5) / 255.
    # Resize and normalize
    input_img = resize(input_img, (img_size, img_size, 3), mode='reflect')
    # Channels-first
    input_img = np.transpose(input_img, (2, 0, 1))
    # As pytorch tensor
    input_img = torch.from_numpy(input_img).float()

    return input_img, img.shape


if __name__ == '__main__':
    init()
    output = run(json.dumps({'image': 'https://media.bizarrepedia.com/images/timothy-treadwell.jpg', 'confidence': .8}))
    n = json.loads(output)
    print(json.dumps(n, indent=3))
