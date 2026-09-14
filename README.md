# product-catalog-flutter

Neurogine Junior Mobile Developer technical assessment

# Stack

- **Flutter** 3.35.5 / **Dart** 3.9.2
- Packages: `http` (API calls), `google_fonts` (Poppins), `cupertino_icons`
- No external state-management package — plain `StatefulWidget` + `setState` (see [Architecture](#architecture--decisions) below for why)
- Tested on a physical Android device (Android 12, API 31) via `Run Without Debugging`

# How to run

1. Install the Flutter SDK (3.35.x or newer) and make sure `flutter doctor` is clean for your target platform.
2. Pick an Android or iOS device/emulator when prompted
    - I'm runing using android phone (Samsung S10)
        - On developer mode
        - Enable Usb Debugging
3. From the project root:
    - flutter pub get
    - flutter run / Run without debugging (not prompt)
4. To run the test suite: `flutter test`. To lint: `flutter analyze`.

# Features

- **Product list** — a scrollable grid with each product's thumbnail, title, and price (`home_screen.dart` + `product_card.dart`).
- **Pagination** — scroll near the bottom and the next page loads automatically using the `skip` param; it just stops quietly once everything's been fetched.
- **Product detail** — tap any product to see its full description, price, star rating, and an image gallery with a thumbnail strip to flip between photos.
- **Loading / error / empty / success states** — every screen that hits the network shows a spinner while loading, a retry button if it fails, a message when there's genuinely nothing to show, and the real content once it succeeds.
- **Debounced search** — typing in the search box waits ~500ms after you stop, then searches DummyJSON's `/products/search` endpoint directly (not just filtering what's already on screen).
- **Two layers** — a data layer (`core/repository`) that only knows about HTTP and JSON, and a presentation layer (`screens/`, `widgets/`) that only ever talks to the repository, never the network directly.

A few extras I added on top of the requirements: pull-to-refresh on the grid, loading/error placeholders on every product image, a star-rating badge on each card, sortable + "show more" paginated reviews and shipping info on the detail screen, and a scroll-to-top button once you've scrolled down a bit.

# Architecture & decisions

**Layers**: `core/repository` (`AppClient` + `AppRepository`) is the data layer — it knows about HTTP, DummyJSON's endpoints, and JSON parsing (via the `Product`/`ProductListResponse`/`Review` models in `screens/home/model/`), and exposes typed methods (`fetchProducts`, `fetchProductById`, `searchProducts`) that throw a single `ApiException` type. `screens/*` and `widgets/` are the presentation layer — they only ever talk to `AppRepository`, never to `http` directly.

**State management**: plain `StatefulWidget`/`setState`, not BLoC/Provider/Riverpod. Each screen owns its own local fetch-and-display state (`_products`, `_isLoading`, `_errorMessage`, etc.) and calls the repository directly. For an app this size — two screens, no state shared between them — a Bloc/Cubit layer would add event classes and stream plumbing without a matching increase in actual complexity. The trade-off: the fetch logic is coupled to the widget's lifecycle, so it isn't unit-testable independently of a widget test (see TODOs).

**Search — server-side, not client-side**: typing in the search box calls DummyJSON's `/products/search?q=...` endpoint (debounced 500ms) rather than filtering the already-loaded page client-side. Reasoning: the product catalog is paginated and much larger than what's loaded on screen at any moment, so a client-side filter would only ever search the ~20-40 items already fetched, not the whole catalog. Server-side search also reuses the exact same paginated response shape (`products`/`total`/`skip`/`limit`) as the list endpoint, so it plugs into the same pagination code path with no special-casing.

**Detail screen refetches by ID**: DummyJSON's list endpoint already returns full product objects (including `description`, `images`, `reviews`), so the detail screen could have just reused the tapped list item. Instead, `ProductDetailScreen` takes only a `productId` and calls `GET /products/{id}` itself. This was a deliberate choice to actually exercise the endpoint the assignment calls out explicitly, and it gives the detail screen its own genuine loading/error/retry states to demonstrate — at the cost of a redundant network call for data the app already had.

# AI usage disclosure

I used AI (Claude) for guidance and research, not to generate the core implementation. Specifically:

Structuring the `app_client` (API/HTTP layer) and `app_repository` (data layer) and how they integrate with each other
Understanding how to implement pagination logic on top of the skip/limit parameters used by the API

All architectural decisions, widget structure, and business logic were written and adapted by me. I can walk through and explain each part in the demo video.

# TODOs / Known limitations

- No unit tests yet for the repository/model layer (e.g. `Product.fromJson`, `AppClient` error mapping) — only one widget smoke test exists, and the fetch logic being coupled to widget state (see above) makes it harder to test in isolation.
- No offline caching — the app always refetches from the network; there's no persisted state if you reopen it without connectivity.
- Review "pagination" and sorting are client-side only: DummyJSON returns all reviews in one response, so this app slices/sorts them locally rather than paging against the server.
- No explicit "end of results" indicator on the product grid — pagination just stops silently once everything is loaded.
- Images use plain `Image.network` with no disk caching, so scrolling back up or reopening the app re-downloads thumbnails already seen.
- No category/price filters or sort options on the product list itself (only reviews can be sorted).
- Grid is a fixed 2-column layout — not adapted for tablet/landscape widths.
- No app icon/branding applied yet (still the default Flutter launcher icon).
- No accessibility pass (screen reader labels, font-scaling checks).
