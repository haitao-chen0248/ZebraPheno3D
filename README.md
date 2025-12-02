# ZebraPheno3D

**ZebraPheno3D** is a high-throughput platform designed for the 3D behavioral and anatomical phenotyping of zebrafish larvae. Consisting of a **multi-camera array microscope (MCAM)** and a co-designed **mirrored well plate**, it enables the simultaneous capture of synchronized top and side views of up to 48 swimming larvae. An efficient, scalable machine learning pipeline enables accurate 3D behavioral and morphodynamical analysis and automated analysis of larvae at several hundred frames per second. The methodology is detailed in our preprint:  
📄 [High-throughput multi-camera array microscope platform for automated 3D behavioral analysis of swimming zebrafish larvae](https://www.biorxiv.org/content/10.1101/2025.07.07.661868v2.full)

---

## ✨ Features

- **3D Behavior Tracking:**  
  Uses **DeepLabCut** to track larval zebrafish from synchronized **top** and **side** views, reconstructing 3D skeletons for fine-grained behavioral analysis.

- **Swim Bladder Segmentation and Reconstruction:**  
  Employs **SAM2** to segment the swim bladder from videos and reconstruct its 3D shape.

- **Behavioral Kinematics:**  
  MATLAB scripts are used to derive kinematic variables from skeleton data, including trajectory and posture information.

---

## 🗂 Project Structure

```
ZebraPheno3D-main/
│
├── dataset/track/                # Sample videos and CSVs for tracking
│   ├── video/                    # Top and side view videos
│   └── csv/                      # Annotated keypoints (DeepLabCut outputs)
│
├── kinematics/                   # MATLAB scripts for 3D kinematic analysis
│   ├── kinematics.m
│   ├── skeleton.m
│   └── trajectory.m
│
├── swimbladder/                 # Notebooks for swim bladder segmentation and analysis
│   ├── Swim Bladder Segmentation.ipynb
│   ├── Swim Bladder Reconstruction.ipynb
│   ├── Dice Verification.ipynb
│   ├── Analysis.ipynb
│   └── dice.csv, swimbladder_data.csv
│
├── track/                       # Python scripts for pre-processing and DeepLabCut tracking
│   ├── pre-processing.py
│   └── tracking.py
│
├── LICENSE
└── README.md
```

---

## 🛠 Installation & Dependencies

### Python Environment

Install the required Python packages for tracking and segmentation. You will need:

- [DeepLabCut](https://github.com/DeepLabCut/DeepLabCut) for multi-view pose estimation
- [SAM2](https://github.com/facebookresearch/sam2) for swim bladder segmentation

```bash
# Core packages
conda install opencv numpy matplotlib

# Install DeepLabCut (see repo for full instructions)
# Please follow official instructions: https://deeplabcut.github.io/DeepLabCut/docs/installation.html

# Install SAM2 (requires PyTorch, torchvision, etc.)
# Please follow official instructions: https://github.com/facebookresearch/sam2
```

### MATLAB

To run the kinematic reconstruction:

- MATLAB R2021a or later recommended
- Make sure to add the `kinematics/` folder to your MATLAB path

---

## 🚀 Usage

### 1. Pre-process and Track

Prepare your videos and run tracking:

```bash
cd track
python pre-processing.py
python tracking.py
```

This generates `.csv` files containing 2D keypoints for both top and side views.

### 2. 3D Skeleton Reconstruction

Use MATLAB scripts in `kinematics/` to reconstruct 3D skeletons from the tracked points and compute movement parameters.

### 3. Swim Bladder Segmentation & Analysis

Run the Jupyter notebooks in `swimbladder/` to segment the swim bladder and perform 3D reconstruction and analysis.

---

## 📄 Citation

If you use this codebase or datasets, please cite:

```bibtex
@article {Chen2025.07.07.661868,
  author = {Chen, Haitao and Li, Kevin and Kreiss, Lucas and Reamey, Paul and Pierce, Lain X. and Zhang, Ralph and Da Luz, Ricardo and Chaware, Amey and Kim, Kanghyun and Cook, Clare B. and Yang, Xi and Lerner, Joshua F. and Doman, Jed and B{\`e}gue, Aur{\'e}lien and Efromson, John and Harfouche, Mark and Horstmeyer, Gregor and McCarroll, Matthew N. and Horstmeyer, Roarke},
  title = {High-throughput multi-camera array microscope platform for automated 3D behavioral analysis of swimming zebrafish larvae},
  elocation-id = {2025.07.07.661868},
  year = {2025},
  doi = {10.1101/2025.07.07.661868},
  publisher = {Cold Spring Harbor Laboratory},
  URL = {https://www.biorxiv.org/content/early/2025/10/20/2025.07.07.661868},
  eprint = {https://www.biorxiv.org/content/early/2025/10/20/2025.07.07.661868.full.pdf},
  journal = {bioRxiv}
}
```

---

## 🧠 License

This project is licensed under the terms of the MIT license. See the [LICENSE](./LICENSE) file for details.
