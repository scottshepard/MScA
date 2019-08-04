import random
import numpy as np

def rand_rot(img, msk):
    """
    Given an image and a mask, randomly augment the data by either
    0. Do nothing
    1. Transpose
    2. Flip about x-axis
    3. Flip about y-axis
    4. Transpose then flip about x
    5. Transpose then flip about y
    The mask and the image must be augmened in the same way
    """
    i = random.randint(0, 5)
    if i == 0:
        img_rot = img
        msk_rot = msk
    elif i == 1:
        img_rot = img.transpose(1,0,2)
        msk_rot = msk.transpose(1,0,2)
    elif i == 2:
        img_rot = img[:,::-1,:]
        msk_rot = msk[:,::-1,:]
    elif i == 3:
        img_rot = img[::-1,:,:]
        msk_rot = msk[::-1,:,:]
    elif i == 4:
        img_rot = img.transpose(1,0,2)[:,::-1,:]
        msk_rot = msk.transpose(1,0,2)[:,::-1,:]
    elif i == 5:
        img_rot = img.transpose(1,0,2)[::-1,:,:]
        msk_rot = msk.transpose(1,0,2)[::-1,:,:]
    return img_rot, msk_rot

def get_rand_patch(img, mask, sz=160):
    """
    :param img: ndarray with shape (x_sz, y_sz, num_channels)
    :param mask: binary ndarray with shape (x_sz, y_sz, num_classes)
    :param sz: size of random patch
    :return: patch with shape (sz, sz, num_channels)
    """
    assert len(img.shape) == 3 and img.shape[0] > sz and img.shape[1] > sz and img.shape[0:2] == mask.shape[0:2]
    xc = random.randint(0, img.shape[0] - sz)
    yc = random.randint(0, img.shape[1] - sz)
    patch_img = img[xc:(xc + sz), yc:(yc + sz)]
    patch_mask = mask[xc:(xc + sz), yc:(yc + sz)]
    return rand_rot(patch_img, patch_mask)


def get_patches(x_dict, y_dict, n_patches, sz=160):
    x = list()
    y = list()
    total_patches = 0
    while total_patches < n_patches:
        img_id = random.sample(x_dict.keys(), 1)[0]
        img = x_dict[img_id]
        mask = y_dict[img_id]
        img_patch, mask_patch = get_rand_patch(img, mask, sz)
        x.append(img_patch)
        y.append(mask_patch)
        total_patches += 1
    print('Generated {} patches'.format(total_patches))
    return np.array(x), np.array(y)


