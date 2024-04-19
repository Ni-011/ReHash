// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/* This contract mints a new NFT
 It keeps track of all NFTs and creates new NFT's ID, mint it, set its tokenURI and return the id of this new token and 
 approves for the marketplace contract
*/

contract products is ERC721URIStorage {
    // total items and address of marketplace contract
    uint256 private _tokenIds;
    address marketplaceContractAddress;

    constructor (address _marketplaceContractAddress) ERC721 ("products", "ITEM") {
        marketplaceContractAddress = _marketplaceContractAddress;
    }

    // the mint fucntion to set new nftID, mint it and set approval
    function mint (string memory _tokenURI) public returns (uint256) {
        uint256 newItemId = _tokenIds++;

        _mint (msg.sender, newItemId);
        _setTokenURI(newItemId, _tokenURI);
        setApprovalForAll (marketplaceContractAddress, true);

        return newItemId;
    }
}