//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Polly is Ownable, ERC1155 {
    uint256 public constant FIRE_POLLY = 0;
    uint256 public constant WATER_POLLY = 1;
    uint256 public constant BOARDS = 2;
    uint256 public constant WEAPON = 3;
    uint256 public constant HEADBAND = 4;
    string public baseUri;

    constructor(string memory _uri) ERC1155(_uri) {
        _mint(msg.sender, FIRE_POLLY, 1, "");
        _mint(msg.sender, WATER_POLLY, 1, "");
        _mint(msg.sender, BOARDS, 1, "");
        _mint(msg.sender, WEAPON, 1, "");
        _mint(msg.sender, HEADBAND, 1, "");

        baseUri = _uri;
    }

    modifier onlyUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    function mintFirePolly() public payable onlyUser {
        _mint(msg.sender, FIRE_POLLY, 1, "");
    }

    function mintWaterPolly() public payable onlyUser {
        _mint(msg.sender, WATER_POLLY, 1, "");
    }

    function mintBoard() public payable onlyUser {
        _mint(msg.sender, BOARDS, 1, "");
    }

    function mintWeapon() public payable onlyUser {
        _mint(msg.sender, WEAPON, 1, "");
    }

    function mintHeadband() public payable onlyUser {
        _mint(msg.sender, HEADBAND, 1, "");
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        require(exists(tokenId), "Nonexistent token");
        return bytes(baseUri).length != 0 ? string(abi.encodePacked(baseUri, tokenId.toString(), '.json')) : '';
    }

    function setUri(string memory uri) external onlyOwner {
        baseUri = uri;
    }
}
