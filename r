// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ArtGallery is ERC721, Ownable {
    struct Artwork {
        string ipfsHash;
        address artist;
        uint256 price;
    }

    uint256 private _tokenCounter;
    mapping(uint256 => Artwork) private _artworks;

    event ArtworkCreated(uint256 indexed tokenId, address indexed artist, string ipfsHash, uint256 price);
    event ArtworkPurchased(uint256 indexed tokenId, address indexed buyer, uint256 price);

    constructor() ERC721("Artwork", "ART") {}

    function createArtwork(string memory ipfsHash, uint256 price) external {
        _tokenCounter++;
        uint256 tokenId = _tokenCounter;
        _mint(msg.sender, tokenId);
        _artworks[tokenId] = Artwork(ipfsHash, msg.sender, price);
        emit ArtworkCreated(tokenId, msg.sender, ipfsHash, price);
    }

    function purchaseArtwork(uint256 tokenId) external payable {
        require(_exists(tokenId), "Token does not exist");
        Artwork storage artwork = _artworks[tokenId];
        require(msg.value >= artwork.price, "Insufficient payment");
        address payable artist = payable(artwork.artist);
        artist.transfer(msg.value);
        _transfer(artist, msg.sender, tokenId);
        emit ArtworkPurchased(tokenId, msg.sender, msg.value);
    }

    function getArtwork(uint256 tokenId) external view returns (string memory ipfsHash, address artist, uint256 price) {
        require(_exists(tokenId), "Token does not exist");
        Artwork storage artwork = _artworks[tokenId];
        return (artwork.ipfsHash, artwork.artist, artwork.price);
    }
}
