import os
from PIL import Image
from tqdm import tqdm

# Define paths and classes to process
base_path = "./imagenette_data/imagenette2"
classes_to_process = ['n01440764', 'n02102040', 'n02979186']
min_size = 160
output_base_path = "./processed_images_160"


def process_image(image_path, output_path):
    with Image.open(image_path) as img:
        # Get original dimensions
        # width, height = img.size
        # # Calculate new dimensions
        # resize_flag = min(width, height) < min_size
        # if width <= height and width < min_size:
        #     new_width = min_size
        #     new_height = int((min_size / width) * height)
        # elif height <= width and height < min_size:
        #     new_height = min_size
        #     new_width = int((min_size / height) * width)
        resize_flag = True
        new_width = 160
        new_height = 160

        if resize_flag:
            # Resize image
            img = img.resize((new_width, new_height), Image.LANCZOS)

        img = img.convert('RGB')

        # Save image to the output path
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        img.save(output_path)


# Collect all images to be processed
images_to_process = []

for split in ['train', 'val', 'test']:
    for class_name in classes_to_process:
        class_path = os.path.join(base_path, split, class_name)
        if not os.path.exists(class_path):
            continue
        for image_name in os.listdir(class_path):
            image_path = os.path.join(class_path, image_name)
            output_path = os.path.join(output_base_path, class_name, image_name)
            images_to_process.append((image_path, output_path))

# Process images with progress tracking
for image_path, output_path in tqdm(images_to_process, desc="Processing Images"):
    process_image(image_path, output_path)

print("Processing completed.")
