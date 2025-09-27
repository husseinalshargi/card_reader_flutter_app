import cv2 as cv


class ImageReader:

    def read_image(path: str) -> cv.typing.MatLike:
        """Reads an image (currently using a path from the dir later i will use db storage)"""

        cv.imread()

        img = cv.imread(path)
        
        return img

