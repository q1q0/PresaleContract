// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract Presale is ERC20Upgradeable, OwnableUpgradeable {
    address public SubZero;

    event Sold(uint256 amount);
    constructor(address _subZero) public {
        SubZero = _subZero;
        __Ownable_init_unchained();
    }

    // function setStableCoin (address token) public {
    //     StableCoin = token;
    // }

    function getBalanceOfSubZeroToken() public view returns (uint256) {
        return IERC20(SubZero).balanceOf(address(this));
    }

    function sell(uint256 _stalbelCoinAmount, uint256 _zeroCoinAmount, address StableCoin) external {
        require(_stalbelCoinAmount > 0, "Invalid amount");
        uint256 userBalance = IERC20(StableCoin).balanceOf(msg.sender);
        require(userBalance >= _stalbelCoinAmount, "Not enough funds in your wallet");

        IERC20(SubZero).transfer(msg.sender, _zeroCoinAmount);
        IERC20(StableCoin).transferFrom(msg.sender, address(this), _stalbelCoinAmount);
        emit Sold(IERC20(SubZero).balanceOf(address(this)));
    }

    function withdraw(address StableCoin) external onlyOwner {
        IERC20(StableCoin).transfer(msg.sender, IERC20(StableCoin).balanceOf(address(this)));
    }
}