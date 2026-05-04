import re
from pathlib import Path

import pandas as pd
from datasets import load_dataset


DATASET_NAME = "jamescalam/youtube-transcriptions"
OUTPUT_DIR = Path("data/external/hf_youtube_transcriptions")
OUTPUT_CSV = OUTPUT_DIR / "external_dataset.csv"


def extract_video_id(value):
    if not isinstance(value, str):
        return ""

    patterns = [
        r"v=([a-zA-Z0-9_-]{11})",
        r"youtu\.be/([a-zA-Z0-9_-]{11})",
        r"embed/([a-zA-Z0-9_-]{11})",
        r"shorts/([a-zA-Z0-9_-]{11})",
    ]

    for pattern in patterns:
        match = re.search(pattern, value)
        if match:
            return match.group(1)

    if re.fullmatch(r"[a-zA-Z0-9_-]{11}", value.strip()):
        return value.strip()

    return ""


def find_column(columns, candidates):
    normalized = {col.lower().strip(): col for col in columns}

    for candidate in candidates:
        if candidate.lower() in normalized:
            return normalized[candidate.lower()]

    return None


def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    print("Downloading HuggingFace dataset:", DATASET_NAME)

    ds = load_dataset(DATASET_NAME, split="train")
    df = ds.to_pandas()

    print("Original rows:", len(df))
    print("Original columns:", list(df.columns))

    url_col = find_column(
        df.columns,
        ["url", "video_url", "youtube_url", "link", "source"],
    )

    video_id_col = find_column(
        df.columns,
        ["external_video_id", "video_id", "youtube_video_id", "id"],
    )

    text_col = find_column(
        df.columns,
        ["text", "transcript", "transcript_text", "sentence"],
    )

    title_col = find_column(
        df.columns,
        ["title", "video_title"],
    )

    if text_col is None:
        raise ValueError("Cannot find transcript text column.")

    if video_id_col:
        df["external_video_id"] = df[video_id_col].apply(extract_video_id)
    elif url_col:
        df["external_video_id"] = df[url_col].apply(extract_video_id)
    else:
        raise ValueError("Cannot find URL or video_id column.")

    df = df[df["external_video_id"] != ""]

    if df.empty:
        raise ValueError("No valid YouTube video IDs found.")

    agg_map = {
        text_col: lambda values: " ".join(
            str(v).strip() for v in values if pd.notna(v) and str(v).strip()
        )
    }

    if url_col:
        agg_map[url_col] = "first"

    if title_col:
        agg_map[title_col] = "first"

    grouped = df.groupby("external_video_id").agg(agg_map).reset_index()

    grouped = grouped.rename(columns={
        text_col: "transcript_text",
    })

    if url_col:
        grouped = grouped.rename(columns={url_col: "video_url"})
    else:
        grouped["video_url"] = grouped["external_video_id"].apply(
            lambda video_id: f"https://www.youtube.com/watch?v={video_id}"
        )

    if title_col:
        grouped = grouped.rename(columns={title_col: "video_title"})
    else:
        grouped["video_title"] = ""

    grouped["source_dataset"] = "hf_youtube_transcriptions"

    final_columns = [
        "external_video_id",
        "video_title",
        "video_url",
        "transcript_text",
        "source_dataset",
    ]

    grouped = grouped[final_columns]

    grouped.to_csv(OUTPUT_CSV, index=False)

    print("Saved:", OUTPUT_CSV)
    print("Grouped rows:", len(grouped))
    print("Columns:", list(grouped.columns))


if __name__ == "__main__":
    main()