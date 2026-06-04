from sqlalchemy import Column, Integer, String

# '..' will enable us to go one level higher as database is one dir level higher than this dir
from ..database import SqlDB

class Card(SqlDB.base):
    __tablename__ = "cards"

    id = Column(Integer, primary_key= True, autoincrement= True)
    user_id = Column(String(255), nullable= False)
    full_name = Column(String(255), nullable= True)
    phone_number = Column(String(255), nullable= True)
    office_number = Column(String(255), nullable= True)
    web_site = Column(String(255), nullable= True)
    company_name = Column(String(255), nullable= True)
    email = Column(String(255), nullable= True)
    address = Column(String(255), nullable= True)
    job_title = Column(String(255), nullable= True)
    city = Column(String(255), nullable= True)
    country = Column(String(255), nullable= True)
