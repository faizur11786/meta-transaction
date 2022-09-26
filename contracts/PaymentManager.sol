// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
// import "@openzeppelin/contracts/metatx/MinimalForwarder.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SimpleForwarder} from "./SimpleForwarder.sol";


contract PaymentManager is ERC2771Context {  


    address public owner;
    mapping(address => bool) public isRelayer;

    event UnlockedAddress(address[] indexed tokens);
    event Registered(address indexed who, string name);
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 timestamp
    );
    event Call(address indexed from, address indexed to, bytes data, uint256 timestamp);
    event MultiCall(address indexed from, address[] indexed to, bytes[] data, uint256 timestamp);
    event EthDeposit(address indexed from, uint256 amount, uint256 timestamp);

    modifier onlyOwner() {
        require(_msgSender() == owner, "PM: caller is not the owner");
        _;
    }
    modifier onlyRelayer() {
        require(isRelayer[_msgSender()] == true, "PM: caller is not a relayer");
        _;
    }

    constructor(SimpleForwarder forwarder) // Initialize trusted forwarder
        ERC2771Context(address(forwarder)) {
        owner = _msgSender();
        isRelayer[_msgSender()] = true;
    }

    function transferOwnership(address newOwner) external onlyOwner returns (bool) {
        owner = newOwner;
        return true;
    }
    function addRelayer(address _rey) external onlyOwner returns (bool) {
        isRelayer[_rey] = true;
        return true;
    }

    function transfer(address token, address to, uint256 amount) public returns(bool)  {
        IERC20(token).transfer(to, amount);
        return true;
    }

    function transferFrom(address token, address to, uint256 amount) public returns(bool) {
        IERC20(token).transferFrom(_msgSender(), to, amount);
        return true;
    }

    function approve(address token, uint256 amount) public returns(bool) {
        IERC20(token).approve(address(this), amount);
        return true;
    }

    function unlockAddress(
        address[] memory tokens
    ) public returns(bool) {

        uint length = tokens.length;
        for(uint i = 0; i < length; i++) {
            IERC20(tokens[i]).approve(address(this), 1000000 * 1e18);
        }
        emit UnlockedAddress(tokens);
        return true;
    }

    function call(address _target, bytes calldata _data) public onlyRelayer returns (bool, bytes memory) {
        require(_msgSender() == owner || _msgSender() == address(this), "Not owner");
        (bool success, bytes memory result) = _target.call(_data);
        require(success, "call failed");
        emit Call(_msgSender(), _target, _data, block.timestamp);
        return (success, result);
    }

    function multiCall(address[] calldata _targets, bytes[] calldata _data) public onlyRelayer returns (bool[] memory, bytes[] memory) {
        require(_msgSender() == owner, "Not owner");
        require(_targets.length == _data.length, "length not match");
        bool[] memory success = new bool[](_targets.length);
        bytes[] memory result = new bytes[](_targets.length);
        for (uint256 i = 0; i < _targets.length; i++) {
            (success[i], result[i]) = call(_targets[i], _data[i]);
            require(success[i], "call failed");
        }
        emit MultiCall(_msgSender(), _targets, _data, block.timestamp);
        return (success, result);
    }
}
