# this is the new version where it will use gemini api instead of a local llm

import json
from typing import List
import cv2 as cv
from fastapi import HTTPException, status
from google import genai
from google.genai import types

from reader_back_end.settings.config import Config


class AIService:
    def __init__(self):
        try:
            self.client = genai.Client(api_key= Config.GEMINI_KEY)
        except Exception as e: 
            print(f"Error initializing gemini ai error: {e}")
        
    
    def extract_final_text(self, images: List[cv.typing.MatLike]) -> dict[str,any]:
        """
        Takes list of preprocessed images of business cards and extract its values returning a dict having name, phone number, etc
        ### classes:
            - full_name
            - phone_number
            - web_site
            - company_name
            - email
            - address
            - job_title
            - city
            - country
        """

        uploaded_parts = []
        for img in images:
            success, encoded_image = cv.imencode('.jpg', img)
            if success:
                uploaded_parts.append(
                    types.Part.from_bytes(data=encoded_image.tobytes(), mime_type="image/jpeg")
                )
        
        # call the model to return the classes
        try:
            response = self.client.models.generate_content(model= "gemini-flash-lite-latest",
                                                       contents= ["""
                                                                You are a dedicated Business Card Data Extractor. Your ONLY function is to identify
                                                                business cards and extract contact details into JSON.
                                                                CRITICAL RULES:

                                                                1. If the image is a book, document, or anything other than a business card,
                                                                return: 
                                                                {"error": "INVALID_OBJECT", "message": "Please scan a business card. "}

                                                                2. if you are unsure if the object is a business card, default to the error response.

                                                                3. Do not explain your reasoning.

                                                                4. Do not engage in conversation.

                                                                5. if the class not found make it's value only an empty string "".

                                                                6. If multiple cards are present, only extract the most prominent one.

                                                                7. If the card is multilingual, prioritize English but include Arabic text if English is unavailable for a specific field.
 
                                                                8. Return ONLY the raw JSON. Do not include markdown formatting or backticks.
                                               
                                                                output structure:
                                                            {
                                                                "full_name": "",
                                                                "phone_number": "",
                                                                "office_number": "",
                                                                "web_site": "",
                                                                "company_name": "",
                                                                "email": "",
                                                                "address": "",
                                                                "job_title": "",
                                                                "city": "",
                                                                "country": ""
                                                            }
                                                              """]+uploaded_parts, 
                                                        config=types.GenerateContentConfig(
                                                            response_mime_type="application/json",
                                                    ))
        except Exception as e:
            print(f'error in llm {e}')
            raise HTTPException(status_code= status.HTTP_500_INTERNAL_SERVER_ERROR, detail= "Something went wrong, try again later")


        try:
            response_dict = json.loads(response.text)
        except Exception as e:
            print(f'error in json {e}')
            raise HTTPException(status_code= status.HTTP_500_INTERNAL_SERVER_ERROR, detail= "Something went wrong, try again later")
        
        return response_dict


        


    
