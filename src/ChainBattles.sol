// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

//Deployed at: 0x879da65c9D2fbb3925e5bA3fe3a456F4B60391ef

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256; // Nos da la posibilidad de convertir uint256 a strings y demas funciones interesantes
    using Counters for Counters.Counter;

    Counters.Counter private _tokensId;

    mapping(uint256 => uint256) public tokenIdtoLevels;

    constructor() ERC721("Chain Battles", "CBTLS") {}

    /**
     * @dev Para generar y actualizar la imagen SVG de nuestro NFT
     */
    function generateCharacter(uint256 tokenId) public view returns (string memory) {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">Warrior</text>',
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">Levels:',
            getLevels(tokenId),
            "</text>",
            "</svg>"
        );

        // Para poder visualizar la imagen en un navegador se necesita el svg en formato base64
        // Es por eso que lo devolvemos en ese formato
        return string(abi.encodePacked("data:image/svg+xml;base64,", Base64.encode(svg)));
    }

    /**
     * @dev Obtener el nivel actual de un NFT
     * @return Se devuelve en string ya que se usará en la funcion generateCharacter
     */
    function getLevels(uint256 tokenId) public view returns (string memory) {
        uint256 levels = tokenIdtoLevels[tokenId];
        // La función toString viene de la libreria Strings de OpenZeppelin
        return levels.toString();
    }

    /**
     * @dev Obtener el tokenURI de un NFT
     */
    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Chain Battles #',
            tokenId.toString(),
            '",',
            '"description": "Battles on chain",',
            '"image": "',
            generateCharacter(tokenId),
            '"',
            "}"
        );

        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(dataURI)));
    }

    /**
     * @dev Crear nuevo NFT, inicializar el nivel, setear el URI del token
     */
    function mint() public {
        _tokensId.increment();
        uint256 newItemId = _tokensId.current();
        _safeMint(msg.sender, newItemId);
        tokenIdtoLevels[newItemId] = 0;
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    /**
     * @dev para entrenar los NFTs y subirlos de nivel
     */
    function train(uint256 tokenId) public {
        // Se comprueba si existe el token y si es el dueño quien lo sube de nivel
        require(_exists(tokenId), "Use an existing token");
        require(ownerOf(tokenId) == msg.sender, "You must own this token");
        tokenIdtoLevels[tokenId] = tokenIdtoLevels[tokenId] + 1;
        // Actualizamos el tokenURI para que se vea reflejado en la imagen
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
}
