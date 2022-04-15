// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC721FlashLoanFacilitator.sol";
import "./IERC721FlashLoan.sol";
import "./NFTWithRedeemable.sol";

contract NFTWithRedeemableFlashLoanFacilitator is IERC721FlashLoanFacilitator {
    function executeOperation(
        address _tokenContract,
        uint256 _tokenId,
        address _lender,
        uint256,
        bytes calldata
    ) external returns (bool) {
        NFTWithRedeemable redeemable = NFTWithRedeemable(_tokenContract);
        // use the loaned NFT
        redeemable.redeemTicket(_tokenId);

        // return the NFT back to the owner
        redeemable.safeTransferFrom(tx.origin, _lender, _tokenId);
        return true;
    }
}
