package ethash

import (
	"math/big"

	"github.com/ethereum/go-ethereum/consensus"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/params"
)

// ══════════════════════════════════════════════════════════════════
//  GSPD Bitcoin-style difficulty retarget.
//  Mengikuti struktur GetNextWorkRequired()/CalculateNextWorkRequired() di
//  Bitcoin Core (pow.cpp): retarget HANYA setiap RetargetInterval blok
//  (bukan setiap blok seperti Ethereum), dibanding TargetTimespan, dengan
//  clamp 0.25x-4x untuk mencegah lonjakan difficulty ekstrem.
// ══════════════════════════════════════════════════════════════════
const (
	RetargetInterval uint64 = 2016       // blok — setara DifficultyAdjustmentInterval() Bitcoin
	TargetBlockTime  int64  = 600        // detik — setara nPowTargetSpacing Bitcoin (10 menit)
	TargetTimespan   int64  = 2016 * 600 // detik — setara nPowTargetTimespan Bitcoin (2016 x 600 = 2 minggu)
)

// calcDifficultyBitcoin menghitung difficulty ala Bitcoin Core.
//
// - Kalau blok berikutnya BUKAN kelipatan RetargetInterval: difficulty SAMA
//   dengan parent, TIDAK dihitung ulang (persis baris "if ((height+1) %
//   DifficultyAdjustmentInterval() != 0) return pindexLast->nBits;" di pow.cpp).
// - Kalau kelipatan RetargetInterval: ambil actual timespan dari RetargetInterval
//   blok terakhir, clamp ke [TargetTimespan/4, TargetTimespan*4], lalu
//   newDifficulty = oldDifficulty * TargetTimespan / actualTimespan.
//
// Catatan implementasi: window RetargetInterval blok terakhir diambil dengan
// MENELUSURI ANCESTRY parent secara langsung (chain.GetHeader by ParentHash,
// bukan chain.GetHeaderByNumber by height) — supaya perhitungan selalu
// konsisten dengan rantai yang benar-benar sedang di-extend oleh `parent`,
// sama seperti Bitcoin Core menelusuri pindexLast->GetAncestor(), bukan
// mengasumsikan height tertentu selalu merujuk blok yang sama di rantai
// kanonik saat ini (penting untuk menghindari kesalahan saat ada reorg pendek).
func calcDifficultyBitcoin(
	chain consensus.ChainHeaderReader,
	time uint64,
	parent *types.Header,
) *big.Int {
	nextNumber := parent.Number.Uint64() + 1

	// Bukan blok retarget — difficulty parent dipakai apa adanya.
	if nextNumber%RetargetInterval != 0 {
		return new(big.Int).Set(parent.Difficulty)
	}

	// Belum cukup histori untuk window penuh (mis. RetargetInterval pertama
	// sejak BitcoinForkBlock) — fallback aman: pertahankan difficulty parent
	// daripada mengekstrapolasi dari window yang tidak lengkap.
	if nextNumber < RetargetInterval {
		return new(big.Int).Set(parent.Difficulty)
	}

	// Telusuri mundur RetargetInterval-1 langkah dari parent, MENGIKUTI
	// ParentHash (bukan by-height), untuk sampai ke blok pertama window ini.
	firstBlock := parent
	for i := uint64(0); i < RetargetInterval-1; i++ {
		if firstBlock.Number.Uint64() == 0 {
			// Sampai genesis sebelum window penuh tertelusuri — fallback aman.
			return new(big.Int).Set(parent.Difficulty)
		}
		ancestor := chain.GetHeader(firstBlock.ParentHash, firstBlock.Number.Uint64()-1)
		if ancestor == nil {
			// Histori belum lengkap di node ini (mis. sedang sync) — fallback aman.
			return new(big.Int).Set(parent.Difficulty)
		}
		firstBlock = ancestor
	}

	actualTimespan := int64(parent.Time) - int64(firstBlock.Time)

	// Clamp ke [TargetTimespan/4, TargetTimespan*4] — persis logika di
	// CalculateNextWorkRequired() Bitcoin Core (mencegah swing difficulty
	// ekstrem akibat lonjakan/penurunan hashrate drastis atau manipulasi timestamp).
	minTimespan := TargetTimespan / 4
	maxTimespan := TargetTimespan * 4
	if actualTimespan < minTimespan {
		actualTimespan = minTimespan
	}
	if actualTimespan > maxTimespan {
		actualTimespan = maxTimespan
	}

	// newDifficulty = oldDifficulty * TargetTimespan / actualTimespan
	newDifficulty := new(big.Int).Mul(parent.Difficulty, big.NewInt(TargetTimespan))
	newDifficulty.Div(newDifficulty, big.NewInt(actualTimespan))

	if newDifficulty.Cmp(params.MinimumDifficulty) < 0 {
		newDifficulty.Set(params.MinimumDifficulty)
	}

	return newDifficulty
}
