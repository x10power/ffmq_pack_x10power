import os
import pandas as pd
import tempfile
from PIL import Image

def convert_bytes(num):
    """Take number of bytes and convert to string with units measure"""
    for x in ["b", "KB", "MB", "GB", "TB", "PB", "YB"]:
        if num < 1024.0:
            return f"{num:3.1f}{x}"
            # return "%3.1f %s" % (num, x)
        num /= 1024.0
    return 0


def file_size(file_path):
    """Get filesize of file at path"""
    if os.path.isfile(file_path):
        file_info = os.stat(file_path)
        return convert_bytes(file_info.st_size)
    return 0

for r,d,f in os.walk(os.path.join(".", "images")):
    for filename in f:
        filext = os.path.splitext(filename)[1][1:]
        if filext in ["gif"]:
            filepath = os.path.join(r, filename)
            this_image = Image.open(filepath)
            this_size = os.stat(filepath).st_size
            # print(">" + os.path.join(r, filename))
            webp_sizes = []
            columns = ["100", "100-lossy", "90-lossy"]
            for webp_spec in columns:
                factor = 100
                lossless = True
                if "90" in webp_spec:
                    factor = 90
                if "lossy" in webp_spec:
                    lossless = False
                temp_handle = tempfile.TemporaryFile(suffix=".webp", delete=False)
                this_image.save(temp_handle.name, quality=factor, lossless=lossless)
                temp_size = os.stat(temp_handle.name).st_size
                if temp_size > this_size:
                    temp_size = ""
                else:
                    temp_size = file_size(temp_handle.name)
                webp_sizes.append(temp_size)
                temp_handle.close()
            print(filepath)
            df = pd.DataFrame(
                [[file_size(filepath), *webp_sizes]],
                columns=[filext, *columns],
                index=[""]
            )
            print(df)
            print("")
