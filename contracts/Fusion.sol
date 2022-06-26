/**
 * @title Fusion - Used to merge mnultiple NFTs to create a new
 * @author Diveristy - twitter.com/DiversityETH
 *
 * 8888b.  88 Yb    dP 88 88b 88 888888      db    88b 88    db    88""Yb  dP""b8 88  88 Yb  dP
 *  8I  Yb 88  Yb  dP  88 88Yb88 88__       dPYb   88Yb88   dPYb   88__dP dP   `" 88  88  YbdP
 *  8I  dY 88   YbdP   88 88 Y88 88""      dP__Yb  88 Y88  dP__Yb  88"Yb  Yb      888888   8P
 * 8888Y"  88    YP    88 88  Y8 888888   dP""""Yb 88  Y8 dP""""Yb 88  Yb  YboodP 88  88  dP
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

import "hardhat/console.sol";

contract Fusion is ERC721, ERC721Enumerable, ERC721Burnable, Ownable, ERC1155Holder {
	using ECDSA for bytes32;
	using Strings for uint256;

	struct FusionToken {
		string uri;
		uint[] tokens;
	}
	mapping(uint256 => FusionToken) public tokenStorage;
	address private _signer;
	address private _pollyContract;

	constructor(address pollyContract) ERC721("Fusion", "FUSE") {
		_pollyContract = pollyContract;
	}

	modifier canChangeUri(uint256[] memory tokens, string calldata ipfs_uri, bytes calldata signature) {
		require(_signer == keccak256(abi.encodePacked(
			msg.sender,
			tokens,
			ipfs_uri
		)).toEthSignedMessageHash().recover(signature), "Not approved URI");

		_;
	}

	modifier requirePollyApproval() {
		require(IERC1155(_pollyContract).isApprovedForAll(msg.sender, address(this)), "Not approved to wrap");

		_;
	}

	modifier requirePollyOwnership(uint256[] memory tokens) {
		uint tokenAmount = tokens.length;
		for(uint i; i < tokenAmount; i++) {
			require(IERC1155(_pollyContract).balanceOf(msg.sender, tokens[i]) > 0, string(abi.encodePacked("Do not own token id: ", tokens[i].toString())));
		}

		_;
	}

	function setPollyContract(address pollyContract) public onlyOwner {
		_pollyContract = pollyContract;
	}

	function setSigner(address signer) public onlyOwner {
		_signer = signer;
	}

	function wrap(uint256[] calldata tokens, string calldata ipfs_uri, bytes calldata signature) public canChangeUri(tokens, ipfs_uri, signature) requirePollyOwnership(tokens) requirePollyApproval() {
		captureTokens(tokens, msg.sender);
		uint256 tokenId = safeMint(msg.sender);

		tokenStorage[tokenId].uri    = ipfs_uri;
		tokenStorage[tokenId].tokens = tokens;
	}

	function unwrap(uint256 token_id) public {
		uint[] memory tokens = tokenStorage[token_id].tokens;

		super.burn(token_id);

		releaseTokens(tokens, msg.sender);

		delete tokenStorage[token_id];
	}

	// This could be way more efficient but I dont have time
	function updateWrap(uint256 token_id, uint256[] calldata tokens, string calldata ipfs_uri, bytes calldata signature) public {
		unwrap(token_id);
		wrap(tokens, ipfs_uri, signature);
	}

	function captureTokens(uint256[] calldata tokens, address addr) private {
		// If I had more time this would be better as a batch
		uint256 tokenLength = tokens.length;
		for(uint i; i < tokenLength; i++) {
			IERC1155(_pollyContract).safeTransferFrom(addr, address(this), tokens[i], 1, "");
		}
	}

	function releaseTokens(uint256[] memory tokens, address addr) private {
		// If I had more time this would be better as a batch
		uint256 tokenLength = tokens.length;
		for(uint i; i < tokenLength; i++) {
			IERC1155(_pollyContract).safeTransferFrom(address(this), addr, tokens[i], 1, "");
		}
	}

	function safeMint(address to) private returns (uint256) {
		uint256 tokenId = totalSupply() + 1;
		_safeMint(to, tokenId);

		return tokenId;
	}

	function walletOfOwner(address owner) public view returns (uint256[] memory) {
		uint256 tokenCount      = super.balanceOf(owner);
		uint256[] memory result = new uint256[](tokenCount);

		for(uint256 i = 0; i < tokenCount; i++) {
			result[i] = super.tokenOfOwnerByIndex(owner, i);
		}
		return result;
	}

	// The following functions are overrides required by Solidity.
	function tokenURI(uint256 tokenId) public  view override(ERC721) returns (string memory) {
		return tokenStorage[tokenId].uri;
	}

	function _beforeTokenTransfer(address from, address to, uint256 tokenId)
		internal
		override(ERC721, ERC721Enumerable)
	{
		super._beforeTokenTransfer(from, to, tokenId);
	}

	function supportsInterface(bytes4 interfaceId)
		public
		view
		override(ERC721, ERC721Enumerable, ERC1155Receiver)
		returns (bool)
	{
		return super.supportsInterface(interfaceId);
	}
}