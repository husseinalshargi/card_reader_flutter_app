# Use a python image as our project is based on python
FROM python:3.12-slim

# this is the folder inside the container where the codebase will be
WORKDIR /app

# first copy only the requirement to speed up the process
COPY requirements.txt .

# install the required libraries
RUN pip install --no-cache-dir -r requirements.txt

# now copy the whole codebase to app dir
COPY . .

# this is the port used to contact the backend (i think fastapi by default use it)
EXPOSE 8000

# start running the uvicorn server
# listening to the outside world via 0.0.0.0 -> this means now when you call localhost from outside the container it maps the call to this running server
# the port 8000 will force the app to always use this port
# on production we don't need to use --reload
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]