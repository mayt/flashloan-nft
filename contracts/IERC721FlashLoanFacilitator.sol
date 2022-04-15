// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721FlashLoanFacilitator {
    /**
     * @dev Receive a flash loan. Must return the borrowed token before returning.
     * @param _tokenContract The addresses of the ERC721 contract to loan
     * @param _tokenId The NFT token id to loan
     * @param _lender The original owner of the NFT
     * @param _premium The additional amount of tokens to repay.
     * @param _params Variadic packed params to pass to the receiver as extra information
     * @return True if the execution was successful
     */
    function executeOperation(
        address _tokenContract,
        uint256 _tokenId,
        address _lender,
        uint256 _premium,
        bytes calldata _params
    ) external returns (bool);
}
