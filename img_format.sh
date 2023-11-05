#!/usr/bin/python

import os
import random
import exifread
from datetime import datetime
import time

FS_TIME_READ = "%Y:%m:%d %H:%M:%S"
TIME_WRITE = "%Y-%m-%dT%H.%M.%S"

for image_path in os.listdir("."):
    if (image_path.endswith(".jpg")):
        image = open(image_path, 'rb')
        
        tags = exifread.process_file(image)
        if "EXIF DateTimeOriginal" in tags:
            timestamp = tags["EXIF DateTimeOriginal"]
        elif "EXIf CreateDate" in tags:
            timestamp = tags["EXIF CreateDate"]
        else:
            mtime = os.path.getmtime(image_path)
            mtime_obj = datetime.fromtimestamp(mtime)
            timestamp = mtime_obj.strftime(FS_TIME_READ)
        time_obj = datetime.strptime(str(timestamp), FS_TIME_READ)
        
        new_image_path = str(time_obj.strftime(TIME_WRITE) + ".jpg")
        print(image_path + ": " + str(timestamp) + " -> " + new_image_path)
        
        if os.path.isfile(new_image_path):
            if (image_path == new_image_path):
                print (new_image_path + ": Image already named correctly.")
            else:
                overwrite = input(new_image_path + " already exists. Do you want to continue? [y/n]: ")
                if overwrite == 'y':
                    print("Overwriting " + image_path + " with " + new_image_path + " …")
                else:
                    print("Keeping " + new_image_path + " …")
                    new_image_path = str(time_obj.strftime(TIME_WRITE) + "_" + str(random.randint(1000, 9999)) + ".jpg")
                    print("Renaming to " + new_image_path + " instead …")
        
        os.rename(image_path, new_image_path)

        unixtime = time.mktime(time_obj.timetuple())
        print (new_image_path + ": utime update to " + str(unixtime))
        os.utime (new_image_path, (unixtime, unixtime))
