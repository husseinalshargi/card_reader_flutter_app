import json
from easyocr import Reader
import torch
from langchain_core.prompts import PromptTemplate
from langchain_ollama import OllamaLLM
import cv2 as cv
from langchain_core.output_parsers import StrOutputParser


class AIService:
    gpu = False
    if torch.cuda.is_available():
        print('cuda available')
        gpu = True
    else:
        print('cuda not available')

    
    def __init__(self, llm: OllamaLLM):
        self.set_up_prompts()
        self.llm = llm
        #StrOutputParser is needed to pass a dict to the llm that has values which will be injected in the prompt, first template then the llm in the chain
        self.llm_chain = (self.template |llm | StrOutputParser())

    def set_up_prompts(self):
        self.template = PromptTemplate.from_template(
        """
        You are a text corrector and text classifier; an OCR will extract details of a business card, and your job is to correct and classify the text. 

        Rules:
            - Correct obvious typos based, for example, Arywhere -> Anywhere. 
            - Correct links, for example, wwwdomaincom -> www.domain.com. 
            - Do not correct words if you are uncertain of their meaning. 
            - Do not correct Names.
            - Do not correct numbers.
            - If a word contains a number in the middle, then correct it with a character instead of the number, whether it is a name or not. 
            - You must classify each part of the extracted text, even if uncertain 
            - Do not hallucinate.
            - In case you are uncertain of the class, then just include it anywhere that might be related. 
            - In case a class has info, then place the text in any other class.  
            - Output MUST have all classes even in case of it is empty.
            - Output MUST be a single JSON object, no comments, no extra text.
            - phone_number and telephone_number must be only numbers, no '+', '-' or other characters only numbers.
            - if there is more info than the classes you could add relavent text in the same class.

        Classes:
            - full_name
            - phone_number
            - telephone_number
            - web_site
            - company_name
            - email
            - address
            - job_title
            - department
            - city
            - state
            - country

        -----

        Card Details:

        {card_details}

        ------

        Output format:
        {{
            "full_name": "",
            "phone_number": "",
            "telephone_number": "",
            "web_site": "",
            "company_name": "",
            "email": "",
            "address": "",
            "job_title": "",
            "department": "",
            "city": "",
            "state": "",
        }}

        """
        )

       

    def read_image(self, img: cv.typing.MatLike, languages_list: list[str]) -> list[str]:
        """read the image text using easy ocr, returns a list of texts which is in the img"""
        try:
            reader = Reader(languages_list, AIService.gpu)
            results = reader.readtext(img)

            text = []
            for result in results:
                #skip bad extraction
                if result[2] < 0.20: continue
                text.append(result[1])
            return text
        
        except Exception as e:
            print(f'error in ocr {e}')
            return ''
    
    def set_up_results(self, results: list[str]) -> str:
        """setup card info for llm"""
        return ', '.join(results)

    def llm_process_ocr(self, card_details_in_text: str) -> dict[str, str]:
        """
        llm will process, correct and arrange the str of extracted text to classes
        
        classes:
            - full_name
            - phone_number
            - telephone_number
            - web_site
            - company_name
            - email
            - address
            - job_title
            - department
            - city
            - state
            - country
        """
        try:
            response = self.llm_chain.invoke({'card_details': card_details_in_text})
        except Exception as e:
            print(f'error in llm {e}')

        try:
            response_dict = json.loads(response)
        except Exception as e:
            print(f'error in parsing to json {e}')
            return {}
        
        #convert numbers to int
        try:
            response_dict['phone_number'] = response_dict['phone_number']
        except Exception as e:
            print("error in converting phone number to an int")
        
        try:
            response_dict['telephone_number'] = response_dict['telephone_number']
        except Exception as e:
            print("error in converting telephone number to an int")

        
        return response_dict
        
    
    def extract_final_text(self, img: cv.typing.MatLike, languages_list: list[str] = ['en']) -> dict[str, str]:
        """extract the final text from the image"""

        # extract text using ocr
        extracted_words_list = self.read_image(img, languages_list)

        # convert easyocr list of strings to a single string to pass it to the llm
        string_text = self.set_up_results(extracted_words_list)

        # pass the string of classes to the llm to arrange them 
        final_response = self.llm_process_ocr(string_text)

        return final_response


        
