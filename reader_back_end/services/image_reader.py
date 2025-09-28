import cv2
import numpy as np


class ImageReader:

    def read_image(img_bytes: bytes) -> cv2.typing.MatLike:
        """Reads an image (it will read the image in bytes and convert it to an open cv img object)"""

        np_array = np.frombuffer(img_bytes, dtype= 'uint8')
        img_np = cv2.imdecode(np_array, cv2.IMREAD_COLOR_BGR)
        
        return img_np

