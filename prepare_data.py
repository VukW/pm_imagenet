import os
from torchvision.datasets import Imagenette
from torchvision.transforms import Resize, Compose
import pandas as pd

# Constants
N_IMAGES_PER_CLASS = 100  # Set the desired number of images per class


def create_csvs(imagenette_root_folder: str, classes: list[str], n_images_per_class: int = 100):
    # Datasets to be created
    datasets = {'train': [], 'test': [], 'val': []}

    # Iterate over each class
    for class_id, class_name in enumerate(classes):
        train_path = os.path.join(imagenette_root_folder, 'train', class_name)
        val_path = os.path.join(imagenette_root_folder, 'val', class_name)

        images = sorted(os.listdir(train_path) + os.listdir(val_path))  # Ensure consistent ordering

        if len(images) < 3 * n_images_per_class:
            raise ValueError(
                f"Not enough images for class {class_name}. Needed: {3 * n_images_per_class}, Found: {len(images)}")

        # Split images into train, test, val
        train_images = images[:n_images_per_class]
        test_images = images[n_images_per_class:2 * n_images_per_class]
        val_images = images[2 * n_images_per_class:3 * n_images_per_class]

        # Append to respective dataset lists
        for img_set, name in zip([train_images, test_images, val_images], ['train', 'test', 'val']):
            for i, img in enumerate(img_set):
                if img in os.listdir(train_path):
                    img_path = os.path.join(train_path, img)
                else:
                    img_path = os.path.join(val_path, img)
                datasets[name].append([img_path, class_id, i])

    # Create CSVs for each dataset
    for name, data in datasets.items():
        df = pd.DataFrame(data, columns=['Channel_0', 'ValueToPredict', 'subjectID'])
        df.to_csv(f'labels_imagenette_{name}.csv', index=False)


def main():
    # Transformations: Resize images and convert to tensor
    transform = Compose([Resize((256, 256))])

    # Load datasets
    # train_set = Imagenette(root='imagenette_data', split='train', size='full', download=True, transform=transform)
    # val_set = Imagenette(root='imagenette_data', split='val', size='full', download=False, transform=transform)
    # test_set = Imagenette(root='imagenette_data', split='val', size='full', download=False, transform=transform)  # Reuse val for example

    create_csvs('imagenette_data/imagenette2/',
                classes=['n01440764', 'n02102040'])  # Example class IDs for 'tench' and 'English springer'


if __name__ == "__main__":
    main()
