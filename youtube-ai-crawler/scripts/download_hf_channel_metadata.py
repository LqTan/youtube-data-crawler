import os
from pathlib import Path

from datasets import load_dataset


DATASET_NAME = "jamescalam/channel-metadata"
OUTPUT_DIR = Path("data/external/hf_channel_metadata")
OUTPUT_CSV = OUTPUT_DIR / "external_dataset.csv"


def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    print("Downloading HuggingFace dataset:", DATASET_NAME)

    ds = load_dataset(DATASET_NAME, split="train")
    df = ds.to_pandas()

    df.to_csv(OUTPUT_CSV, index=False)

    print("Saved:", OUTPUT_CSV)
    print("Rows:", len(df))
    print("Columns:", list(df.columns))


if __name__ == "__main__":
    main()