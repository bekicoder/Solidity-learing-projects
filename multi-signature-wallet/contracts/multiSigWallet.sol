// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Gas Optimized MultiSig Wallet
contract MultiSigWallet {

    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    error NotOwner();
    error InvalidSignature();
    error TxFailed();
    error AlreadyExecuted();

    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    address[] public owners;
    mapping(address => bool) public isOwner;

    uint256 public immutable threshold;
    uint256 public nonce;

    mapping(bytes32 => bool) public executed;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address[] memory _owners, uint256 _threshold) {
        require(_owners.length >= _threshold, "Invalid threshold");

        for (uint i; i < _owners.length; ) {
            address owner = _owners[i];
            isOwner[owner] = true;
            owners.push(owner);

            unchecked { i++; }
        }

        threshold = _threshold;
    }

    /*//////////////////////////////////////////////////////////////
                           HASH TRANSACTION
    //////////////////////////////////////////////////////////////*/

    function getTxHash(
        address to,
        uint256 value,
        bytes calldata data,
        uint256 _nonce
    ) public view returns (bytes32) {

        return keccak256(
            abi.encodePacked(
                address(this),
                to,
                value,
                keccak256(data),
                _nonce,
                block.chainid
            )
        );
    }

    /*//////////////////////////////////////////////////////////////
                           EXECUTE TRANSACTION
    //////////////////////////////////////////////////////////////*/

    function execute(
        address to,
        uint256 value,
        bytes calldata data,
        bytes[] calldata signatures 
    ) external {

        bytes32 txHash = getTxHash(to, value, data, nonce);

        if (executed[txHash]) revert AlreadyExecuted();

        uint256 validSignatures;

        for (uint i; i < signatures.length; ) {

            address signer = recover(txHash, signatures[i]);

            if (!isOwner[signer]) revert InvalidSignature();

            validSignatures++;

            unchecked { i++; }
        }

        if (validSignatures < threshold) revert InvalidSignature();

        executed[txHash] = true;
        nonce++;

        (bool success,) = to.call{value: value}(data);

        if (!success) revert TxFailed();
    }

    /*//////////////////////////////////////////////////////////////
                         SIGNATURE RECOVERY
    //////////////////////////////////////////////////////////////*/

    function recover(bytes32 hash, bytes memory signature)
        internal
        pure
        returns (address signer)
    {

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature,32))
            s := mload(add(signature,64))
            v := byte(0,mload(add(signature,96)))
        }

        signer = ecrecover(hash, v, r, s);
    }

    /*//////////////////////////////////////////////////////////////
                                RECEIVE
    //////////////////////////////////////////////////////////////*/

    receive() external payable {}
}
