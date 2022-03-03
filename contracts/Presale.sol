// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Presale is ERC20Upgradeable, OwnableUpgradeable {
    using SafeMath for uint256;
    uint256 private subZeroTokenAmount = 4000000;
    uint256 public initialZeroTokenAmount;
    uint256 private startTime;
    bytes32 public MerkleRoot;
    mapping (address => uint256) public SZtokenList;
    mapping (address => uint256) public StableCoinList1;        // for round 1
    mapping (address => uint256) public StableCoinList2;        // for round 2

    event Sold(uint256 indexed amount);

    constructor() public {
        __Ownable_init_unchained();
    }

    modifier isValidMerkleProof(bytes32[] calldata merkleProof, bytes32 root) {
        require(
            (block.timestamp > startTime.add(12 hours) && block.timestamp < startTime.add(24 hours)) ||
                ((block.timestamp > startTime && block.timestamp <= startTime.add(12 hours)) &&
                    MerkleProof.verify(
                        merkleProof,
                        root,
                        keccak256(abi.encodePacked(msg.sender))
                    )),
            "Address does not exist in list"
        );
        _;
    }

    function setStart() public onlyOwner {
        startTime = block.timestamp;
    }

    function getBalanceOfSubZeroToken() public view returns (uint256) {
        return subZeroTokenAmount;
    }

    function buy(
        uint256 _stableCoinAmount,
        uint256 _zeroCoinAmount,
        address StableCoin,
        bytes32[] calldata merkleProof
    ) external isValidMerkleProof(merkleProof, MerkleRoot) {
        require(
            block.timestamp > startTime &&
                block.timestamp < startTime + 24 hours,
            "Time Expired!"
        );
        require(_stableCoinAmount > 0, "Invalid amount");
        uint256 userBalance = IERC20(StableCoin).balanceOf(msg.sender);
        require(
            userBalance >= _stableCoinAmount,
            "Not enough funds in your wallet"
        );
        require(
            subZeroTokenAmount >= _zeroCoinAmount,
            "Not enough SubZero token"
        );

        subZeroTokenAmount = subZeroTokenAmount.sub(_zeroCoinAmount);

        SZtokenList[msg.sender] = SZtokenList[msg.sender].add(_zeroCoinAmount);

        if((block.timestamp > startTime && block.timestamp < startTime.add(12 hours))) {
            // if stable coin amount is exceed in round1
            require(StableCoinList1[msg.sender].add(_stableCoinAmount) <= 25000 * (10 ** 9), "you already bought up to 25K in Round1");
            StableCoinList1[msg.sender] = StableCoinList1[msg.sender] + _stableCoinAmount;
        }

        // if stable coin amount is exceed in round2
        if((block.timestamp > startTime.add(12 hours) && block.timestamp < startTime.add(24 hours))) {
            require(StableCoinList2[msg.sender].add(_stableCoinAmount) <= 25000 * (10 ** 9), "you already bought up to 25K in Round2");
            StableCoinList2[msg.sender] = StableCoinList2[msg.sender] + _stableCoinAmount;
        }

        IERC20(StableCoin).transferFrom(
            msg.sender,
            address(this),
            _stableCoinAmount
        );
        emit Sold(subZeroTokenAmount);
    }

    function withdraw(address StableCoin) external onlyOwner {
        IERC20(StableCoin).transfer(
            msg.sender,
            IERC20(StableCoin).balanceOf(address(this))
        );
    }

    function setPresale(bytes32 merkleRoot, uint256 _amount) external onlyOwner {
        MerkleRoot = merkleRoot;
        startTime = block.timestamp;
        subZeroTokenAmount = _amount;
        initialZeroTokenAmount = _amount;
    }

    function getRound() public view returns (uint8) {
        if(block.timestamp > startTime && block.timestamp <= startTime.add(12 hours))
            return 1;
        else if(block.timestamp > startTime.add(12 hours) && block.timestamp < startTime.add(24 hours))
            return 2;
        else
            return 0;
    }
}
