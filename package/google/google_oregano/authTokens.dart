/// Authorize client with Spicerack and OAuth2.0

import 'dart:async';
import 'dart:io';
import 'dart:convert';

const String SPICERACK_AUTH =
    "https://www-googleapis-staging.sandbox.google.com/rpc";

const String separatorFlag = "--separator=";

main(List<String> args) {
  int now = new DateTime.now().millisecondsSinceEpoch;

  String separator = "&";
  // I don't want to import a 3rd party arguments parser for a simple script.
  // Allow the caller to switch between '&flag=' and ' --flag='
  if (args.length > 0 && args[0].startsWith(separatorFlag) ) {
    separator = args[0].substring(separatorFlag.length);
  }

  String serialNumber;
  ProcessResult rslt = Process.runSync("serial", []);
  serialNumber = rslt.stdout.trim();

  makeSignature(now).then((String signature) {
    getAuthCode(serialNumber, signature). then((authResponse) {
      Map json = JSON.decode(authResponse)['result'];
      var oauthClientId = json['oauthClientId'];
      var oauthAddress = json['oauthAddress'];
      var oauthClientSecret = json['oauthClientSecret'];
      getOAuth2Tokens(json['authorizationCode'], oauthAddress, oauthClientId,
          oauthClientSecret).then((tokens) {
        Map json = JSON.decode(tokens);
        print(
            "${separator}clientId=$oauthClientId"
            "${separator}clientSecret=$oauthClientSecret"
            "${separator}oauth2Url=$oauthAddress"
            "${separator}refreshToken=${json['refresh_token']}");
      });
    });
  });
}


/**
 * Returns the [now], signed with the local device certificate, and base64
 * encoded. See [getAuthCode]. This is equivalent to the following:
 *     $(date +%s | openssl rsautl -sign -inkey /etc/ssl/private/device.key | openssl base64 -A)
 */
Future<String> makeSignature(int now) {
  return Process.start("openssl",
      ["rsautl", "-sign", "-inkey", "/etc/ssl/private/device.key"])
        .then((Process sign) {
          sign.stdin.write("$now");
          sign.stdin.close();
          return Process.start("openssl", ["base64", "-A"])
              .then((Process base64) {
                sign.stdout.pipe(base64.stdin);
                return base64.stdout.transform(new Utf8Decoder()).join()
                   .then((String encOut) => encOut);
              });
        });
}


/**
 * Connect to Spicerack and request an authcode. Spicerack fetches the client
 * certificate from CARS based on the [serial] number and then verifies the
 * [signature] is valid.
 */
Future<String> getAuthCode(String serial, String signature) {
  var map = {
    "method": "spicerack.authcode.fetch",
    "apiVersion": "v1",
    "params": {
      "serialNumber": serial,
      "signature": signature,
    }
  };
  String authRequest = JSON.encode(map);
  return new HttpClient().postUrl(Uri.parse(SPICERACK_AUTH))
      .then((HttpClientRequest request) {
        request.headers.contentType = new ContentType("application", "json");
        request.write(authRequest);
        return request.close();
      }).then((HttpClientResponse response) =>
          response.transform(new Utf8Decoder()).join());
}



/**
 * Connect to the Oath2 service to get access tokens.
 */
Future<String> getOAuth2Tokens(String authCode, String authAddress,
    String authClientId, String authClientSecret) {
  String tokenRequest = "code=$authCode"
      "&client_id=$authClientId"
      "&client_secret=$authClientSecret"
      "&redirect_uri=oob"
      "&grant_type=authorization_code";
  return new HttpClient().postUrl(Uri.parse(authAddress))
      .then((HttpClientRequest request) {
        request.headers.contentType =
            new ContentType("application", "x-www-form-urlencoded");
        request.write(tokenRequest);
        return request.close();
      }).then((HttpClientResponse response) =>
          response.transform(new Utf8Decoder()).join());
}
