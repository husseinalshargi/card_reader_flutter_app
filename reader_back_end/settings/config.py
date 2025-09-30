from dotenv import load_dotenv
import os

class Config:

    load_dotenv('reader_back_end\\.env')

    llm_model = os.environ.get('LLM_MODEL', 'command-r7b-arabic:7b')

    # redis config
    REDIS_HOST = os.environ.get('REDIS_HOST')
    REDIS_PORT = int(os.environ.get('REDIS_PORT'))
    REDIS_PASSWORD = os.environ.get('REDIS_PASSWORD')
