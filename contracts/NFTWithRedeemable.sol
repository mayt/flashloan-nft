// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTWithRedeemable is ERC721 {
    mapping(uint256 => address) private _tickets;

    constructor() ERC721("NFTWithRedeemable", "NFTR") {
    }

    function redeemTicket(uint256 id) external {
        require(ownerOf(id) == tx.origin, "Tx origin is not the owner of this tokemn");
        require(_tickets[id] == address(0), "Ticket has been claimed");
        _tickets[id] = tx.origin;
    }

    function ticketOwner(uint256 id) view external returns(address) {
        return _tickets[id];
    }

    function safeMint(address to, uint256 tokenId) external {
        _safeMint(to, tokenId);
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        return super.ownerOf(tokenId);
    }
}
