#!/bin/python3
import os, requests, zipfile, tempfile

t = tempfile.TemporaryFile()
print("Zipping lfs to temp ...")
def zipdir(path):
    ziph = zipfile.ZipFile(t, 'w', zipfile.ZIP_DEFLATED)
    # ziph is zipfile handle
    for root, dirs, files in os.walk(path):
        for file in files:
            ziph.write(os.path.join(root, file))

zipdir(os.path.join(os.path.dirname(__file__), "lfs"))
t.seek(0)
print("Zipped.")
print("Uploading zip to blog.ellisons.org.uk ...")
resp = requests.post("https://blog.ellisons.org.uk/luac", files={'userfile': ("lfs.zip", t)})
print("{} {}".format(resp.status_code, resp.reason))
if resp.status_code == 200:
    print("Success! Writing lfs.img ...")
    with open("lfs.img", 'wb') as f:
        f.write(resp.content)