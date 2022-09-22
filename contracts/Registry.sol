// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import { Forwarder } from "./Forwarder.sol";


contract Registry is ERC2771Context {  
  event Registered(address indexed who, string name);

  mapping(address => string) public names;
  mapping(string => address) public owners;

  constructor(Forwarder forwarder) // Initialize trusted forwarder
    ERC2771Context(address(forwarder)) {
  }

  function register(string memory name) external {
    require(owners[name] == address(0), "Name taken");
    address owner = _msgSender(); // Changed from msg.sender
    owners[name] = owner;
    names[owner] = name;
    emit Registered(owner, name);
  }
}
