# Flashloan with NFTs

A proof of concept project to show how do a flashloan with NFTs. Loosely based on [EIP-3156](https://eips.ethereum.org/EIPS/eip-3156)

## Design Requirements
1. The owner of the NFT effectively keeps their NFT in their wallet at all times
2. The owner can set and  is paid a premium when anyone uses their NFT
3. Premiums are settled in ether
4. A borrower can temporary move a token to their wallet

## Interfaces
###[IERC721FlashLoanFacilitator.sol](./contracts/IERC721FlashLoanFacilitator.sol)
```solidity
interface IERC721FlashLoanFacilitator {
    /**
     * @dev Receive a flash loan. Must return the borrowed token before returning.
     * @param _tokenContract The addresses of the ERC721 contract to loan
     * @param _tokenId The NFT token id to loan
     * @param _owner The original owner of the token
     * @param _premium The additional amount of tokens to repay.
     * @param _params Variadic packed params to pass to the receiver as extra information
     * @return True if the execution was successful
     */
    function executeOperation(
        address _tokenContract,
        uint256 _tokenId,
        address _owner,
        uint256 _premium,
        bytes calldata _params
    ) external returns (bool);
}
```

###[IERC721FlashLoan.sol](./contracts/IERC721FlashLoan.sol)
```solidity
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
```

## Workflow

### Setup
1. Deploy the flashloan contract like [FlashLoanNFT.sol](./contracts/FlashLoanNFT.sol)

### For the NFT lender
1. NFT lender calls the NFT contract's `setApprovalForAll({flashloan_contract_address}, true)`
2. NFT lender calls the flashloan contract's `approveForFlashLoans` method and sets a premium for each NFT he/she wants to enable for flashloan.

### For the NFT borrower
1. Deploy a facilitator contract like [NFTWithRedeemableFlashLoanFacilitator](./contracts/NFTWithRedeemableFlashLoanFacilitator.sol)
2. Call NFT contract's `setApprovalForAll({facilitators_contract_address}, true)`
3. Call the flashloan contract's `flashloan` method with the necessary premium
4. Profit!

## Installing
```cmd
npm install
```

## Testing
```cmd
npm test
```
