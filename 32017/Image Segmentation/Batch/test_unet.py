import tifffile as tiff
from sys import argv
from sklearn.metrics import log_loss
import pdb

CLASS_WEIGHTS = [0.2, 0.3, 0.1, 0.1, 0.3]

def weighted_log_loss(y_true, y_pred, n_classes=5):
    hw = y_true.shape[0] * y_true.shape[1]
    assert y_pred.shape == y_true.shape
    wll = 0
    for c in range(n_classes):
        wll += CLASS_WEIGHTS[c] * log_loss(y_true[:,:,c], y_pred[:,:,c]) / hw
    return -wll

if __name__ == '__main__':
    mask = tiff.imread(argv[1]).transpose([1, 2, 0])
    pred = tiff.imread(argv[2]).transpose([1, 2, 0])

    print(weighted_log_loss(mask, pred))
    


