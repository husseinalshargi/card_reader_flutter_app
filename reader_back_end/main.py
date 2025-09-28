from langchain_ollama import OllamaLLM
from fastapi import FastAPI, UploadFile, File, Form
from pydantic import BaseModel

from reader_back_end.services.card_reader import CardReader
from reader_back_end.settings.config import Config

languages_list: list[str]

try:
    app = FastAPI()

    #setup the llm instance the llm
    llm = OllamaLLM(model = Config.llm_model)

    print('initalizing card reader')

    #setup the class that has the process of reading card details
    card_reader = CardReader(llm)

    print('card reader initialized')

except Exception as e:
    print(f'error in initializing card reader back-end - {e}')    

        
@app.post('/process_card')
async def get_card_details(is_binarized: bool = Form(...),
                            is_extracted: bool = Form(...),
                            language: str = Form('en'),
                            image: UploadFile = File(...)):
    
    #read the image content (in bytes)
    img_content = await image.read()

    #as easy ocr in case of other languages it require them to be in the second place after 'en'
    languages_list = ['en'] if language.strip().lower() == 'en' else ['en', language.strip().lower()]

    #return the values in dict form 
    card_details = card_reader.read_card(img_content, is_binarized, is_extracted, languages_list)

    return card_details
