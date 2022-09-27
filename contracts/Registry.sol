// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.9;

// // Uncomment this line to use console.log
// // import "hardhat/console.sol";
// import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
// import { Forwarder } from "./Forwarder.sol";
// import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// interface IToken {
//     function mint(uint256 amount) external;
// }

// contract Registry is ERC2771Context {  
//   event Registered(address indexed who, string name);

//   mapping(address => string) public names;
//   mapping(string => address) public owners;

//   constructor(Forwarder forwarder) // Initialize trusted forwarder
//     ERC2771Context(address(forwarder)) {}

//   function register(string memory name) external {
//     require(owners[name] == address(0), "Name taken");
//     address owner = _msgSender(); // Changed from msg.sender
//     owners[name] = owner;
//     names[owner] = name;
//     emit Registered(owner, name);
//   }

//     function transferToken(address token, address to, uint256 amount) external {
//         IERC20(token).transfer(to, amount);
//     }
//     function transferFromToken(address token,address from, address to, uint256 amount) external {
//         IERC20(token).transferFrom(from, to, amount);
//     }
//     function mint(address token,uint256 amount) external {
//         IToken(token).mint(amount);
//     }
// }
