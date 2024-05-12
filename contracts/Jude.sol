// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Jude is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol){
        _mint(msg.sender, 1000000000 * 10 ** 18);
    }
}

contract JudeSwap {
    string[] public tokens = ["JUDE"];

        // map to maintain the tokens and its instances
    mapping(string => ERC20) public tokenInstanceMap;

    // 1 OMNI = 0.001 eth
    //10000000000000000 wei = 0.01Eth
    uint256 ethValue = 1000000000000000;

    constructor() {
        for (uint i=0; i<tokens.length; i++) {
            Jude token = new Jude(tokens[i], tokens[i]);
            tokenInstanceMap[tokens[i]] = token;
        }
    }

    function getBalance(string memory tokenName, address _address) public view returns (uint256) {
        return tokenInstanceMap[tokenName].balanceOf(_address);
    }

    function getName(string memory tokenName) public view returns (string memory) {
        return tokenInstanceMap[tokenName].name();
    }

    function getTokenAddress(string memory tokenName) public view returns (address) {
        return address(tokenInstanceMap[tokenName]);
    }

    function swapEthToToken(string memory tokenName) public payable returns (uint256) {
        uint256 inputValue = msg.value;
        uint256 outputValue = (inputValue / ethValue) * 10 ** 18; // Convert to 18 decimal places
        require(tokenInstanceMap[tokenName].transfer(msg.sender, outputValue));
        return outputValue;
    }

    function swapTokenToEth(string memory tokenName, uint256 _amount) public returns (uint256) {
        // Convert the token amount (ethValue) to exact amount (10)
        uint256 exactAmount = _amount / 10 ** 18;
        uint256 ethToBeTransferred = exactAmount * ethValue;
        require(address(this).balance >= ethToBeTransferred, "Dex is running low on balance.");

        payable(msg.sender).transfer(ethToBeTransferred);
        require(tokenInstanceMap[tokenName].transferFrom(msg.sender, address(this), _amount));
        return ethToBeTransferred;
    }

    function getEthBalance() public view returns (uint256) {
        return address(this).balance;
    }
}