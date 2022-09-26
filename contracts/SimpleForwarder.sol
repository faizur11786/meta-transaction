// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev Simple forwarder to be used together with an ERC2771 compatible contract. See {ERC2771Context}.
 *
 * Forwarder is mainly meant for testing, as it is missing features to be a good production-ready forwarder. This
 * contract does not intend to have all the properties that are needed for a sound forwarding system. A fully
 * functioning forwarding system with good properties requires more complexity. We suggest you look at other projects
 * such as the GSN which do have the goal of building a system like that.
 */

contract SimpleForwarder is EIP712, Ownable {

    using ECDSA for bytes32;

    struct ForwardRequest  {
        address from;
        address to;
        uint256 value;
        uint256 gas;
        uint256 nonce;
        bytes data;
    }

    bytes32 public constant _TYPE_HASH = keccak256("ForwardRequest(address from,address to,uint256 value,uint256 gas,uint256 nonce,bytes data)");

    mapping(address => uint256 ) public _nonces;

    event Invoke(address indexed from, address indexed to, uint256 value, uint256 gas, bytes data, uint256 timestamp);
    event Execute(address indexed relayer, address indexed from, address indexed to, uint256 value, uint256 gas, bytes data, uint256 timestamp);

    constructor () Ownable() EIP712("SimpleForwarder", "1") {}


    function getNonce(address from) public view returns(uint256){
        return _nonces[from];
    }
    

    function methodData(string memory functionWithSignature) public pure returns(bytes32 typeHash){
        typeHash = keccak256(abi.encodePacked(functionWithSignature));
    }

    function verify( ForwardRequest calldata req, bytes calldata signature ) public view returns(bool){
        address signer = _hashTypedDataV4(
            keccak256(abi.encode(
                _TYPE_HASH,
                req.from, 
                req.to, 
                req.value, 
                req.gas, 
                req.nonce, 
                keccak256(req.data)
            )))
            .recover(signature);
        return _nonces[req.from] == req.nonce && signer == req.from;
    }

    function execute( ForwardRequest calldata req, bytes calldata signature) public payable returns(bool){
        require(verify(req, signature), "Forwarder: signature does not match request");
        _nonces[req.from] = req.nonce + 1;
        (bool success,) = invoke(
            req.to,
            req.from,
            req.value,
            req.gas,
            req.data
        );
        emit Execute(_msgSender(), req.from, req.to, req.value, req.gas,  req.data, block.timestamp);
        return success;
    }
    function onlyOwnerExecute( ForwardRequest calldata req, bytes calldata signature) public payable onlyOwner returns(bool){
        require(verify(req, signature), "Forwarder: signature does not match request");
        _nonces[req.from] = req.nonce + 1;
        (bool success,) = invoke(
            req.to,
            req.from,
            req.value,
            req.gas,
            req.data
        );
        emit Execute(_msgSender(), req.from, req.to, req.value, req.gas,  req.data, block.timestamp);
        return success;
    }
    
    function invoke(address _target, address _from, uint256 _value, uint256 _gas, bytes calldata _data) internal returns(bool, bytes memory) {
        (bool success, bytes memory result) = _target.call{value:_value, gas:_gas}(
            abi.encodePacked(_data, _from)
        );
        // // Validate that the relayer has sent enough gas for the call.
        // // See https://ronan.eth.link/blog/ethereum-gas-dangers/
        if (gasleft() <= _gas / 63) {
            // We explicitly trigger invalid opcode to consume all gas and bubble-up the effects, since
            // neither revert or assert consume all gas since Solidity 0.8.0
            // https://docs.soliditylang.org/en/v0.8.0/control-structures.html#panic-via-assert-and-error-via-require
            /// @solidity memory-safe-assembly
            assembly {
                invalid()
            }
        }
        emit Invoke(_from, _target, _value, _gas, _data, block.timestamp);
        return (success, result);
    }
}