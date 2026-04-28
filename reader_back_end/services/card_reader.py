from typing import List

import cv2 
from google import genai
from langchain_ollama import OllamaLLM
import numpy as np

from reader_back_end.services.ai_service import AIService
from reader_back_end.services.image_pre_processor import ImagePreProcessor
from reader_back_end.settings.config import Config


class CardReader:
    def __init__(self):
        try:
            self.ai_service = AIService()
        except Exception as e:
            raise e

    
    def read_image(self, img_bytes: bytes) -> cv2.typing.MatLike:
        """Reads an image (it will read the image in bytes and convert it to an open cv img object)"""
        np_array = np.frombuffer(img_bytes, dtype= 'uint8')
        img_np = cv2.imdecode(np_array, cv2.IMREAD_COLOR_BGR)
        
        return img_np



    def read_card(self, images_bytes: List[bytes], is_binarized: bool, is_extracted: bool, user_id = "", user_email = "") -> dict[str, str]:
        """combine all services to read the card content (could be used for the api)"""

        #read the original image
        imgs = [self.read_image(img_bytes) for img_bytes in images_bytes]

        #pre-process the image
        processed_images = [ImagePreProcessor.process_image(img, is_binarized, is_extracted, user_id = user_id, user_email = user_email) for img in imgs]

        #get the final content of the card in dict format with all the classes
        card_content = self.ai_service.extract_final_text(processed_images, user_id = user_id, user_email = user_email)

        return card_content

