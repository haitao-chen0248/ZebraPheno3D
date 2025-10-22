import os
import shutil
import logging
import argparse
import deeplabcut as dlc
from tqdm import tqdm


def setup_logging():
    logging.basicConfig(level=logging.INFO, format='[%(levelname)s] %(message)s')


def get_config_path(filename, config_even, config_odd):
    """
    Determine which DLC config to use based on the number in the filename.
    """
    digits = ''.join(filter(str.isdigit, os.path.splitext(filename)[0]))
    if not digits:
        raise ValueError(f"Filename {filename} does not contain digits.")
    
    number = int(digits)
    return config_odd if number % 2 == 1 else config_even


def process_videos(video_folder, config_even, config_odd):
    video_files = [f for f in os.listdir(video_folder) if f.endswith(".mp4")]
    logging.info(f"Found {len(video_files)} videos to process.")

    for filename in tqdm(video_files, desc="Processing videos"):
        try:
            config_path = get_config_path(filename, config_even, config_odd)
            video_path = os.path.join(video_folder, filename)

            # Analyze the video and save results as CSV
            dlc.analyze_videos(config_path, [video_path], save_as_csv=True)

            # Optional: filter predictions
            # dlc.filterpredictions(config_path, [video_path])

            # Create labeled video (unfiltered version)
            dlc.create_labeled_video(
                config_path,
                [video_path],
                videotype=".mp4",
                filtered=False,
                draw_skeleton=True
            )
        except Exception as e:
            logging.error(f"Failed to process {filename}: {e}")


def organize_outputs(video_folder, csv_folder, labeled_video_folder):
    """
    Move DLC outputs to appropriate folders. Delete unwanted files.
    """
    for filename in os.listdir(video_folder):
        file_path = os.path.join(video_folder, filename)

        if os.path.isdir(file_path):
            continue

        if filename.endswith(".mp4") and "DLC" in filename:
            shutil.move(file_path, os.path.join(labeled_video_folder, filename))
        elif filename.endswith(".csv"):
            shutil.move(file_path, os.path.join(csv_folder, filename))
        elif not filename.endswith((".avi", ".mp4", ".nc", ".json", ".ipynb")):
            os.remove(file_path)


def main(folder_path, config_even, config_odd):
    setup_logging()

    video_folder = os.path.join(folder_path, "video")
    csv_folder = os.path.join(folder_path, "data_csv")
    labeled_video_folder = os.path.join(folder_path, "dlc_video")

    os.makedirs(csv_folder, exist_ok=True)
    os.makedirs(labeled_video_folder, exist_ok=True)

    process_videos(video_folder, config_even, config_odd)
    organize_outputs(video_folder, csv_folder, labeled_video_folder)
    logging.info("Processing complete.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Process videos with DeepLabCut using two config files.")
    parser.add_argument("--folder", "-f", required=True, help="Path to the root folder containing 'video/'")
    parser.add_argument("--config_even", "-e", required=True, help="Path to DLC config.yaml for even-numbered files")
    parser.add_argument("--config_odd", "-o", required=True, help="Path to DLC config.yaml for odd-numbered files")
    args = parser.parse_args()

    main(args.folder, args.config_even, args.config_odd)