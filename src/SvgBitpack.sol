// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import "./stuff/ERC721.sol";
import "./stuff/Ownable.sol";
import "./stuff/Strings.sol";

error MintPriceNotPaid();
error MaxSupply();
error NonExistentTokenURI();
error WithdrawTransfer();
error NotTheOwner();

contract SvgBitpack is ERC721, Ownable {

    string public baseURI;
    uint256 public currentTokenId;
    // Max supply can be 4,294,967,295 if using 8 attributes
    uint256 public constant TOTAL_SUPPLY = 10_000;

    mapping(uint256 => uint256) public attributes;

    // External contract
    Strings strings;

    constructor(
        string memory _name,
        string memory _symbol,
        Strings _strings
    ) ERC721(_name, _symbol) {
        strings = _strings;
    }


    function mintTo(address recipient) public payable returns (uint256) {
        uint256 newTokenId = ++currentTokenId;

        if (newTokenId > TOTAL_SUPPLY) {
            revert MaxSupply();
        }

        uint256 attributes_ = attributes[newTokenId];
    
        assembly {                                          // Colors
        attributes_ := add(attributes_, 0x87FFFE)           // 0
        attributes_ := add(attributes_, shl(24, 0x88FF89))  // 1
        attributes_ := add(attributes_, shl(48, 0xF8F58A))  // 2
        attributes_ := add(attributes_, shl(72, 0xEF696A))  // 3
        attributes_ := add(attributes_, shl(96, 0xF36ABA))  // 4
        attributes_ := add(attributes_, shl(120, 0xEF696A)) // 5
        attributes_ := add(attributes_, shl(144, 0xF8F58A)) // 6
        attributes_ := add(attributes_, shl(168, 0x88FF89)) // 7
        attributes_ := add(attributes_, shl(216, 10000)) // Speed | 10,000ms (milli)
        }

        attributes[newTokenId] = attributes_;

        _safeMint(recipient, newTokenId);
        return newTokenId;
    }

    /// VIEW TOKEN-URI 

    function tokenURI(uint256 tokenId)
        public
        virtual
        view
        override
        returns (string memory finalTokenURI)
    {
        if (ownerOf[tokenId] == address(0)) {
            revert NonExistentTokenURI();
        }
    
    string memory finalSvg = string(abi.encodePacked(
        render_1(tokenId),
        render_2(tokenId),
        render_3(tokenId)
        ));

    return finalTokenURI = string(abi.encodePacked("data:application/json;base64,", strings.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Rainbow", "description": "Bitpacked Rainbow on chain", "image": "data:image/svg+xml;base64,',
                        // Add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        strings.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
    )));

    }

    /// RENDER SVG FUNCTIONS ///
    // Render 4 attributes @ a time to avoid stack too deep
    function render_1(uint256 tokenId) internal view returns (string memory) {
        uint256 attributes_ = attributes[tokenId];
    
        // attributes
        uint24 a0;
        uint24 a1;
        uint24 a2;
        uint24 a3;

        string memory Svg0 = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><rect width='100%' height='100%' fill='url(#pattern)' /><defs><linearGradient id='gradient' x1='100%' y1='10%' x2='0%' y2='10%'><stop offset='6.25%' stop-color='#";
        string memory Svg1 = "'/><stop offset='18.75%' stop-color='#";
        string memory Svg2 = "'/><stop offset='31.25%' stop-color='#";
        string memory Svg3 = "'/><stop offset='56.25%' stop-color='#";

        string memory partialSvg;
        // Thank you v much Optimism team!
        assembly {
            a0 := and(
                    attributes_,
                    0x0000000000000000000000000000000000000000000000000000000000FFFFFF
                  
            )

            a1 := shr(
                24,
                and(
                    attributes_,
                    0x0000000000000000000000000000000000000000000000000000FFFFFF000000)
            )

            a2 := shr(
                48,
                and(
                    attributes_,
                    0x0000000000000000000000000000000000000000000000FFFFFF000000000000)
            ) 

            a3 := shr(
                72,
                and(
                    attributes_,
                    0x0000000000000000000000000000000000000000FFFFFF000000000000000000)
            )       

    }

    return partialSvg = string(abi.encodePacked(
        Svg0,
        strings.uint24tohexstr(a0),
        Svg1,
        strings.uint24tohexstr(a1),
        Svg2,
        strings.uint24tohexstr(a2),
        Svg3,
        strings.uint24tohexstr(a3)
    ));
    }

    function render_2(uint256 tokenId) internal view returns (string memory) {
        uint256 attributes_ = attributes[tokenId];
    
        // attributes
        uint24 a4;
        uint24 a5;
        uint24 a6;
        uint24 a7;

        string memory Svg4 = "'/><stop offset='68.75%' stop-color='#";
        string memory Svg5 = "'/><stop offset='81.25%' stop-color='#";
        string memory Svg6 = "'/><stop offset='93.75%' stop-color='#";
        string memory Svg7 = "'/><stop offset='100%' stop-color='#";

        string memory partialSvg;
        // Thank you v much Optimism team!
        assembly {
           
            a4 := shr(
                96,
                and(
                    attributes_,
                    0x0000000000000000000000000000000000FFFFFF000000000000000000000000)
            )       

            a5 := shr(
                120,
                and(
                    attributes_,
                    0x0000000000000000000000000000FFFFFF000000000000000000000000000000)
            ) 

            a6 := shr(
                144,
                and(
                    attributes_,
                    0x0000000000000000000000FFFFFF000000000000000000000000000000000000)
            ) 

            a7 := shr(
                168,
                and(
                    attributes_,
                    0x0000000000000000FFFFFF000000000000000000000000000000000000000000)
            )       
    }

    return partialSvg = string(abi.encodePacked(
        Svg4,
        strings.uint24tohexstr(a4),
        Svg5,
        strings.uint24tohexstr(a5),
        Svg6,
        strings.uint24tohexstr(a6),
        Svg7,
        strings.uint24tohexstr(a7)
    ));
    }

    function render_3(uint256 tokenId) internal view returns (string memory partialSvg) {
        uint256 attributes_ = attributes[tokenId];
        uint24 speed;

        string memory Svg8 = "'/></linearGradient></defs><pattern id='pattern' x='0' y='0' width='400%' height='100%' patternUnits='userSpaceOnUse'><rect x='-150%' y='0' width='200%' height='100%' fill='url(#gradient)' transform='rotate(-65)'><animate attributeType='XML' attributeName='x' from='-150%' to='50%' dur='";
        string memory Svg9 = "ms' repeatCount='indefinite'/></rect><rect x='-350%' y='0' width='200%' height='100%' fill='url(#gradient)' transform='rotate(-65)'><animate attributeType='XML' attributeName='x' from='-350%' to='-150%' dur='";
        string memory Svg10 = "ms' repeatCount='indefinite'/></rect></pattern></svg>";
  
        assembly {
     
            speed := shr(
                216,
                and(
                    attributes_,
                    0x0000FFFFFF000000000000000000000000000000000000000000000000000000
                )
            )
        }
    // returning strings like this reduces gas for funcs like tokenURI & render_3 but increases
    // gas by almost 100,000 if done elsewhere.
    return partialSvg = string(abi.encodePacked(
        Svg8,
        strings.toString(speed),
        Svg9,
        strings.toString(speed),
        Svg10
    ));
    }
}
