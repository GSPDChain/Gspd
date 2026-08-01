package main

import (
	"fmt"
"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/rawdb"
	"github.com/ethereum/go-ethereum/ethdb/leveldb"
)

func main() {
	db, err := leveldb.New(
		"/root/gspd-bitcoin-testnet-53562/geth/chaindata.backup.20260622_0928",
		16,
		16,
		"",
		false,
	)
	if err != nil {
		panic(err)
	}
	defer db.Close()

	hash := rawdb.ReadHeadBlockHash(db)

	fmt.Println("LastBlock =", hash.Hex())

	num := rawdb.ReadHeaderNumber(db, hash)
	if num == nil {
		fmt.Println("BlockNumber = nil")
	} else {
		fmt.Println("BlockNumber =", *num)
	}

block := rawdb.ReadBlock(db, common.HexToHash("0x4ac0c9019e184b0ed333b977bb246084aadcf68d478618a2a33a2dd35e07afbb"), 0)
fmt.Println("Block exists:", block != nil)
if block != nil {
    fmt.Println("Header number:", block.NumberU64())
}
}
