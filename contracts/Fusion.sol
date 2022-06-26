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

import "hardhat/console.sol";

contract Fusion is ERC721, ERC721Enumerable, ERC721Burnable, Ownable {
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
		uint tokenAmount = tokens.length;

		require(_signer == keccak256(abi.encodePacked(
			msg.sender,
			tokens,
			ipfs_uri
		)).toEthSignedMessageHash().recover(signature), "Not approved URI");

		uint baseModelCount = 0;
		for(uint i; i < tokenAmount; i++) {
			require(IERC1155(_pollyContract).balanceOf(msg.sender, tokens[i]) > 0, string(abi.encodePacked("Do not own token id: ", tokens[i].toString())));
		}

		require(IERC1155(_pollyContract).isApprovedForAll(msg.sender, address(this)), "Not approved to wrap");

		_;
	}

	function setPollyContract(address pollyContract) public onlyOwner {
		_pollyContract = pollyContract;
	}

	function setSigner(address signer) public onlyOwner {
		_signer = signer;
	}

	function wrap(uint256[] calldata tokens, string calldata ipfs_uri, bytes calldata signature) public canChangeUri(tokens, ipfs_uri, signature) {
		// verify tokens, ipfs uri in signature
		// move tokens into contract - captureTokens
		// mint token
		// save token state for wrapped tokens
	}

	function unwrap(uint256 token_id) public {
		// burn token
		// release tokens - releaseTokens
		// delete storage
	}

	function updateWrap(uint256[] calldata wrapTokens, uint256[] calldata unwrapTokens) public {
		// verify tokens, ipfs uri in sig
		// move tokens into contract - captureTokens
		// release tokens - releaseTokens
		// update storage state
	}

	function captureTokens(uint256[] calldata tokens, address addr) private {
		// move tokens into contract
	}

	function releaseTokens(uint256[] calldata tokens, address addr) private {
		// move tokens out of contract into wallet
	}

	function safeMint(address to) private returns (uint256) {
		uint256 tokenId = totalSupply() + 1;
		_safeMint(to, tokenId);
		/* TODO: Save wrapped tokens and uri */

		return tokenId;
	}

	// The following functions are overrides required by Solidity.
	function _beforeTokenTransfer(address from, address to, uint256 tokenId)
		internal
		override(ERC721, ERC721Enumerable)
	{
		super._beforeTokenTransfer(from, to, tokenId);
	}

	function supportsInterface(bytes4 interfaceId)
		public
		view
		override(ERC721, ERC721Enumerable)
		returns (bool)
	{
		return super.supportsInterface(interfaceId);
	}
}