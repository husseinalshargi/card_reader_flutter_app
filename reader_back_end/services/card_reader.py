import cv2 
from langchain_ollama import OllamaLLM
import numpy as np

from reader_back_end.services.image_pre_processor import ImagePreProcessor
from reader_back_end.services.ai_service import AIService


class CardReader:
    def __init__(self, llm: OllamaLLM):
        self.image_pre_processor = ImagePreProcessor()
        self.ai_service = AIService(llm)
    
    def read_image(self, img_bytes: bytes) -> cv2.typing.MatLike:
        """Reads an image (it will read the image in bytes and convert it to an open cv img object)"""
        np_array = np.frombuffer(img_bytes, dtype= 'uint8')
        img_np = cv2.imdecode(np_array, cv2.IMREAD_COLOR_BGR)
        
        return img_np



    def read_card(self, img_bytes: bytes, is_bi: bool, is_extracted: bool, languages_list: list[str]) -> dict[str, str]:
        """combine all services to read the card content (could be used for the api)"""

        #read the original image
        img = self.read_image(img_bytes)

        #pre-process the image
        processed_image = self.image_pre_processor.process_image(img, is_bi, is_extracted)

        #get the final content of the card in dict format with all the classes
        card_content = self.ai_service.extract_final_text(processed_image, languages_list)

        return card_content

