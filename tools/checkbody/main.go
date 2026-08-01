package main

import (
	"fmt"

	"github.com/ethereum/go-ethereum/core/rawdb"
)

func main() {
	db, err := rawdb.NewLevelDBDatabaseWithFreezer(
    "/root/gspd-bitcoin-testnet-53562/geth/chaindata.backup.20260622_0928",
		16,
		16,
		"/root/gspd-bitcoin-testnet-53562/geth/chaindata/ancient",
		"",
		false,
	)
	if err != nil {
		panic(err)
	}
	defer db.Close()

	number := uint64(260)

	hash := rawdb.ReadCanonicalHash(db, number)
	fmt.Println("Hash:", hash.Hex())

	body := rawdb.ReadBody(db, hash, number)
	if body == nil {
		fmt.Println("Body: NIL")
		return
	}

	fmt.Println("Transactions:", len(body.Transactions))
	fmt.Println("Uncles:", len(body.Uncles))
}
