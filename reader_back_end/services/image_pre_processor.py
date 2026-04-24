import cv2 as cv
import numpy as np
import imutils



class ImagePreProcessor:

    def adaptive_gausian(img: cv.typing.MatLike) -> cv.typing.MatLike:
        """binarization using adaptive gausian method"""
        adaptive_gausian_img = cv.adaptiveThreshold(img, 255, cv.ADAPTIVE_THRESH_GAUSSIAN_C, cv.THRESH_BINARY, 11, 9)
        return adaptive_gausian_img

    def scale_image(img: cv.typing.MatLike, c_height: int = 768 ,c_width: int = 1024, ) -> cv.typing.MatLike:
        """resize image to 1024 x 768 for better ocr results"""

        #(h, w, c)
        height, width, _ = img.shape 

        height_scale = c_height / height
        width_scale = c_width / width

        img_scaled = cv.resize(img, (int(width*width_scale), int(height*height_scale)), cv.INTER_LANCZOS4 )

        return img_scaled
    

    def sharppen_img(img: cv.typing.MatLike) -> cv.typing.MatLike:
        """returns image sharppend using unsharp mask matrix"""

        sharp = cv.filter2D(img, -1, -1/256 * np.array([[1, 4, 6, 4, 1], [4, 16, 24, 16, 4], [6, 24, -476, 24, 6], [4, 16, 24, 16, 4], [1, 4, 6, 4, 1]]))

        return sharp
    
    def gausian_threshold(img: cv.typing.MatLike) -> cv.typing.MatLike:
        """binarization using gausian method"""
        gausian_img = cv.adaptiveThreshold(img, 255, cv.ADAPTIVE_THRESH_MEAN_C, cv.THRESH_BINARY, 11, 9)
        return gausian_img
    
    def sort_points(points: cv.typing.MatLike):
        """sort the points in:  top left, top right, bottom right, bottom left order"""
        points = points.reshape((4,2))
        new_points = np.zeros((4, 1, 2), dtype= np.int32)
        
        add = points.sum(1)
        dif = np.diff(points, axis= 1)

        new_points[0] = points[np.argmin(add)]
        new_points[2] = points[np.argmax(add)]

        new_points[1] = points[np.argmin(dif)]
        new_points[3] = points[np.argmax(dif)]

        return new_points

    def larger_card(new_points: cv.typing.MatLike, original_image: cv.typing.MatLike) -> cv.typing.MatLike:
        """makes the whole picture the card itself"""
        img_shape = original_image.shape

        img_height = img_shape[0]
        img_width = img_shape[1]
        
        pts1 = np.float32(new_points)
        pts2 = np.float32(([[0,0], [img_width, 0], [img_width, img_height], [0, img_height]]))

        matrix = cv.getPerspectiveTransform(pts1, pts2)

        transform = cv.warpPerspective(original_image, matrix, (img_width, img_height))

        #just to make sure it is one channel 
        transform = transform.reshape(transform.shape[0], transform.shape[1], 1)

        return (transform)

    def extract_card( gray_image: cv.typing.MatLike) -> cv.typing.MatLike | None:
        """Extract the card it self for better results in the ocr"""

        #blur for better edges
        blur = cv.GaussianBlur(gray_image, (5,5), 0)

        #get edges for better ctor extraction
        edged = cv.Canny(blur, 30, 200)

        #find contours
        conts = cv.findContours(ImagePreProcessor.adaptive_gausian(edged), cv.RETR_LIST, cv.CHAIN_APPROX_SIMPLE)
        conts = imutils.grab_contours(conts)

        #sort it by size 
        conts = sorted(conts, key = cv.contourArea, reverse= True)[:6]

        larger = None

        #locate biggest contour
        for c in conts:
            perimeter = cv.arcLength(c, True) #true -> means only include the closed contours
            approximation = cv.approxPolyDP(c, 0.02 * perimeter, True)  #c, epsilon, true -> means only include the closed ctors
            #note: make a fall back if it didn't work
            if len(approximation) == 4: #means that we found 4 sided conturn,
                larger = approximation
                break
        
        if larger is None:
            print('no contr found')
            return None
        
        sorted_points = ImagePreProcessor.sort_points(larger)

        #top right - top left (take the x axis value)
        largest_contr_width = sorted_points[1] - sorted_points[0]
        largest_contr_width = largest_contr_width[0][0]

        #bottom left - bottom right (take the y axis value)
        largest_contr_height = sorted_points[3] - sorted_points[0]
        largest_contr_height = largest_contr_height[0][1]

        contr_area = largest_contr_width * largest_contr_width

        original_image_area = gray_image.shape[0] * gray_image.shape[1]

        if contr_area < int(original_image_area/2):
            print('contr area is less than 50% of the original image size')
            return None

        larger_extracted_image = ImagePreProcessor.larger_card(sorted_points, gray_image)

        return larger_extracted_image
    
    def set_up_results(results: list[str]) -> str:
        """setup card info for llm"""
        return '\n'.join(results)



    def process_image(img: cv.typing.MatLike, is_bi: bool = True, is_extracted: bool = True) -> cv.typing.MatLike:
        """
        pre-process an image before ocr

        Args:
            path (str): the image path
            is_bi (bool): flag for thresholding the image (1 - 0) useful in case of we have an image that contain multiple color scale
            is_extracted (bool): flag for extracting the card it self, could give better results but in case of the background not as the same color of the card background
            
        Output:
            MatLike object
        """

        #scale image to 1024 x 768
        scaled_img = ImagePreProcessor.scale_image(img)

        #convert to gray scale
        gray_image = cv.cvtColor(scaled_img, cv.COLOR_BGR2GRAY)
        
        #sharppen the image after scaling
        sharppen_image = ImagePreProcessor.sharppen_img(gray_image)
        
        #make the image only the card itself rather than the background 
        extracted_image = None
        if is_extracted:
            extracted_image = ImagePreProcessor.extract_card(sharppen_image)

        if extracted_image is None:
            extracted_image = sharppen_image
        
        

        #convert to binarized form 0 and 1 (must be gray) and dilate -> erode
        dilated_image = None
        if is_bi:
            binarized_image = ImagePreProcessor.gausian_threshold(extracted_image)

            # erode -> dilate = opening which is used to remove noise
            # eroded_image = cv.erode(binarized_image, np.ones((3,3), np.uint8))
            # dilated_image = cv.dilate(eroded_image, np.ones((3,3), np.uint8))
            dilated_image = binarized_image
        
        if dilated_image is None:
            dilated_image = gray_image
        

        return dilated_image
    
