import os
import shutil
import subprocess
from pathlib import Path

import pandas as pd


DATASET_SLUG = "asmaahadir/aiml-youtube-channels-content-2018-2019"
OUTPUT_DIR = Path("data/external/kaggle_aiml")
OUTPUT_CSV = OUTPUT_DIR / "external_dataset.csv"


def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    print("Downloading Kaggle dataset:", DATASET_SLUG)

    subprocess.run(
        [
            "kaggle",
            "datasets",
            "download",
            "-d",
            DATASET_SLUG,
            "-p",
            str(OUTPUT_DIR),
            "--unzip",
        ],
        check=True,
    )

    csv_files = list(OUTPUT_DIR.glob("*.csv"))

    if not csv_files:
        raise FileNotFoundError("No CSV file found after downloading Kaggle dataset.")

    # Chọn file CSV lớn nhất, thường là file dữ liệu chính
    source_csv = max(csv_files, key=lambda p: p.stat().st_size)

    print("Selected CSV:", source_csv)

    df = pd.read_csv(source_csv)

    df.to_csv(OUTPUT_CSV, index=False)

    print("Saved:", OUTPUT_CSV)
    print("Rows:", len(df))
    print("Columns:", list(df.columns))


if __name__ == "__main__":
    main()