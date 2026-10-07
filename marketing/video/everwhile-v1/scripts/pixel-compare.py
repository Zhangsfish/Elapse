from PIL import Image
import numpy as np
import sys
a=np.asarray(Image.open(sys.argv[1]).convert('RGB'),dtype=float)
b=np.asarray(Image.open(sys.argv[2]).convert('RGB'),dtype=float)
assert a.shape==b.shape
print(float(np.abs(a-b).mean()))
