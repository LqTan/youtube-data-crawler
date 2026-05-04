package main

import (
	"context"
	"flag"
	"fmt"
	"youtube-ai-crawler/internal/env"
	"youtube-ai-crawler/internal/importcsv"
	"youtube-ai-crawler/internal/importer"
	"youtube-ai-crawler/internal/pgconn"
)

func main() {
	_ = env.LoadFile(".env")
	_ = env.LoadFile("../postgres/.env")

	ctx := context.Background()

	defaultInputCSV := env.Get("INPUT_CSV", "data/youtube_ai_videos.csv")
	inputCSVFlag := flag.String("input-csv", defaultInputCSV, "Input CSV path to import")
	flag.Parse()

	inputCSV := *inputCSVFlag
	if flag.NArg() >= 1 {
		inputCSV = flag.Arg(0)
	}

	db, err := pgconn.Connect(ctx)
	if err != nil {
		panic(err)
	}
	defer db.Close()

	rows, err := importcsv.ReadFile(inputCSV)
	if err != nil {
		panic(err)
	}

	imp := importer.New()

	successCount := 0
	failCount := 0

	for _, row := range rows {
		err := imp.ImportOne(ctx, db, row)

		if err != nil {
			failCount++
			fmt.Printf("Import failed [%s]: %v\n", row.ExternalVideoID, err)
			continue
		}

		successCount++
		fmt.Printf("[%d] Imported: %s\n", successCount, row.VideoTitle)
	}

	fmt.Println("Done.")
	fmt.Println("Success:", successCount)
	fmt.Println("Failed:", failCount)
}
