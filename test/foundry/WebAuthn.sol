// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../../contracts/webauthn/WebAuthn.sol"; // Update path to your WebAuthn.sol contract
import "../../contracts/webauthn/Base64URL.sol"; // Update path to your WebAuthn.sol contract

contract WebAuthnTest is Test {
    using Base64 for bytes; // Make sure Base64Url is available

    WebAuthn.WebAuthnAuth auth;
    bytes challenge;
    bytes authenticatorData;
    uint256 x;
    uint256 y;
    uint256 r;
    uint256 s;

    function setUp() public {
        challenge = abi.encode(
            0x9a33416cfa2cbc041970765272785aec535255210c1fa2cec52a5a8f43d15638
        );
        x = 112934680721400888756244364470885836040126922266956169695542799226566146555623;
        y = 84500962549362344870436172480931662121305316444424964628544230017129558392159;
        auth = WebAuthn.WebAuthnAuth({
            authenticatorData: hex"49960de5880e8c687434170f6476605b8fe4aeb9a28632c7995cf3ba831d97631d00000000",
            clientDataJSON: string.concat(
                '{"type":"webauthn.get","challenge":"mjNBbPosvAQZcHZScnha7FNSVSEMH6LOxSpaj0PRVjg","origin":"http://localhost:3000","crossOrigin":false}'
            ),
            challengeIndex: 23,
            typeIndex: 1,
            r: 9829648776368866095820243961416192569890044585633652914565855611705717589926,
            s: 38110418766458631384199818057529768744153483448973426380493509806046065377515
        });
    }

    function testVerifyWebAuthn() public {
        bool result = WebAuthn.verify(challenge, auth, x, y);
        assertTrue(result, "WebAuthn verification failed");
    }
}
