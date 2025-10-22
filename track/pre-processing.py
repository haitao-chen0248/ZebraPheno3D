import cv2
import os
import numpy as np
import argparse
import logging
from tqdm import tqdm
from concurrent.futures import ProcessPoolExecutor, as_completed
from multiprocessing import cpu_count

# Set up logging
logging.basicConfig(level=logging.INFO, format='[%(levelname)s] %(message)s')


def compute_background(video_path, downsample_factor=2, target_sample_frames=100):
    """
    Compute background image by averaging every `step`-th downsampled frame.
    """
    cap = cv2.VideoCapture(video_path)
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    step = max(1, total_frames // target_sample_frames)

    avg_background = None
    count = 0
    current_frame = 0

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        if current_frame % step == 0:
            frame_ds = frame[::downsample_factor, ::downsample_factor].astype(np.float32)
            if avg_background is None:
                avg_background = frame_ds
            else:
                cv2.accumulateWeighted(frame_ds, avg_background, 1.0 / (count + 1))
            count += 1

        current_frame += 1

    cap.release()
    return avg_background.astype(np.uint8) if avg_background is not None else None


def process_video(video_path, output_video_path, background, downsample_factor=2, output_size=(512, 512)):
    """
    Subtract background from each downsampled frame and normalize result.
    """
    cap = cv2.VideoCapture(video_path)
    fps = cap.get(cv2.CAP_PROP_FPS)

    fourcc = cv2.VideoWriter_fourcc(*'avc1')  # or 'mp4v'
    out = cv2.VideoWriter(output_video_path, fourcc, fps, output_size)

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        frame_ds = frame[::downsample_factor, ::downsample_factor]
        min_frame = cv2.min(frame_ds, background)
        diff_frame = cv2.subtract(background, min_frame)
        norm_frame = cv2.normalize(diff_frame, None, 0, 255, cv2.NORM_MINMAX)

        out.write(norm_frame.astype(np.uint8))

    cap.release()
    out.release()


def process_single_video(filename, video_folder, output_folder, downsample_factor=2, output_size=(512, 512)):
    """
    Wrapper to process a single video end-to-end.
    """
    if not filename.lower().endswith(('.mp4', '.avi', '.mov', '.mkv')):
        return f"Skipping {filename}: unsupported format"

    video_path = os.path.join(video_folder, filename)
    output_name = os.path.splitext(filename)[0] + '_bg_rv.mp4'
    output_video_path = os.path.join(output_folder, output_name)

    background = compute_background(video_path, downsample_factor)
    if background is None:
        return f"Skipping {filename}: unable to compute background"

    process_video(video_path, output_video_path, background, downsample_factor, output_size)
    return f"Processed {filename}"


def main(video_folder, output_folder, workers=None):
    os.makedirs(output_folder, exist_ok=True)
    video_files = [f for f in os.listdir(video_folder) if f.lower().endswith(('.mp4', '.avi', '.mov', '.mkv'))]

    workers = min(workers or cpu_count(), len(video_files))
    logging.info(f"Found {len(video_files)} video(s). Using {workers} worker(s).")

    with ProcessPoolExecutor(max_workers=workers) as executor:
        futures = {
            executor.submit(process_single_video, f, video_folder, output_folder): f
            for f in video_files
        }
        for future in tqdm(as_completed(futures), total=len(futures), desc="Processing videos"):
            result = future.result()
            logging.info(result)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Batch video background subtraction and downsampling tool.")
    parser.add_argument('--input', '-i', type=str, required=True, help='Input video folder')
    parser.add_argument('--output', '-o', type=str, required=True, help='Output video folder')
    parser.add_argument('--workers', '-w', type=int, default=None, help='Number of parallel workers (default: CPU cores)')

    args = parser.parse_args()
    main(args.input, args.output, args.workers)