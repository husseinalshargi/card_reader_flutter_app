from langchain_ollama import OllamaLLM
from fastapi import FastAPI, UploadFile, File
from pydantic import BaseModel

from reader_back_end.services.card_reader import CardReader
from reader_back_end.settings.config import Config

languages_list: list[str]

class ImageRequest(BaseModel):
    is_binarized: bool = True
    is_extracted: bool = True
    language: str = 'en'


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
async def get_card_details(image_request: ImageRequest, image: UploadFile = File(...)):
    img_content = await image.read()
    
