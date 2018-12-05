from __future__ import division

from models import *
from utils.utils import *
from utils.datasets import *
from utils.parse_config import *
from utils.logs import *

import os
import sys
import time
import datetime
import argparse
from pathlib import Path

import torch
from torch.utils.data import DataLoader
from torchvision import datasets
from torchvision import transforms
from torch.autograd import Variable
import torch.optim as optim

from azureml.core.run import Run


def main(opt, run=None):

    # Get data configuration
    base_path = Path(opt.base_path).resolve()
    assert base_path.exists() and base_path.is_dir(), 'invalid data directory ({})'.format(opt.base_path)

    use_cuda = opt.use_cuda.strip().lower() in ['true', 'yes', 'ok']
    classes_file = Path(opt.classes_file).resolve()
    model_file = Path(opt.model_config_path).resolve()
    data_file = base_path.joinpath('trainvalno5k.txt').resolve()
    weight_file = base_path.joinpath('yolov3.weights').resolve()

    batch_size = opt.batch_size
    n_cpu = opt.n_cpu
    epochs = opt.epochs
    checkpoint_interval = opt.checkpoint_interval
    checkpoint_dir = check_dir(opt.checkpoint_dir)
    log_dir = check_dir(opt.log_dir)

    cuda = torch.cuda.is_available() and use_cuda
    classes = load_classes(classes_file)

    # Get hyper parameters
    hyperparams = parse_model_config(model_file)[0]
    learning_rate = float(hyperparams["learning_rate"])
    momentum = float(hyperparams["momentum"])
    decay = float(hyperparams["decay"])
    burn_in = int(hyperparams["burn_in"])

    session = { 'base_path': base_path, 'use_cuda': use_cuda, 'classes_file': classes_file,
                'model_file': model_file, 'data_file': data_file, 'weight_file': weight_file,
                'batch_size': batch_size, 'n_cpu': n_cpu, 'epochs': epochs,
                'checkpoint_interval': checkpoint_interval, 'checkpoint_dir': checkpoint_dir,
                'log_dir': log_dir, 'learning_rate': learning_rate, 'momentum': momentum, 'decay': decay,
                'burn_in': burn_in }

    aml_log(run, **session)
    flog = log_dir.joinpath('training_params.txt').resolve()
    log(flog, 'Start: {}\n', datetime.datetime.now())
    log(flog, 'Session paramters\n{}', FormatDict(session))

    # Initiate model
    model = Darknet(model_file)
    # preload transfer learned weights
    #model.load_weights(weight_file)
    model.apply(weights_init_normal)

    if cuda:
        model = model.cuda()

    model.train()

    # log format
    fmt = '[Epoch {epoch:d}/{epochs:d}, Batch {batch:d}/{batches:d}] [Losses: x {x:f}, y {y:f}, w {w:f}, h {h:f}, conf {conf:f}, cls {cls:f}, total {total:f}, recall: {recall:.5f}, precision: {precision:.5f}]'

    # Get dataloader
    dataloader = torch.utils.data.DataLoader(
        ListDataset(base_path, data_file), batch_size=batch_size, shuffle=False, num_workers=n_cpu
    )

    Tensor = torch.cuda.FloatTensor if cuda else torch.FloatTensor
    optimizer = torch.optim.Adam(filter(lambda p: p.requires_grad, model.parameters()))

    for epoch in range(epochs):
        flog = log_dir.joinpath('epoch_{}_{}.txt'.format(epoch, epochs)).resolve()
        print('Epoch {}/{}'.format(epoch, epochs))
        for batch_i, (_, imgs, targets) in enumerate(dataloader):
            imgs = Variable(imgs.type(Tensor))
            targets = Variable(targets.type(Tensor), requires_grad=False)

            # optimization steps
            optimizer.zero_grad()
            loss = model(imgs, targets)
            loss.backward()
            optimizer.step()
            
            # loss
            losses = { 'x': model.losses["x"], 'y': model.losses["y"], 'w': model.losses["w"], 'h': model.losses["h"],
                        'conf': model.losses["conf"], 'cls': model.losses["cls"], 'total': loss.item(), 
                        'recall': model.losses["recall"], 'precision': model.losses["precision"] }

            # output logging
            log(flog, fmt, epoch=epoch, epochs=epochs, batch=batch_i, batches=len(dataloader), **losses)
            aml_log(run, **losses)
            if batch_i % 100 == 0:
                print(fmt.format(epoch=epoch, epochs=epochs, batch=batch_i, batches=len(dataloader), **losses))

            model.seen += imgs.size(0)

        if epoch % checkpoint_interval == 0:
            chk = checkpoint_dir.joinpath('epoch_{}_{}.weights'.format(epoch, epochs)).resolve()
            model.save_weights(chk)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--epochs", type=int, default=30, help="number of epochs")
    parser.add_argument("--base_path", type=str, default="data/coco", help="path to dataset")
    parser.add_argument("--batch_size", type=int, default=16, help="size of each image batch")
    parser.add_argument("--model_config_path", type=str, default="model/yolov3.cfg", help="path to model config file")
    parser.add_argument("--weights_path", type=str, default="model/yolov3.weights", help="path to weights file")
    parser.add_argument("--classes_file", type=str, default="model/coco.names", help="path to class label file")
    parser.add_argument("--n_cpu", type=int, default=0, help="number of cpu threads to use during batch generation")
    parser.add_argument("--checkpoint_interval", type=int, default=1, help="interval between saving model weights")
    parser.add_argument(
        "--checkpoint_dir", type=str, default="outputs", help="directory where model checkpoints are saved"
    )
    parser.add_argument("--log_dir", type=str, default="logs", help="directory where logs are saved")
    parser.add_argument("--use_cuda", type=str, default='false', help="whether to use cuda if available")
    opt = parser.parse_args()
    #print(opt)
    try:
        run = Run.get_context()
    except:
        run = None

    main(opt, run)