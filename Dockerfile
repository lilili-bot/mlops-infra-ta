# Use a lightweight base image for Python
# todo: recreate image due to repo restructure.
FROM python:3.9-slim

# Set the working directory
WORKDIR /src

# Copy the requirements file into the image
COPY requirements.txt .

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire app directory into the image
COPY ./src /src

# Expose the port that FastAPI will run on
EXPOSE 80

# CMD ["/bin/sh"]
# Command to run the FastAPI application with Uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]

# gk3-dh-global-sales-data-nap-jux8avut-8eade5f3-vnir/10.2.0.5