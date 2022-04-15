// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721FlashLoan {
    /**
     * @dev The premium to be charged to loan the NFT.
     * @param _tokenContract The addresses of the ERC721 contract to loan
     * @param _tokenId The NFT token id to loan
     * @return The amount of ether needed to complete the flashloan
     */
    function getPremiumForToken(
        address _tokenContract,
        uint256 _tokenId
    ) external view returns (uint256);

    /**
     * @dev Allows the msg.sender access to an approved NFT through a smartcontract within one transaction,
     * @param _facilitatorAddress The address of the contract implementing the IERC721FlashLoanFacilitator interface
     * @param _tokenContract The addresses of the ERC721 contract to loan
     * @param _tokenId The NFT token id to loan
     * @param _params Variadic packed params to pass to the receiver as extra information
     **/
    function flashLoan( address _facilitatorContract, address _tokenContract, uint256 _tokenId, bytes calldata _params) external payable;
}
