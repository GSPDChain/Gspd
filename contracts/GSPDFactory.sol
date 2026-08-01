// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./GSPDPair.sol";

contract GSPDFactory {
    address public feeTo; // if set, receives 1/6 of the 0.3% fee (0.05%) as protocol revenue — optional
    address public feeToSetter;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint256 pairIndex);

    constructor(address _feeToSetter) {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view returns (uint256) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, "GSPD: IDENTICAL_ADDRESSES");
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "GSPD: ZERO_ADDRESS");
        require(getPair[token0][token1] == address(0), "GSPD: PAIR_EXISTS");

        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        pair = address(new GSPDPair{salt: salt}());
        GSPDPair(pair).initialize(token0, token1);

        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in both directions
        allPairs.push(pair);

        emit PairCreated(token0, token1, pair, allPairs.length - 1);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, "GSPD: FORBIDDEN");
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, "GSPD: FORBIDDEN");
        feeToSetter = _feeToSetter;
    }
}
