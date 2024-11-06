from PIL import Image
import os
import datetime

def extract_metadata(image_path):
    with Image.open(image_path) as img:
        width, height = img.size
        file_format = img.format
        file_size = os.path.getsize(image_path)
        creation_time = datetime.datetime.fromtimestamp(os.path.getmtime(image_path)).strftime('%Y-%m-%dT%H:%M:%S.%f')[:23]
        modification_time = datetime.datetime.fromtimestamp(os.path.getmtime(image_path)).strftime('%Y-%m-%dT%H:%M:%S.%f')[:23]

    return (width, height, file_format, file_size, creation_time, modification_time)

