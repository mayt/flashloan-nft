// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IERC721FlashLoanFacilitator.sol";
import "./IERC721FlashLoan.sol";

contract FlashLoanNFT is IERC721FlashLoan {
    // maps nftContract -> owner -> tokenid -> premium amount
    mapping(address => mapping(address => mapping(uint256 => uint256)))
        public contractNFTPremium;

    event ERC721FlashLoan(
        address facilitator,
        address sender,
        address erc721Contract,
        uint256 tokenId,
        uint256 premium
    );

    function getPremiumForToken(address erc721Contract, uint256 tokenId)
        external
        view
        returns (uint256)
    {
        return contractNFTPremium[erc721Contract][msg.sender][tokenId];
    }

    function approveForFlashLoans(
        address erc721Contract,
        uint256 tokenId,
        uint256 premium
    ) external {
        require(erc721Contract != address(0), "Contract is empty address");
        require(premium > 0, "Premium must be greater than 0");
        IERC721 _contract = IERC721(erc721Contract);
        require(
            _contract.isApprovedForAll(msg.sender, address(this)),
            "Owner has not set approval for all for this contract"
        );
        require(_contract.ownerOf(tokenId) == msg.sender, "Not owner of token");
        contractNFTPremium[erc721Contract][msg.sender][tokenId] = premium;
    }

    function revokeFromFlashLoans(address erc721Contract, uint256 tokenId)
        external
    {
        IERC721 _contract = IERC721(erc721Contract);
        address owner = _contract.ownerOf(tokenId);
        require(owner == msg.sender, "Not owner of token");
        contractNFTPremium[erc721Contract][owner][tokenId] = 0;
    }

    function flashLoan(
        address facilitatorAddress,
        address erc721Contract,
        uint256 tokenId,
        bytes calldata params
    ) external payable {
        IERC721 _contract = IERC721(erc721Contract);
        address _lender = _contract.ownerOf(tokenId);
        require(
            _contract.isApprovedForAll(_lender, address(this)),
            "Lender has not approved contract's setApprovedForAll"
        );

        uint256 premium = contractNFTPremium[erc721Contract][_lender][tokenId];
        require(premium > 0, "Token not approved for flashloan");
        require(msg.value >= premium, "Not enough premium sent");

        // loan the nft
        _contract.safeTransferFrom(_lender, msg.sender, tokenId);

        // perform flash loan actions
        IERC721FlashLoanFacilitator facilitator = IERC721FlashLoanFacilitator(
            facilitatorAddress
        );

        require(
            facilitator.executeOperation(
                erc721Contract,
                tokenId,
                _lender,
                premium,
                params
            ),
            "Execution failed"
        );

        // pay the premiums
        payable(_lender).transfer(premium);

        // confirm that the nft was returned
        require(_contract.ownerOf(tokenId) == _lender, "NFT was not returned to lender");

        emit ERC721FlashLoan(
            facilitatorAddress,
            msg.sender,
            erc721Contract,
            tokenId,
            premium
        );
    }
}
