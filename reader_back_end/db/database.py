from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, DeclarativeBase, declarative_base

from reader_back_end.settings.config import Config

class SqlDB:
    def __init__(self):
        self.engine = create_engine(url=Config.mysql_url, echo=False)
        self.sessionmaker = sessionmaker(bind=self.engine)
        # uncomment this to see base commands as it is "any"
        # self.base = Base()
        self.base = declarative_base()

    def init_db(self):
        # import all models to create
        from reader_back_end.db.models import card
        # create all tables 
        self.base.metadata.create_all(bind= self.engine)

    def get_db(self):
        try:
            db_session = self.sessionmaker()
            
            # pass the session until the request finish then it will be closed
            yield db_session
        finally:
            db_session.close()


# uncomment this to see base commands as it is "any"
# class Base(DeclarativeBase):
#     pass
        

        


