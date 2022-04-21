// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import "./stuff/ERC721.sol";
import "./stuff/Ownable.sol";
import "./stuff/StringsLib.sol";
import "./stuff/Base64.sol";
import "./stuff/ToHex.sol";

error MintPriceNotPaid();
error MaxSupply();
error NonExistentTokenURI();

contract SvgUnoptimized is ERC721, Ownable {
   using StringsLib for uint24;

    string public baseURI;
    uint256 public currentTokenId;
    uint256 public constant TOTAL_SUPPLY = 10_000;

    mapping(uint256 => attrib) public attributes;
    uint256[] public attrib_;
    // External contract
    Base64 base64;
    ToHex toHex;

    string Svg0 = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><rect width='100%' height='100%' fill='url(#pattern)' /><defs><linearGradient id='gradient' x1='100%' y1='10%' x2='0%' y2='10%'><stop offset='6.25%' stop-color='#";
    string Svg1 = "'/><stop offset='18.75%' stop-color='#";
    string Svg2 = "'/><stop offset='31.25%' stop-color='#";
    string Svg3 = "'/><stop offset='56.25%' stop-color='#";
    string Svg4 = "'/><stop offset='68.75%' stop-color='#";
    string Svg5 = "'/><stop offset='81.25%' stop-color='#";
    string Svg6 = "'/><stop offset='93.75%' stop-color='#";
    string Svg7 = "'/><stop offset='100%' stop-color='#";
    string Svg8 = "'/></linearGradient></defs><pattern id='pattern' x='0' y='0' width='400%' height='100%' patternUnits='userSpaceOnUse'><rect x='-150%' y='0' width='200%' height='100%' fill='url(#gradient)' transform='rotate(-65)'><animate attributeType='XML' attributeName='x' from='-150%' to='50%' dur='";
    string Svg9 = "ms' repeatCount='indefinite'/></rect><rect x='-350%' y='0' width='200%' height='100%' fill='url(#gradient)' transform='rotate(-65)'><animate attributeType='XML' attributeName='x' from='-350%' to='-150%' dur='";
    string Svg10 = "ms' repeatCount='indefinite'/></rect></pattern></svg>";
  

    struct attrib {
        uint24 color0;
        uint24 color1;
        uint24 color2;
        uint24 color3;
        uint24 color4;
        uint24 color5;
        uint24 color6;
        uint24 color7;
        uint24 speed;
    }
  
    attrib Attrib;

    constructor(
        string memory _name,
        string memory _symbol,
        Base64 _base64,
        ToHex _toHex
    ) ERC721(_name, _symbol) {
        base64 = _base64;
        toHex = _toHex;
       }

    function mintTo(address recipient) public payable returns (uint256) {
        uint256 newTokenId = ++currentTokenId;

        if (newTokenId > TOTAL_SUPPLY) {
            revert MaxSupply();
        }

        attributes[newTokenId].color0 = 0x87FFFE;
        attributes[newTokenId].color1 = 0x88FF89;
        attributes[newTokenId].color2 = 0xF8F58A;
        attributes[newTokenId].color3 = 0xEF696A;
        attributes[newTokenId].color4 = 0xF36ABA;
        attributes[newTokenId].color5 = 0xEF696A;
        attributes[newTokenId].color6 = 0xF8F58A;
        attributes[newTokenId].color7 = 0x88FF89;
        attributes[newTokenId].speed = 10000;

        _safeMint(recipient, newTokenId);
        return newTokenId;
    }

    
    function tokenURI(uint256 tokenId)
        public
        virtual
        view
        override
        returns (string memory)
    {
        if (ownerOf[tokenId] == address(0)) {
            revert NonExistentTokenURI();
        }
    string memory render1 = render_1(tokenId);
    string memory render2 = render_2(tokenId);
    string memory render3 = render_3(tokenId);
    
    string memory finalSvg = string(abi.encodePacked(
       render1,
       render2,
       render3
        ));

        string memory json = base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Rainbow", "description": "Unoptimized Rainbow on chain", "image": "data:image/svg+xml;base64,',
                        // Add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );
        
        string memory finalTokenUri = string(
        abi.encodePacked("data:application/json;base64,", json)
    );

        return finalTokenUri;
    }

    /// READ FUNCTIONS ///
   
    function render_1(uint256 tokenId) internal view returns (string memory) {
    
    string memory partialSvg;

    return partialSvg = string(abi.encodePacked(
        Svg0,
        toHex.uint24tohexstr(attributes[tokenId].color0),
        Svg1,
        toHex.uint24tohexstr(attributes[tokenId].color1),
        Svg2,
        toHex.uint24tohexstr(attributes[tokenId].color2),
        Svg3,
        toHex.uint24tohexstr(attributes[tokenId].color3)
          
    ));
    }

    function render_2(uint256 tokenId) internal view returns (string memory) {
    
    string memory partialSvg;
    
    return  partialSvg = string(abi.encodePacked(
        Svg4,
        toHex.uint24tohexstr(attributes[tokenId].color4),
        Svg5,
        toHex.uint24tohexstr(attributes[tokenId].color5),
        Svg6,
        toHex.uint24tohexstr(attributes[tokenId].color6),
        Svg7,
        toHex.uint24tohexstr(attributes[tokenId].color7)
    ));
    }

    function render_3(uint256 tokenId) internal view returns (string memory) {
    
    string memory partialSvg;
    
    return  partialSvg = string(abi.encodePacked(
        Svg8,
        attributes[tokenId].speed.toString(),
        Svg9,
        attributes[tokenId].speed.toString(),
        Svg10
    ));
    }
    
}