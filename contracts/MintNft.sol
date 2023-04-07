// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.18;

import "@routerprotocol/router-crosstalk-utils/contracts/CrossTalkUtils.sol";
import "evm-gateway-contract/contracts/ICrossTalkApplication.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MintNft is ERC721, ICrossTalkApplication {
    address public admin;
    address public gatewayContract;
    uint64 public destGasLimit;

    mapping(uint64 => mapping(string => bytes)) public ourContractOnChains;

    struct TransferParams {
        uint256 nftId;
        bytes recipient;
    }

    constructor(
        address payable _gatewayAddress,
        uint64 _destGasLimit,
        uint256 _tokenId
    ) ERC721("CrossERC721", "cerc721") {
        gatewayContract = _gatewayAddress;
        destGasLimit = _destGasLimit;
        admin = msg.sender;
        _mint(msg.sender, _tokenId);
    }

    function setContractOnChain(
        uint64 chainType,
        string memory chainId,
        address contractAddress
    ) external {
        require(msg.sender == admin, "only admin");
        ourContractOnChains[chainType][chainId] = CrossTalkUtils.toBytes(
            contractAddress
        );
    }

    function transferCrossChain(
        uint64 chainType,
        string memory chainId,
        uint64 expiryDurationInSeconds,
        uint64 destGasPrice,
        uint256 _nftId,
        address _recepient
    ) public payable {
        require(
            keccak256(ourContractOnChains[chainType][chainId]) !=
                keccak256(CrossTalkUtils.toBytes(address(0))),
            "ERR:CROSS_CHAIN_CONTRACT_NOT_SET"
        );

        require(_ownerOf(_nftId) == msg.sender, "ERR:NOT_OWNER");

        _burn(_nftId);

        bytes memory payload = abi.encode(
            TransferParams(_nftId, CrossTalkUtils.toBytes(_recepient))
        );
        uint64 expiryTimestamp = uint64(block.timestamp) +
            expiryDurationInSeconds;

        Utils.DestinationChainParams memory destChainParams = Utils
            .DestinationChainParams(
                destGasLimit,
                destGasPrice,
                chainType,
                chainId,
                "0x"
            );
        Utils.RequestArgs memory requestArgs = Utils.RequestArgs(
            expiryTimestamp,
            false
        );

        CrossTalkUtils.singleRequestWithoutAcknowledgement(
            address(gatewayContract),
            requestArgs,
            destChainParams,
            ourContractOnChains[chainType][chainId],
            payload
        );
    }

    function handleRequestFromSource(
        bytes memory srcContractAddress,
        bytes memory payload,
        string memory srcChainId,
        uint64 srcChainType
    ) external override returns (bytes memory) {
        require(msg.sender == gatewayContract, "ERR:NOT_GATEWAY_CONTRACT");
        require(
            keccak256(srcContractAddress) ==
                keccak256(ourContractOnChains[srcChainType][srcChainId]),
            "ERR:CONTRACT_NOT_FOUND"
        );

        TransferParams memory transferParams = abi.decode(
            payload,
            (TransferParams)
        );
        _mint(
            CrossTalkUtils.toAddress(transferParams.recipient),
            transferParams.nftId
        );

        return "";
    }

    function handleCrossTalkAck(
        uint64 eventIdentifier,
        bool[] memory execFlags,
        bytes[] memory execData
    ) external view override {}
}
