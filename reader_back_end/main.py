from langchain_ollama import OllamaLLM
from fastapi import FastAPI, HTTPException, UploadFile, File, Form, Depends

from reader_back_end.database_connections.firebase_db import Firebase_db
from reader_back_end.services.card_reader import CardReader
from reader_back_end.settings.config import Config
from reader_back_end.database_connections.redis_db import Redis_db


languages_list: list[str]

try:
    
    app = FastAPI()

    print("\n=== initalizing redis db ===")
    rdb = Redis_db()
    print('=== redis db initialized ===')

    print("\n=== initalizing firebase ===")
    fdb = Firebase_db()
    print('=== firebase initialized ===')

    #setup the llm instance
    print("\n=== initalizing ollama model ===")
    llm = OllamaLLM(model = Config.llm_model)
    print("=== initalizing ollama model ===")

    print('\n=== initalizing card reader ===')
    #setup the class that has the process of reading card details
    card_reader = CardReader(llm)
    print('=== card reader initialized ===')
    

except Exception as e:
    print(f'error in initializing card reader back-end - {e}')    

# Form(...) indicates for an entry that is a string
# File(...) indicates for an entry that is an image or more than one (i think)
# dependencies= [Depends(api_header_auth.admin_access)] this means when this post is called it will require a header that will be processed in the function api_header_auth.admin_access
# decoded_JWT: dict = Depends(fdb.get_user_id_from_token) this makes it useable in the function
@app.post('/process_card')
async def get_card_details(decoded_JWT: dict = Depends(fdb.get_user_info_from_token),
                            is_binarized: bool = Form(...),
                            is_extracted: bool = Form(...),
                            language: str = Form('en'),
                            image: UploadFile = File(...)):
    
    # now before doing anything the user id will be used to rate limit 
    # the function will return a bool indcating whether the user is under limit or not (currently 3 requests per minute)
    is_request_under_limit: bool = rdb.api_limiter(uid= decoded_JWT["uid"])


    #read the image content (in bytes)
    img_content = await image.read()

    #as easy ocr in case of other languages it require them to be in the second place after 'en'
    languages_list = ['en'] if language.strip().lower() == 'en' else ['en', language.strip().lower()]


    #return the values in dict form 
    card_details = card_reader.read_card(img_content, is_binarized, is_extracted, languages_list)

    return card_details


