// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.9;

// // Uncomment this line to use console.log
// // import "hardhat/console.sol";
// import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
// import { Forwarder } from "./Forwarder.sol";
// import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// contract Token is ERC20 {
//     event Mint(
//         address indexed to,
//         uint256 amount
//     );

//     constructor() ERC20("Meta Token", "MTk") {
//         _mint(_msgSender(), 1000000000000000000000000);
//     }

//     function mint(uint256 amount) external {
//         _mint(_msgSender(), amount);
//         emit Mint(_msgSender(), amount);
//     }

//     function decimals() public pure virtual override returns (uint8) {
//         return 18;
//     }
// }
