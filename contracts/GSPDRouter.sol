// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./interfaces/IGSPDFactory.sol";
import "./interfaces/IGSPDPair.sol";
import "./interfaces/IERC20.sol";
import "./libraries/GSPDLibrary.sol";
import "./libraries/TransferHelper.sol";

// Any wallet calls this contract directly (after approving it once per token).
// The Router itself never holds a balance between transactions — msg.sender
// signs every call, and tokens move straight from msg.sender to the Pair.
contract GSPDRouter {
    address public immutable factory;

    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, "GSPD: EXPIRED");
        _;
    }

    constructor(address _factory) {
        factory = _factory;
    }

    // ---------- LIQUIDITY ----------

    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin
    ) internal returns (uint256 amountA, uint256 amountB) {
        // create the pair on-demand if this is the first liquidity provider for it
        if (IGSPDFactory(factory).getPair(tokenA, tokenB) == address(0)) {
            IGSPDFactory(factory).createPair(tokenA, tokenB);
        }
        (uint256 reserveA, uint256 reserveB) = GSPDLibrary.getReserves(factory, tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint256 amountBOptimal = GSPDLibrary.quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, "GSPD: INSUFFICIENT_B_AMOUNT");
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint256 amountAOptimal = GSPDLibrary.quote(amountBDesired, reserveB, reserveA);
                require(amountAOptimal <= amountADesired, "GSPD: EXCESSIVE_A_AMOUNT");
                require(amountAOptimal >= amountAMin, "GSPD: INSUFFICIENT_A_AMOUNT");
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external ensure(deadline) returns (uint256 amountA, uint256 amountB, uint256 liquidity) {
        (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        address pair = GSPDLibrary.pairFor(factory, tokenA, tokenB);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        liquidity = IGSPDPair(pair).mint(to);
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) public ensure(deadline) returns (uint256 amountA, uint256 amountB) {
        address pair = GSPDLibrary.pairFor(factory, tokenA, tokenB);
        TransferHelper.safeTransferFrom(pair, msg.sender, pair, liquidity); // send LP tokens back to the pair to be burned
        (uint256 amount0, uint256 amount1) = IGSPDPair(pair).burn(to);
        (address token0,) = GSPDLibrary.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, "GSPD: INSUFFICIENT_A_AMOUNT");
        require(amountB >= amountBMin, "GSPD: INSUFFICIENT_B_AMOUNT");
    }

    // ---------- SWAP ----------

    function _swap(uint256[] memory amounts, address[] memory path, address _to) internal {
        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = GSPDLibrary.sortTokens(input, output);
            uint256 amountOut = amounts[i + 1];
            (uint256 amount0Out, uint256 amount1Out) =
                input == token0 ? (uint256(0), amountOut) : (amountOut, uint256(0));
            address to = i < path.length - 2 ? GSPDLibrary.pairFor(factory, output, path[i + 2]) : _to;
            IGSPDPair(GSPDLibrary.pairFor(factory, input, output)).swap(amount0Out, amount1Out, to);
        }
    }

    // path lets a swap hop through multiple pools, e.g. GOLD -> USDT -> GSPD,
    // when there's no direct GOLD/GSPD pool.
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external ensure(deadline) returns (uint256[] memory amounts) {
        amounts = GSPDLibrary.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, "GSPD: INSUFFICIENT_OUTPUT_AMOUNT");
        TransferHelper.safeTransferFrom(path[0], msg.sender, GSPDLibrary.pairFor(factory, path[0], path[1]), amounts[0]);
        _swap(amounts, path, to);
    }

    // ---------- VIEWS (used by the backend / DEX frontend for quotes) ----------

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts) {
        return GSPDLibrary.getAmountsOut(factory, amountIn, path);
    }
}
