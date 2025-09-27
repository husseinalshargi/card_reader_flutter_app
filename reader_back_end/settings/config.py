from dotenv import load_dotenv
import os

class Config:

    load_dotenv()

    llm_model = os.environ.get('LLM_MODEL', 'command-r7b-arabic:7b')
