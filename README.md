This is a simple app that uses [SoundCloud][soundcloud] API to authenticate and fetch user's affiliated tracks. Track names & waveforms are displayed in table view.

Acknowledgements:

* [ReactiveCocoa][rac] — reactive stuff and bindings;
* [AFNetworking][afn] — best iOS/Mac networking framework ever;
* [GROAuth2SessionManager][afn_oauth2] — OAuth 2 implementation for AFNetworking 2, slightly [modified][afn_oauth2_mod] to be more compatible;
* [Mantle][mantle] — models & JSON mapping;
* [OHHTTPStubs][ohhttpstubs] — network request stubbing for tests;

[soundcloud]: http://soundcloud.com/
[rac]: https://github.com/ReactiveCocoa/ReactiveCocoa/
[afn]: https://github.com/AFNetworking/AFNetworking
[afn_oauth2]: https://github.com/gabrielrinaldi/GROAuth2SessionManager/
[afn_oauth2_mod]: https://github.com/corristo/GROAuth2SessionManager
[mantle]: https://github.com/github/Mantle
[ohhttpstubs]: https://github.com/AliSoftware/OHHTTPStubs
