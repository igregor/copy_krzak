# https://stackoverflow.com/questions/2186525/how-to-use-to-find-files-recursively
# https://www.geeksforgeeks.org/copy-files-and-rename-in-python/
from glob import glob
from pathlib import Path

src_path = 'zamowienia'

def copy_and_rename_pathlib(src_path, dest_path, new_name):
    # Create Path objects
    src_path = Path(src_path)
    dest_path = Path(dest_path)
 
    # Copy and rename the file
    new_path = dest_path / new_name
    src_path.rename(new_path)

for filename in glob(f"{src_path}/**/*.jpg", recursive=True):
    filename_changed = filename.replace("\\", "--").replace(" ", "_").replace(f"{src_path}--", "")
    copy_command = f"copy \"{filename}\" test"
    
    copy_and_rename_pathlib(filename, 'zamowienia', filename_changed)