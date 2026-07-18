import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sq.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('sq'),
    Locale('en'),
  ];

  /// No description provided for @brandName.
  ///
  /// In sq, this message translates to:
  /// **'Cava Premium'**
  String get brandName;

  /// No description provided for @retry.
  ///
  /// In sq, this message translates to:
  /// **'Provo përsëri'**
  String get retry;

  /// No description provided for @clearFilters.
  ///
  /// In sq, this message translates to:
  /// **'Pastro filtrat'**
  String get clearFilters;

  /// No description provided for @clear.
  ///
  /// In sq, this message translates to:
  /// **'Pastro'**
  String get clear;

  /// No description provided for @apply.
  ///
  /// In sq, this message translates to:
  /// **'Apliko'**
  String get apply;

  /// No description provided for @cancel.
  ///
  /// In sq, this message translates to:
  /// **'Anulo'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In sq, this message translates to:
  /// **'Ruaj'**
  String get save;

  /// No description provided for @close.
  ///
  /// In sq, this message translates to:
  /// **'Mbyll'**
  String get close;

  /// No description provided for @login.
  ///
  /// In sq, this message translates to:
  /// **'Kyçu'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In sq, this message translates to:
  /// **'Dil'**
  String get logout;

  /// No description provided for @register.
  ///
  /// In sq, this message translates to:
  /// **'Regjistrohu'**
  String get register;

  /// No description provided for @send.
  ///
  /// In sq, this message translates to:
  /// **'Dërgo'**
  String get send;

  /// No description provided for @total.
  ///
  /// In sq, this message translates to:
  /// **'Totali'**
  String get total;

  /// No description provided for @totalColon.
  ///
  /// In sq, this message translates to:
  /// **'Totali:'**
  String get totalColon;

  /// No description provided for @errorGeneric.
  ///
  /// In sq, this message translates to:
  /// **'Gabim'**
  String get errorGeneric;

  /// No description provided for @emDash.
  ///
  /// In sq, this message translates to:
  /// **'—'**
  String get emDash;

  /// No description provided for @notAvailable.
  ///
  /// In sq, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @somethingWentWrong.
  ///
  /// In sq, this message translates to:
  /// **'Diçka shkoi keq. Provo përsëri.'**
  String get somethingWentWrong;

  /// No description provided for @checkInternetConnection.
  ///
  /// In sq, this message translates to:
  /// **'Kontrollo lidhjen me internet.'**
  String get checkInternetConnection;

  /// No description provided for @mustBeLoggedIn.
  ///
  /// In sq, this message translates to:
  /// **'Duhet të jeni të kyçur.'**
  String get mustBeLoggedIn;

  /// No description provided for @loginToContinue.
  ///
  /// In sq, this message translates to:
  /// **'Kyçu për të vazhduar.'**
  String get loginToContinue;

  /// No description provided for @view.
  ///
  /// In sq, this message translates to:
  /// **'Shiko'**
  String get view;

  /// No description provided for @seeAll.
  ///
  /// In sq, this message translates to:
  /// **'Shiko të gjitha'**
  String get seeAll;

  /// No description provided for @add.
  ///
  /// In sq, this message translates to:
  /// **'Shto'**
  String get add;

  /// No description provided for @change.
  ///
  /// In sq, this message translates to:
  /// **'Ndrysho >'**
  String get change;

  /// No description provided for @email.
  ///
  /// In sq, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In sq, this message translates to:
  /// **'Telefon'**
  String get phone;

  /// No description provided for @phoneLabel.
  ///
  /// In sq, this message translates to:
  /// **'Telefoni'**
  String get phoneLabel;

  /// No description provided for @name.
  ///
  /// In sq, this message translates to:
  /// **'Emri'**
  String get name;

  /// No description provided for @lastName.
  ///
  /// In sq, this message translates to:
  /// **'Mbiemri'**
  String get lastName;

  /// No description provided for @fullName.
  ///
  /// In sq, this message translates to:
  /// **'Emri i plotë'**
  String get fullName;

  /// No description provided for @address.
  ///
  /// In sq, this message translates to:
  /// **'Adresa'**
  String get address;

  /// No description provided for @city.
  ///
  /// In sq, this message translates to:
  /// **'Qyteti'**
  String get city;

  /// No description provided for @country.
  ///
  /// In sq, this message translates to:
  /// **'Shteti'**
  String get country;

  /// No description provided for @postalCode.
  ///
  /// In sq, this message translates to:
  /// **'Kodi postar'**
  String get postalCode;

  /// No description provided for @password.
  ///
  /// In sq, this message translates to:
  /// **'Fjalëkalimi'**
  String get password;

  /// No description provided for @schedule.
  ///
  /// In sq, this message translates to:
  /// **'Orari'**
  String get schedule;

  /// No description provided for @defaultCountryKosovo.
  ///
  /// In sq, this message translates to:
  /// **'Kosovë'**
  String get defaultCountryKosovo;

  /// No description provided for @navHome.
  ///
  /// In sq, this message translates to:
  /// **'Kreu'**
  String get navHome;

  /// No description provided for @navWishlist.
  ///
  /// In sq, this message translates to:
  /// **'Preferencat'**
  String get navWishlist;

  /// No description provided for @navCart.
  ///
  /// In sq, this message translates to:
  /// **'Shporta'**
  String get navCart;

  /// No description provided for @navProfile.
  ///
  /// In sq, this message translates to:
  /// **'Profili'**
  String get navProfile;

  /// No description provided for @ownerNavDashboard.
  ///
  /// In sq, this message translates to:
  /// **'Paneli'**
  String get ownerNavDashboard;

  /// No description provided for @ownerNavOrders.
  ///
  /// In sq, this message translates to:
  /// **'Porositë'**
  String get ownerNavOrders;

  /// No description provided for @ownerNavAnalytics.
  ///
  /// In sq, this message translates to:
  /// **'Analitika'**
  String get ownerNavAnalytics;

  /// No description provided for @ownerNavProducts.
  ///
  /// In sq, this message translates to:
  /// **'Produktet'**
  String get ownerNavProducts;

  /// No description provided for @ownerNavSupport.
  ///
  /// In sq, this message translates to:
  /// **'Support'**
  String get ownerNavSupport;

  /// No description provided for @ownerNavProfile.
  ///
  /// In sq, this message translates to:
  /// **'Profili'**
  String get ownerNavProfile;

  /// No description provided for @homeSectionRecommended.
  ///
  /// In sq, this message translates to:
  /// **'Të rekomanduara'**
  String get homeSectionRecommended;

  /// No description provided for @homeSectionBestSellers.
  ///
  /// In sq, this message translates to:
  /// **'Më të shiturat'**
  String get homeSectionBestSellers;

  /// No description provided for @homeSectionOffers.
  ///
  /// In sq, this message translates to:
  /// **'Oferta'**
  String get homeSectionOffers;

  /// No description provided for @searchHintDefault.
  ///
  /// In sq, this message translates to:
  /// **'Kërko produkte…'**
  String get searchHintDefault;

  /// No description provided for @allProductsChip.
  ///
  /// In sq, this message translates to:
  /// **'Të gjitha produktet'**
  String get allProductsChip;

  /// No description provided for @allChip.
  ///
  /// In sq, this message translates to:
  /// **'Të gjitha'**
  String get allChip;

  /// No description provided for @heroBrandTagline.
  ///
  /// In sq, this message translates to:
  /// **'Koleksioni Premium'**
  String get heroBrandTagline;

  /// No description provided for @heroHeadline.
  ///
  /// In sq, this message translates to:
  /// **'Zbuloni Koleksionin\nPremium'**
  String get heroHeadline;

  /// No description provided for @heroSubtitle.
  ///
  /// In sq, this message translates to:
  /// **'Verë • Spirits • Duhan • Aksesorë'**
  String get heroSubtitle;

  /// No description provided for @heroCta.
  ///
  /// In sq, this message translates to:
  /// **'Eksploro koleksionin'**
  String get heroCta;

  /// No description provided for @visitStoreTitle.
  ///
  /// In sq, this message translates to:
  /// **'Na vizitoni fizikisht'**
  String get visitStoreTitle;

  /// No description provided for @visitStoreSubtitle.
  ///
  /// In sq, this message translates to:
  /// **'në pikën tonë të shitjes'**
  String get visitStoreSubtitle;

  /// No description provided for @visitStoreAddress.
  ///
  /// In sq, this message translates to:
  /// **'The Village - Shopping & Fun, 1 Ahmet Kaçiku, Ferizaj 70000'**
  String get visitStoreAddress;

  /// No description provided for @openMapsTitle.
  ///
  /// In sq, this message translates to:
  /// **'Hap Maps?'**
  String get openMapsTitle;

  /// No description provided for @openMapsMessage.
  ///
  /// In sq, this message translates to:
  /// **'Dëshiron ta hapësh lokacionin në Maps?'**
  String get openMapsMessage;

  /// No description provided for @openMapsCancel.
  ///
  /// In sq, this message translates to:
  /// **'Anulo'**
  String get openMapsCancel;

  /// No description provided for @openMapsConfirm.
  ///
  /// In sq, this message translates to:
  /// **'Hap Maps'**
  String get openMapsConfirm;

  /// No description provided for @openMapsError.
  ///
  /// In sq, this message translates to:
  /// **'Nuk mund të hapet Maps.'**
  String get openMapsError;

  /// No description provided for @searchHintCava.
  ///
  /// In sq, this message translates to:
  /// **'Kërko produktet e Cava Premium…'**
  String get searchHintCava;

  /// No description provided for @searchClear.
  ///
  /// In sq, this message translates to:
  /// **'Fshij'**
  String get searchClear;

  /// No description provided for @searchEmptyPrompt.
  ///
  /// In sq, this message translates to:
  /// **'Kërko produktet e Cava Premium.'**
  String get searchEmptyPrompt;

  /// No description provided for @searchRecentTitle.
  ///
  /// In sq, this message translates to:
  /// **'Kërkimet e fundit'**
  String get searchRecentTitle;

  /// No description provided for @searchClearAll.
  ///
  /// In sq, this message translates to:
  /// **'Fshij të gjitha'**
  String get searchClearAll;

  /// No description provided for @searchNoResults.
  ///
  /// In sq, this message translates to:
  /// **'Nuk u gjet asnjë produkt.'**
  String get searchNoResults;

  /// No description provided for @searchNoResultsWithFilters.
  ///
  /// In sq, this message translates to:
  /// **'Nuk u gjet asnjë produkt me këto filtra.'**
  String get searchNoResultsWithFilters;

  /// No description provided for @categoriesTitle.
  ///
  /// In sq, this message translates to:
  /// **'Kategoritë'**
  String get categoriesTitle;

  /// No description provided for @allProductsTitle.
  ///
  /// In sq, this message translates to:
  /// **'Të gjitha produktet'**
  String get allProductsTitle;

  /// No description provided for @productsTitle.
  ///
  /// In sq, this message translates to:
  /// **'Produktet'**
  String get productsTitle;

  /// No description provided for @searchInAllProducts.
  ///
  /// In sq, this message translates to:
  /// **'Kërko të gjitha produktet…'**
  String get searchInAllProducts;

  /// No description provided for @searchInCategory.
  ///
  /// In sq, this message translates to:
  /// **'Kërko në {category}…'**
  String searchInCategory(String category);

  /// No description provided for @searchInCategoryFallback.
  ///
  /// In sq, this message translates to:
  /// **'kategori'**
  String get searchInCategoryFallback;

  /// No description provided for @filterSortTitle.
  ///
  /// In sq, this message translates to:
  /// **'Filtro & Sorto'**
  String get filterSortTitle;

  /// No description provided for @filterSectionSort.
  ///
  /// In sq, this message translates to:
  /// **'Renditja'**
  String get filterSectionSort;

  /// No description provided for @filterSectionPrice.
  ///
  /// In sq, this message translates to:
  /// **'Çmimi'**
  String get filterSectionPrice;

  /// No description provided for @filterInStockOnly.
  ///
  /// In sq, this message translates to:
  /// **'Vetëm në stok'**
  String get filterInStockOnly;

  /// No description provided for @filterSectionBrand.
  ///
  /// In sq, this message translates to:
  /// **'Marka'**
  String get filterSectionBrand;

  /// No description provided for @filterSectionOrigin.
  ///
  /// In sq, this message translates to:
  /// **'Origjina'**
  String get filterSectionOrigin;

  /// No description provided for @filterSectionCategory.
  ///
  /// In sq, this message translates to:
  /// **'Kategoria'**
  String get filterSectionCategory;

  /// No description provided for @filterSectionSubcategory.
  ///
  /// In sq, this message translates to:
  /// **'Nënkategoria'**
  String get filterSectionSubcategory;

  /// No description provided for @filterSectionVolume.
  ///
  /// In sq, this message translates to:
  /// **'Volumi'**
  String get filterSectionVolume;

  /// No description provided for @sortRecommended.
  ///
  /// In sq, this message translates to:
  /// **'Të rekomanduara'**
  String get sortRecommended;

  /// No description provided for @sortNameAsc.
  ///
  /// In sq, this message translates to:
  /// **'Emri A–Z'**
  String get sortNameAsc;

  /// No description provided for @sortNameDesc.
  ///
  /// In sq, this message translates to:
  /// **'Emri Z–A'**
  String get sortNameDesc;

  /// No description provided for @sortPriceAsc.
  ///
  /// In sq, this message translates to:
  /// **'Çmimi: nga i ulët'**
  String get sortPriceAsc;

  /// No description provided for @sortPriceDesc.
  ///
  /// In sq, this message translates to:
  /// **'Çmimi: nga i lartë'**
  String get sortPriceDesc;

  /// No description provided for @sortNewest.
  ///
  /// In sq, this message translates to:
  /// **'Më të rejat'**
  String get sortNewest;

  /// No description provided for @sortBestSellers.
  ///
  /// In sq, this message translates to:
  /// **'Më të shiturat'**
  String get sortBestSellers;

  /// No description provided for @wishlistTitle.
  ///
  /// In sq, this message translates to:
  /// **'Preferencat'**
  String get wishlistTitle;

  /// No description provided for @wishlistEmpty.
  ///
  /// In sq, this message translates to:
  /// **'Lista e preferencave është bosh.'**
  String get wishlistEmpty;

  /// No description provided for @viewProducts.
  ///
  /// In sq, this message translates to:
  /// **'Shiko produktet'**
  String get viewProducts;

  /// No description provided for @addToCart.
  ///
  /// In sq, this message translates to:
  /// **'Shto në shportë'**
  String get addToCart;

  /// No description provided for @cartScriptTitle.
  ///
  /// In sq, this message translates to:
  /// **'Shporta'**
  String get cartScriptTitle;

  /// No description provided for @cartBoldTitle.
  ///
  /// In sq, this message translates to:
  /// **'Juaj'**
  String get cartBoldTitle;

  /// No description provided for @cartEmpty.
  ///
  /// In sq, this message translates to:
  /// **'Shporta është bosh'**
  String get cartEmpty;

  /// No description provided for @cartOrderTotalTitle.
  ///
  /// In sq, this message translates to:
  /// **'Totali i porosisë'**
  String get cartOrderTotalTitle;

  /// No description provided for @cartPrice.
  ///
  /// In sq, this message translates to:
  /// **'Çmimi'**
  String get cartPrice;

  /// No description provided for @cartVat.
  ///
  /// In sq, this message translates to:
  /// **'TVSH'**
  String get cartVat;

  /// No description provided for @cartShipping.
  ///
  /// In sq, this message translates to:
  /// **'Transporti'**
  String get cartShipping;

  /// No description provided for @cartDiscount.
  ///
  /// In sq, this message translates to:
  /// **'Zbritja'**
  String get cartDiscount;

  /// No description provided for @cartContinue.
  ///
  /// In sq, this message translates to:
  /// **'Vazhdo'**
  String get cartContinue;

  /// No description provided for @productAddedToCart.
  ///
  /// In sq, this message translates to:
  /// **'Produkti u shtua në shportë.'**
  String get productAddedToCart;

  /// No description provided for @productOutOfStock.
  ///
  /// In sq, this message translates to:
  /// **'Produkti nuk është në stok.'**
  String get productOutOfStock;

  /// No description provided for @insufficientStock.
  ///
  /// In sq, this message translates to:
  /// **'Nuk ka stok të mjaftueshëm.'**
  String get insufficientStock;

  /// No description provided for @addToCartFailed.
  ///
  /// In sq, this message translates to:
  /// **'Nuk u shtua në shportë. Provo përsëri.'**
  String get addToCartFailed;

  /// No description provided for @cartItemUnavailable.
  ///
  /// In sq, this message translates to:
  /// **'Një produkt nuk është më në dispozicion ose nuk ka stok të mjaftueshëm.'**
  String get cartItemUnavailable;

  /// No description provided for @productTitle.
  ///
  /// In sq, this message translates to:
  /// **'Produkti'**
  String get productTitle;

  /// No description provided for @productNotFound.
  ///
  /// In sq, this message translates to:
  /// **'Produkti nuk u gjet'**
  String get productNotFound;

  /// No description provided for @productVatNote.
  ///
  /// In sq, this message translates to:
  /// **'TVSH llogaritet në arkë'**
  String get productVatNote;

  /// No description provided for @productDescription.
  ///
  /// In sq, this message translates to:
  /// **'Përshkrimi'**
  String get productDescription;

  /// No description provided for @productDescriptionPlaceholder.
  ///
  /// In sq, this message translates to:
  /// **'Është duke u përpunuar përshkrimi, ju kërkojmë ndjesë.'**
  String get productDescriptionPlaceholder;

  /// No description provided for @productTabDetails.
  ///
  /// In sq, this message translates to:
  /// **'Detajet'**
  String get productTabDetails;

  /// No description provided for @productTabSuggestions.
  ///
  /// In sq, this message translates to:
  /// **'Sugjerimet'**
  String get productTabSuggestions;

  /// No description provided for @outOfStockBadge.
  ///
  /// In sq, this message translates to:
  /// **'Jashtë stoku'**
  String get outOfStockBadge;

  /// No description provided for @productCodeLabel.
  ///
  /// In sq, this message translates to:
  /// **'Kodi: {code}'**
  String productCodeLabel(String code);

  /// No description provided for @productOriginLabel.
  ///
  /// In sq, this message translates to:
  /// **'Origjina: {origin}'**
  String productOriginLabel(String origin);

  /// No description provided for @detailGrapeType.
  ///
  /// In sq, this message translates to:
  /// **'Lloji i rrushit:'**
  String get detailGrapeType;

  /// No description provided for @detailRegion.
  ///
  /// In sq, this message translates to:
  /// **'Rajoni:'**
  String get detailRegion;

  /// No description provided for @detailVintage.
  ///
  /// In sq, this message translates to:
  /// **'Vintage:'**
  String get detailVintage;

  /// No description provided for @detailTaste.
  ///
  /// In sq, this message translates to:
  /// **'Shija:'**
  String get detailTaste;

  /// No description provided for @detailAbv.
  ///
  /// In sq, this message translates to:
  /// **'ABV:'**
  String get detailAbv;

  /// No description provided for @detailVolume.
  ///
  /// In sq, this message translates to:
  /// **'Volumi:'**
  String get detailVolume;

  /// No description provided for @detailBody.
  ///
  /// In sq, this message translates to:
  /// **'Trupi:'**
  String get detailBody;

  /// No description provided for @detailTannins.
  ///
  /// In sq, this message translates to:
  /// **'Taninet:'**
  String get detailTannins;

  /// No description provided for @detailAging.
  ///
  /// In sq, this message translates to:
  /// **'Vjetrimi:'**
  String get detailAging;

  /// No description provided for @suggestTemperature.
  ///
  /// In sq, this message translates to:
  /// **'Temperatura:'**
  String get suggestTemperature;

  /// No description provided for @suggestDecanting.
  ///
  /// In sq, this message translates to:
  /// **'Dekantimi:'**
  String get suggestDecanting;

  /// No description provided for @suggestFinish.
  ///
  /// In sq, this message translates to:
  /// **'Përfundimi:'**
  String get suggestFinish;

  /// No description provided for @suggestAromas.
  ///
  /// In sq, this message translates to:
  /// **'Aromat:'**
  String get suggestAromas;

  /// No description provided for @suggestPairing.
  ///
  /// In sq, this message translates to:
  /// **'Kombinimi:'**
  String get suggestPairing;

  /// No description provided for @buyNow.
  ///
  /// In sq, this message translates to:
  /// **'Bli tani'**
  String get buyNow;

  /// No description provided for @addToCartCta.
  ///
  /// In sq, this message translates to:
  /// **'SHTO NË SHPORTË'**
  String get addToCartCta;

  /// No description provided for @metaCountry.
  ///
  /// In sq, this message translates to:
  /// **'Shteti'**
  String get metaCountry;

  /// No description provided for @metaBottle.
  ///
  /// In sq, this message translates to:
  /// **'Shishja'**
  String get metaBottle;

  /// No description provided for @metaAlcohol.
  ///
  /// In sq, this message translates to:
  /// **'Alkooli'**
  String get metaAlcohol;

  /// No description provided for @infoVariety.
  ///
  /// In sq, this message translates to:
  /// **'Varieteti'**
  String get infoVariety;

  /// No description provided for @infoServing.
  ///
  /// In sq, this message translates to:
  /// **'Shërbimi'**
  String get infoServing;

  /// No description provided for @sectionDescription.
  ///
  /// In sq, this message translates to:
  /// **'Përshkrimi'**
  String get sectionDescription;

  /// No description provided for @sectionFoodPairing.
  ///
  /// In sq, this message translates to:
  /// **'Kombinimi me ushqim'**
  String get sectionFoodPairing;

  /// No description provided for @sectionTastingNotes.
  ///
  /// In sq, this message translates to:
  /// **'Shënime shije'**
  String get sectionTastingNotes;

  /// No description provided for @sectionWinery.
  ///
  /// In sq, this message translates to:
  /// **'Kanteria'**
  String get sectionWinery;

  /// No description provided for @checkoutScriptTitle.
  ///
  /// In sq, this message translates to:
  /// **'Finalizo'**
  String get checkoutScriptTitle;

  /// No description provided for @checkoutBoldTitle.
  ///
  /// In sq, this message translates to:
  /// **'Porosinë'**
  String get checkoutBoldTitle;

  /// No description provided for @deliveryAddressTitle.
  ///
  /// In sq, this message translates to:
  /// **'Adresa e dorëzimit'**
  String get deliveryAddressTitle;

  /// No description provided for @selectDeliveryAddress.
  ///
  /// In sq, this message translates to:
  /// **'Zgjidh adresën e dorëzimit.'**
  String get selectDeliveryAddress;

  /// No description provided for @notLoggedIn.
  ///
  /// In sq, this message translates to:
  /// **'Nuk je i kyçur.'**
  String get notLoggedIn;

  /// No description provided for @buyAsGuest.
  ///
  /// In sq, this message translates to:
  /// **'Bli pa u regjistruar'**
  String get buyAsGuest;

  /// No description provided for @signIn.
  ///
  /// In sq, this message translates to:
  /// **'Hyr'**
  String get signIn;

  /// No description provided for @noAddressYet.
  ///
  /// In sq, this message translates to:
  /// **'Nuk ke asnjë adresë.'**
  String get noAddressYet;

  /// No description provided for @addAddress.
  ///
  /// In sq, this message translates to:
  /// **'Shto adresë'**
  String get addAddress;

  /// No description provided for @addNewAddress.
  ///
  /// In sq, this message translates to:
  /// **'Shto adresë të re'**
  String get addNewAddress;

  /// No description provided for @infoName.
  ///
  /// In sq, this message translates to:
  /// **'Emri:'**
  String get infoName;

  /// No description provided for @infoEmail.
  ///
  /// In sq, this message translates to:
  /// **'Email:'**
  String get infoEmail;

  /// No description provided for @infoAddress.
  ///
  /// In sq, this message translates to:
  /// **'Adresa:'**
  String get infoAddress;

  /// No description provided for @infoCity.
  ///
  /// In sq, this message translates to:
  /// **'Qyteti:'**
  String get infoCity;

  /// No description provided for @infoCountry.
  ///
  /// In sq, this message translates to:
  /// **'Shteti:'**
  String get infoCountry;

  /// No description provided for @infoPhone.
  ///
  /// In sq, this message translates to:
  /// **'Telefoni:'**
  String get infoPhone;

  /// No description provided for @infoPostalCode.
  ///
  /// In sq, this message translates to:
  /// **'Kodi postar:'**
  String get infoPostalCode;

  /// No description provided for @payCash.
  ///
  /// In sq, this message translates to:
  /// **'Paguaj me para në dorë'**
  String get payCash;

  /// No description provided for @payCard.
  ///
  /// In sq, this message translates to:
  /// **'Paguaj me kartel'**
  String get payCard;

  /// No description provided for @payBank.
  ///
  /// In sq, this message translates to:
  /// **'Transfer bankar'**
  String get payBank;

  /// No description provided for @termsAgreePrefix.
  ///
  /// In sq, this message translates to:
  /// **'Pajtohem me '**
  String get termsAgreePrefix;

  /// No description provided for @termsAndRules.
  ///
  /// In sq, this message translates to:
  /// **'Kushtet & Rregullat'**
  String get termsAndRules;

  /// No description provided for @termsAgreeAnd.
  ///
  /// In sq, this message translates to:
  /// **' dhe '**
  String get termsAgreeAnd;

  /// No description provided for @returnPolicy.
  ///
  /// In sq, this message translates to:
  /// **'Politikën e Kthimit'**
  String get returnPolicy;

  /// No description provided for @buy.
  ///
  /// In sq, this message translates to:
  /// **'Bli'**
  String get buy;

  /// No description provided for @orderCreateFailed.
  ///
  /// In sq, this message translates to:
  /// **'Porosia nuk u krijua. Provo përsëri.'**
  String get orderCreateFailed;

  /// No description provided for @mustAcceptTerms.
  ///
  /// In sq, this message translates to:
  /// **'Duhet të pranosh kushtet.'**
  String get mustAcceptTerms;

  /// No description provided for @completeDeliveryInfo.
  ///
  /// In sq, this message translates to:
  /// **'Plotëso të dhënat për dorëzim.'**
  String get completeDeliveryInfo;

  /// No description provided for @addOrSelectAddress.
  ///
  /// In sq, this message translates to:
  /// **'Shto ose zgjidh një adresë.'**
  String get addOrSelectAddress;

  /// No description provided for @guestCheckoutTitle.
  ///
  /// In sq, this message translates to:
  /// **'Të dhënat e dorëzimit'**
  String get guestCheckoutTitle;

  /// No description provided for @mockPayCardTitle.
  ///
  /// In sq, this message translates to:
  /// **'Paguaj me Kartë (Quipu)'**
  String get mockPayCardTitle;

  /// No description provided for @mockPayCardSubtitle.
  ///
  /// In sq, this message translates to:
  /// **'Paguaj online në mënyrë të sigurt'**
  String get mockPayCardSubtitle;

  /// No description provided for @mockPayBankTitle.
  ///
  /// In sq, this message translates to:
  /// **'Transfer Bankar'**
  String get mockPayBankTitle;

  /// No description provided for @mockPayBankSubtitle.
  ///
  /// In sq, this message translates to:
  /// **'Do të konfirmohet manualisht'**
  String get mockPayBankSubtitle;

  /// No description provided for @mockPayCashTitle.
  ///
  /// In sq, this message translates to:
  /// **'Pagesë në dorëzim (Cash)'**
  String get mockPayCashTitle;

  /// No description provided for @mockPayCashSubtitle.
  ///
  /// In sq, this message translates to:
  /// **'Paguaj kur të pranosh porosinë'**
  String get mockPayCashSubtitle;

  /// No description provided for @validationFirstNameRequired.
  ///
  /// In sq, this message translates to:
  /// **'Emri është i detyrueshëm.'**
  String get validationFirstNameRequired;

  /// No description provided for @validationLastNameRequired.
  ///
  /// In sq, this message translates to:
  /// **'Mbiemri është i detyrueshëm.'**
  String get validationLastNameRequired;

  /// No description provided for @validationEmailRequired.
  ///
  /// In sq, this message translates to:
  /// **'Email është i detyrueshëm.'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In sq, this message translates to:
  /// **'Email nuk është valid.'**
  String get validationEmailInvalid;

  /// No description provided for @validationPhoneRequired.
  ///
  /// In sq, this message translates to:
  /// **'Telefoni është i detyrueshëm.'**
  String get validationPhoneRequired;

  /// No description provided for @validationAddressRequired.
  ///
  /// In sq, this message translates to:
  /// **'Adresa është e detyrueshme.'**
  String get validationAddressRequired;

  /// No description provided for @validationCityRequired.
  ///
  /// In sq, this message translates to:
  /// **'Qyteti është i detyrueshëm.'**
  String get validationCityRequired;

  /// No description provided for @validationCountryRequired.
  ///
  /// In sq, this message translates to:
  /// **'Shteti është i detyrueshëm.'**
  String get validationCountryRequired;

  /// No description provided for @validationStreetRequired.
  ///
  /// In sq, this message translates to:
  /// **'Rruga është e detyrueshme.'**
  String get validationStreetRequired;

  /// No description provided for @validationPhoneInvalid.
  ///
  /// In sq, this message translates to:
  /// **'Numri i telefonit nuk është i vlefshëm.'**
  String get validationPhoneInvalid;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In sq, this message translates to:
  /// **'Fjalëkalimi është i detyrueshëm.'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordMinLength.
  ///
  /// In sq, this message translates to:
  /// **'Fjalëkalimi duhet të ketë të paktën 6 karaktere.'**
  String get validationPasswordMinLength;

  /// No description provided for @validationNameRequired.
  ///
  /// In sq, this message translates to:
  /// **'Emri është i detyrueshëm.'**
  String get validationNameRequired;

  /// No description provided for @validationConfirmPassword.
  ///
  /// In sq, this message translates to:
  /// **'Konfirmo fjalëkalimin.'**
  String get validationConfirmPassword;

  /// No description provided for @validationPasswordsMismatch.
  ///
  /// In sq, this message translates to:
  /// **'Fjalëkalimet nuk përputhen.'**
  String get validationPasswordsMismatch;

  /// No description provided for @orderSuccessAppBar.
  ///
  /// In sq, this message translates to:
  /// **'Porosia'**
  String get orderSuccessAppBar;

  /// No description provided for @orderSuccessTitle.
  ///
  /// In sq, this message translates to:
  /// **'Porosia u Krye!'**
  String get orderSuccessTitle;

  /// No description provided for @orderSuccessThanks.
  ///
  /// In sq, this message translates to:
  /// **'Faleminderit për besimin tuaj.'**
  String get orderSuccessThanks;

  /// No description provided for @orderSuccessOrderLabel.
  ///
  /// In sq, this message translates to:
  /// **'Porosia'**
  String get orderSuccessOrderLabel;

  /// No description provided for @orderSuccessPaymentLabel.
  ///
  /// In sq, this message translates to:
  /// **'Pagesa'**
  String get orderSuccessPaymentLabel;

  /// No description provided for @paymentMethodCash.
  ///
  /// In sq, this message translates to:
  /// **'Para në dorë'**
  String get paymentMethodCash;

  /// No description provided for @paymentMethodCard.
  ///
  /// In sq, this message translates to:
  /// **'Kartë'**
  String get paymentMethodCard;

  /// No description provided for @paymentMethodBank.
  ///
  /// In sq, this message translates to:
  /// **'Transfer bankar'**
  String get paymentMethodBank;

  /// No description provided for @confirm.
  ///
  /// In sq, this message translates to:
  /// **'Konfirmo'**
  String get confirm;

  /// No description provided for @orderFulfillmentStatusTitle.
  ///
  /// In sq, this message translates to:
  /// **'Statusi i përmbushjes'**
  String get orderFulfillmentStatusTitle;

  /// No description provided for @orderStatusSelectorLabel.
  ///
  /// In sq, this message translates to:
  /// **'Ndrysho statusin'**
  String get orderStatusSelectorLabel;

  /// No description provided for @orderStatusChangeTitle.
  ///
  /// In sq, this message translates to:
  /// **'Ndrysho statusin'**
  String get orderStatusChangeTitle;

  /// No description provided for @orderStatusChangeSuccess.
  ///
  /// In sq, this message translates to:
  /// **'Statusi i porosisë u përditësua.'**
  String get orderStatusChangeSuccess;

  /// No description provided for @orderFulfillmentReceived.
  ///
  /// In sq, this message translates to:
  /// **'Porosia u pranua'**
  String get orderFulfillmentReceived;

  /// No description provided for @orderFulfillmentConfirmed.
  ///
  /// In sq, this message translates to:
  /// **'U konfirmua'**
  String get orderFulfillmentConfirmed;

  /// No description provided for @orderFulfillmentPrepared.
  ///
  /// In sq, this message translates to:
  /// **'U përgatit'**
  String get orderFulfillmentPrepared;

  /// No description provided for @orderFulfillmentShipped.
  ///
  /// In sq, this message translates to:
  /// **'U dërgua te postieri'**
  String get orderFulfillmentShipped;

  /// No description provided for @orderFulfillmentInTransit.
  ///
  /// In sq, this message translates to:
  /// **'Në transport'**
  String get orderFulfillmentInTransit;

  /// No description provided for @orderFulfillmentDelivered.
  ///
  /// In sq, this message translates to:
  /// **'U dorëzua'**
  String get orderFulfillmentDelivered;

  /// No description provided for @orderFulfillmentReturned.
  ///
  /// In sq, this message translates to:
  /// **'Kthyer / Return'**
  String get orderFulfillmentReturned;

  /// No description provided for @orderFulfillmentCanceled.
  ///
  /// In sq, this message translates to:
  /// **'Anuluar'**
  String get orderFulfillmentCanceled;

  /// No description provided for @orderStatusChangeConfirm.
  ///
  /// In sq, this message translates to:
  /// **'Ndrysho statusin e {orderNumber} nga \"{fromStatus}\" në \"{toStatus}\"?'**
  String orderStatusChangeConfirm(
    Object orderNumber,
    Object fromStatus,
    Object toStatus,
  );

  /// No description provided for @backToHome.
  ///
  /// In sq, this message translates to:
  /// **'Kthehu në Kreu'**
  String get backToHome;

  /// No description provided for @authWelcome.
  ///
  /// In sq, this message translates to:
  /// **'Mirë se vini'**
  String get authWelcome;

  /// No description provided for @authResetPasswordTitle.
  ///
  /// In sq, this message translates to:
  /// **'Rikthe fjalëkalimin'**
  String get authResetPasswordTitle;

  /// No description provided for @authForgotPassword.
  ///
  /// In sq, this message translates to:
  /// **'Harrove fjalëkalimin?'**
  String get authForgotPassword;

  /// No description provided for @authConfirmPassword.
  ///
  /// In sq, this message translates to:
  /// **'Konfirmo fjalëkalimin'**
  String get authConfirmPassword;

  /// No description provided for @authForgotPasswordHint.
  ///
  /// In sq, this message translates to:
  /// **'Shkruaj email-in tënd dhe do të dërgojmë një link për rikthimin e fjalëkalimit.'**
  String get authForgotPasswordHint;

  /// No description provided for @authSendLink.
  ///
  /// In sq, this message translates to:
  /// **'Dërgo linkun'**
  String get authSendLink;

  /// No description provided for @authBackToLogin.
  ///
  /// In sq, this message translates to:
  /// **'Kthehu te kyçja'**
  String get authBackToLogin;

  /// No description provided for @authResetEmailSent.
  ///
  /// In sq, this message translates to:
  /// **'Email për rikthim fjalëkalimi u dërgua.'**
  String get authResetEmailSent;

  /// No description provided for @authWrongCredentials.
  ///
  /// In sq, this message translates to:
  /// **'Email ose fjalëkalim i pasaktë.'**
  String get authWrongCredentials;

  /// No description provided for @authEmailInUse.
  ///
  /// In sq, this message translates to:
  /// **'Ky email është i regjistruar.'**
  String get authEmailInUse;

  /// No description provided for @authWeakPassword.
  ///
  /// In sq, this message translates to:
  /// **'Fjalëkalimi është shumë i dobët.'**
  String get authWeakPassword;

  /// No description provided for @profileTitle.
  ///
  /// In sq, this message translates to:
  /// **'Profili'**
  String get profileTitle;

  /// No description provided for @editProfile.
  ///
  /// In sq, this message translates to:
  /// **'Edito profilin'**
  String get editProfile;

  /// No description provided for @myOrders.
  ///
  /// In sq, this message translates to:
  /// **'Porositë e mia'**
  String get myOrders;

  /// No description provided for @addresses.
  ///
  /// In sq, this message translates to:
  /// **'Adresat'**
  String get addresses;

  /// No description provided for @helpAndContact.
  ///
  /// In sq, this message translates to:
  /// **'Ndihmë & Kontakt'**
  String get helpAndContact;

  /// No description provided for @aboutCava.
  ///
  /// In sq, this message translates to:
  /// **'Rreth Cava Premium'**
  String get aboutCava;

  /// No description provided for @language.
  ///
  /// In sq, this message translates to:
  /// **'Gjuha'**
  String get language;

  /// No description provided for @termsOfUse.
  ///
  /// In sq, this message translates to:
  /// **'Kushtet e përdorimit'**
  String get termsOfUse;

  /// No description provided for @privacyPolicy.
  ///
  /// In sq, this message translates to:
  /// **'Politika e privatësisë'**
  String get privacyPolicy;

  /// No description provided for @currency.
  ///
  /// In sq, this message translates to:
  /// **'Valuta'**
  String get currency;

  /// No description provided for @profileUpdated.
  ///
  /// In sq, this message translates to:
  /// **'Profili u përditësua.'**
  String get profileUpdated;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In sq, this message translates to:
  /// **'Profili nuk u përditësua. Provo përsëri.'**
  String get profileUpdateFailed;

  /// No description provided for @profileReadFailed.
  ///
  /// In sq, this message translates to:
  /// **'Profili nuk u lexua. Provo përsëri.'**
  String get profileReadFailed;

  /// No description provided for @profileCreateFailed.
  ///
  /// In sq, this message translates to:
  /// **'Profili nuk u krijua. Provo përsëri.'**
  String get profileCreateFailed;

  /// No description provided for @languageAlbanian.
  ///
  /// In sq, this message translates to:
  /// **'Shqip'**
  String get languageAlbanian;

  /// No description provided for @languageEnglish.
  ///
  /// In sq, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @currencyEur.
  ///
  /// In sq, this message translates to:
  /// **'EUR (€)'**
  String get currencyEur;

  /// No description provided for @currencyUsd.
  ///
  /// In sq, this message translates to:
  /// **'USD (\$)'**
  String get currencyUsd;

  /// No description provided for @currencyAll.
  ///
  /// In sq, this message translates to:
  /// **'ALL (L)'**
  String get currencyAll;

  /// No description provided for @addressesEmpty.
  ///
  /// In sq, this message translates to:
  /// **'Nuk ke adresa të ruajtura.'**
  String get addressesEmpty;

  /// No description provided for @loginToManageAddresses.
  ///
  /// In sq, this message translates to:
  /// **'Kyçu për të menaxhuar adresat e tua.'**
  String get loginToManageAddresses;

  /// No description provided for @addressFallbackLabel.
  ///
  /// In sq, this message translates to:
  /// **'Adresë'**
  String get addressFallbackLabel;

  /// No description provided for @addressDefaultBadge.
  ///
  /// In sq, this message translates to:
  /// **'Kryesore'**
  String get addressDefaultBadge;

  /// No description provided for @setAsDefault.
  ///
  /// In sq, this message translates to:
  /// **'Vendos si kryesore'**
  String get setAsDefault;

  /// No description provided for @postalCodeWithValue.
  ///
  /// In sq, this message translates to:
  /// **'Kodi postar: {zip}'**
  String postalCodeWithValue(String zip);

  /// No description provided for @addAddressTitle.
  ///
  /// In sq, this message translates to:
  /// **'Shto adresë'**
  String get addAddressTitle;

  /// No description provided for @addressLabel.
  ///
  /// In sq, this message translates to:
  /// **'Etiketa'**
  String get addressLabel;

  /// No description provided for @street.
  ///
  /// In sq, this message translates to:
  /// **'Rruga'**
  String get street;

  /// No description provided for @setAsDefaultAddress.
  ///
  /// In sq, this message translates to:
  /// **'Vendos si adresë kryesore'**
  String get setAsDefaultAddress;

  /// No description provided for @saveAddress.
  ///
  /// In sq, this message translates to:
  /// **'Ruaj adresën'**
  String get saveAddress;

  /// No description provided for @ordersEmpty.
  ///
  /// In sq, this message translates to:
  /// **'Nuk ke porosi ende.'**
  String get ordersEmpty;

  /// No description provided for @loginToSeeOrders.
  ///
  /// In sq, this message translates to:
  /// **'Kyçu për të parë porositë e tua.'**
  String get loginToSeeOrders;

  /// No description provided for @ordersItemCount.
  ///
  /// In sq, this message translates to:
  /// **'{count} produkte'**
  String ordersItemCount(int count);

  /// No description provided for @orderDetailTitle.
  ///
  /// In sq, this message translates to:
  /// **'Detajet e porosisë'**
  String get orderDetailTitle;

  /// No description provided for @orderLabel.
  ///
  /// In sq, this message translates to:
  /// **'Porosia'**
  String get orderLabel;

  /// No description provided for @orderStatus.
  ///
  /// In sq, this message translates to:
  /// **'Statusi'**
  String get orderStatus;

  /// No description provided for @orderPayment.
  ///
  /// In sq, this message translates to:
  /// **'Pagesa'**
  String get orderPayment;

  /// No description provided for @orderDate.
  ///
  /// In sq, this message translates to:
  /// **'Data'**
  String get orderDate;

  /// No description provided for @orderProducts.
  ///
  /// In sq, this message translates to:
  /// **'Produktet'**
  String get orderProducts;

  /// No description provided for @orderNoProducts.
  ///
  /// In sq, this message translates to:
  /// **'Nuk ka produkte në këtë porosi.'**
  String get orderNoProducts;

  /// No description provided for @orderSubtotal.
  ///
  /// In sq, this message translates to:
  /// **'Nëntotali'**
  String get orderSubtotal;

  /// No description provided for @orderCustomer.
  ///
  /// In sq, this message translates to:
  /// **'Klienti'**
  String get orderCustomer;

  /// No description provided for @orderStatusOpen.
  ///
  /// In sq, this message translates to:
  /// **'E hapur'**
  String get orderStatusOpen;

  /// No description provided for @orderStatusPending.
  ///
  /// In sq, this message translates to:
  /// **'Në pritje'**
  String get orderStatusPending;

  /// No description provided for @orderStatusProcessing.
  ///
  /// In sq, this message translates to:
  /// **'Në përpunim'**
  String get orderStatusProcessing;

  /// No description provided for @orderStatusShipped.
  ///
  /// In sq, this message translates to:
  /// **'Në rrugëtim'**
  String get orderStatusShipped;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In sq, this message translates to:
  /// **'E dorëzuar'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In sq, this message translates to:
  /// **'E anuluar'**
  String get orderStatusCancelled;

  /// No description provided for @paymentStatusPaid.
  ///
  /// In sq, this message translates to:
  /// **'E paguar'**
  String get paymentStatusPaid;

  /// No description provided for @paymentStatusUnpaid.
  ///
  /// In sq, this message translates to:
  /// **'E papaguar'**
  String get paymentStatusUnpaid;

  /// No description provided for @paymentStatusPending.
  ///
  /// In sq, this message translates to:
  /// **'Në pritje'**
  String get paymentStatusPending;

  /// No description provided for @paymentStatusFailed.
  ///
  /// In sq, this message translates to:
  /// **'Dështuar'**
  String get paymentStatusFailed;

  /// No description provided for @paymentStatusRefunded.
  ///
  /// In sq, this message translates to:
  /// **'E rimbursuar'**
  String get paymentStatusRefunded;

  /// No description provided for @helpEmailValue.
  ///
  /// In sq, this message translates to:
  /// **'info@cava-premium.com'**
  String get helpEmailValue;

  /// No description provided for @helpPhoneValue.
  ///
  /// In sq, this message translates to:
  /// **'+355 69 000 0000'**
  String get helpPhoneValue;

  /// No description provided for @helpHoursValue.
  ///
  /// In sq, this message translates to:
  /// **'E Hënë – E Shtunë, 09:00 – 20:00'**
  String get helpHoursValue;

  /// No description provided for @faqTitle.
  ///
  /// In sq, this message translates to:
  /// **'Pyetje të shpeshta'**
  String get faqTitle;

  /// No description provided for @faqTrackOrder.
  ///
  /// In sq, this message translates to:
  /// **'Si mund ta ndjek porosinë time?'**
  String get faqTrackOrder;

  /// No description provided for @faqPaymentMethods.
  ///
  /// In sq, this message translates to:
  /// **'Cilat janë metodat e pagesës?'**
  String get faqPaymentMethods;

  /// No description provided for @faqDeliveryTime.
  ///
  /// In sq, this message translates to:
  /// **'Sa kohë zgjat dërgesa?'**
  String get faqDeliveryTime;

  /// No description provided for @faqTrackOrderAnswer.
  ///
  /// In sq, this message translates to:
  /// **'Mund ta ndjekësh porosinë në seksionin «Porositë e mia» te profili yt.'**
  String get faqTrackOrderAnswer;

  /// No description provided for @faqPaymentMethodsAnswer.
  ///
  /// In sq, this message translates to:
  /// **'Pranojmë pagesë me para në dorëzim, kartë dhe transfer bankar.'**
  String get faqPaymentMethodsAnswer;

  /// No description provided for @faqDeliveryTimeAnswer.
  ///
  /// In sq, this message translates to:
  /// **'Dërgesa zakonisht zgjat 1–3 ditë pune, në varësi të lokacionit.'**
  String get faqDeliveryTimeAnswer;

  /// No description provided for @aboutTagline.
  ///
  /// In sq, this message translates to:
  /// **'Dyqani juaj premium për verëra, spirits dhe aksesorë të zgjedhur me kujdes.'**
  String get aboutTagline;

  /// No description provided for @aboutMissionTitle.
  ///
  /// In sq, this message translates to:
  /// **'Misioni ynë'**
  String get aboutMissionTitle;

  /// No description provided for @aboutMissionBody.
  ///
  /// In sq, this message translates to:
  /// **'Ofrojmë produkte cilësore me shërbim të shkëlqyer dhe përvojë blerjeje moderne për klientët tanë premium.'**
  String get aboutMissionBody;

  /// No description provided for @aboutVersionTitle.
  ///
  /// In sq, this message translates to:
  /// **'Versioni'**
  String get aboutVersionTitle;

  /// No description provided for @aboutVersionValue.
  ///
  /// In sq, this message translates to:
  /// **'1.0.0'**
  String get aboutVersionValue;

  /// No description provided for @termsIntro.
  ///
  /// In sq, this message translates to:
  /// **'Duke përdorur aplikacionin Cava Premium, ju pranoni kushtet e mëposhtme të përdorimit.'**
  String get termsIntro;

  /// No description provided for @termsSection1Title.
  ///
  /// In sq, this message translates to:
  /// **'1. Përdorimi i shërbimit'**
  String get termsSection1Title;

  /// No description provided for @termsSection1Body.
  ///
  /// In sq, this message translates to:
  /// **'Aplikacioni ofrohet për blerje produktesh të ligjshme nga persona të moshës 18 vjeç e lart.'**
  String get termsSection1Body;

  /// No description provided for @termsSection2Title.
  ///
  /// In sq, this message translates to:
  /// **'2. Porositë'**
  String get termsSection2Title;

  /// No description provided for @termsSection2Body.
  ///
  /// In sq, this message translates to:
  /// **'Çmimet dhe disponueshmëria e produkteve mund të ndryshojnë. Porosia konfirmohet pas pranimit të pagesës.'**
  String get termsSection2Body;

  /// No description provided for @termsSection3Title.
  ///
  /// In sq, this message translates to:
  /// **'3. Përgjegjësia'**
  String get termsSection3Title;

  /// No description provided for @termsSection3Body.
  ///
  /// In sq, this message translates to:
  /// **'Cava Premium përpiqet të ofrojë informacion të saktë, por nuk mban përgjegjësi për gabime teknike të përkohshme.'**
  String get termsSection3Body;

  /// No description provided for @privacyIntro.
  ///
  /// In sq, this message translates to:
  /// **'Cava Premium respekton privatësinë tuaj dhe mbron të dhënat personale që na besoni.'**
  String get privacyIntro;

  /// No description provided for @privacyDataTitle.
  ///
  /// In sq, this message translates to:
  /// **'Të dhënat që mbledhim'**
  String get privacyDataTitle;

  /// No description provided for @privacyDataBody.
  ///
  /// In sq, this message translates to:
  /// **'Mund të mbledhim emrin, email-in, adresën e dërgesës dhe historikun e porosive për të përpunuar blerjet tuaja.'**
  String get privacyDataBody;

  /// No description provided for @privacyUseTitle.
  ///
  /// In sq, this message translates to:
  /// **'Si i përdorim'**
  String get privacyUseTitle;

  /// No description provided for @privacyUseBody.
  ///
  /// In sq, this message translates to:
  /// **'Të dhënat përdoren për përpunimin e porosive, komunikimin me klientët dhe përmirësimin e shërbimit.'**
  String get privacyUseBody;

  /// No description provided for @privacySecurityTitle.
  ///
  /// In sq, this message translates to:
  /// **'Siguria'**
  String get privacySecurityTitle;

  /// No description provided for @privacySecurityBody.
  ///
  /// In sq, this message translates to:
  /// **'Aplikojmë masa të arsyeshme sigurie për të mbrojtur informacionin tuaj nga aksesi i paautorizuar.'**
  String get privacySecurityBody;

  /// No description provided for @supportTitle.
  ///
  /// In sq, this message translates to:
  /// **'Support'**
  String get supportTitle;

  /// No description provided for @supportSubtitle.
  ///
  /// In sq, this message translates to:
  /// **'Jemi këtu për t\'ju ndihmuar'**
  String get supportSubtitle;

  /// No description provided for @supportLoginRequired.
  ///
  /// In sq, this message translates to:
  /// **'Kyçu për të kontaktuar support-in.'**
  String get supportLoginRequired;

  /// No description provided for @supportHowCanWeHelp.
  ///
  /// In sq, this message translates to:
  /// **'Si mund t\'ju ndihmojmë?'**
  String get supportHowCanWeHelp;

  /// No description provided for @supportIntro.
  ///
  /// In sq, this message translates to:
  /// **'Pyet për produkte, porosi, dërgesa ose çdo gjë tjetër rreth Cava Premium.'**
  String get supportIntro;

  /// No description provided for @supportConversation.
  ///
  /// In sq, this message translates to:
  /// **'Biseda'**
  String get supportConversation;

  /// No description provided for @supportWriteQuestion.
  ///
  /// In sq, this message translates to:
  /// **'Shkruaj pyetjen tënde'**
  String get supportWriteQuestion;

  /// No description provided for @supportQuestionHint.
  ///
  /// In sq, this message translates to:
  /// **'P.sh. A e keni këtë verë në stok?'**
  String get supportQuestionHint;

  /// No description provided for @supportSendQuestion.
  ///
  /// In sq, this message translates to:
  /// **'Dërgo pyetjen'**
  String get supportSendQuestion;

  /// No description provided for @supportHoursTitle.
  ///
  /// In sq, this message translates to:
  /// **'Orari i supportit'**
  String get supportHoursTitle;

  /// No description provided for @supportHoursValue.
  ///
  /// In sq, this message translates to:
  /// **'E Hënë – E Shtunë, 09:00 – 20:00'**
  String get supportHoursValue;

  /// No description provided for @supportMessageEmpty.
  ///
  /// In sq, this message translates to:
  /// **'Mesazhi nuk mund të jetë bosh.'**
  String get supportMessageEmpty;

  /// No description provided for @supportMessageTooLong.
  ///
  /// In sq, this message translates to:
  /// **'Mesazhi është shumë i gjatë (max 2000).'**
  String get supportMessageTooLong;

  /// No description provided for @supportAdminRequired.
  ///
  /// In sq, this message translates to:
  /// **'Duhet të jeni të kyçur si admin.'**
  String get supportAdminRequired;

  /// No description provided for @supportConversationNotFound.
  ///
  /// In sq, this message translates to:
  /// **'Biseda nuk u gjet.'**
  String get supportConversationNotFound;

  /// No description provided for @supportReplyNotificationTitle.
  ///
  /// In sq, this message translates to:
  /// **'Përgjigje nga Support'**
  String get supportReplyNotificationTitle;

  /// No description provided for @supportStatusOpen.
  ///
  /// In sq, this message translates to:
  /// **'Hapur'**
  String get supportStatusOpen;

  /// No description provided for @supportStatusPending.
  ///
  /// In sq, this message translates to:
  /// **'Në pritje'**
  String get supportStatusPending;

  /// No description provided for @supportStatusResolved.
  ///
  /// In sq, this message translates to:
  /// **'Zgjidhur'**
  String get supportStatusResolved;

  /// No description provided for @supportStatusClosed.
  ///
  /// In sq, this message translates to:
  /// **'Mbyllur'**
  String get supportStatusClosed;

  /// No description provided for @notificationsTitle.
  ///
  /// In sq, this message translates to:
  /// **'Njoftimet'**
  String get notificationsTitle;

  /// No description provided for @notificationsUnreadToday.
  ///
  /// In sq, this message translates to:
  /// **'{count} të reja sot'**
  String notificationsUnreadToday(int count);

  /// No description provided for @notificationsNoNew.
  ///
  /// In sq, this message translates to:
  /// **'Nuk ka njoftime të reja'**
  String get notificationsNoNew;

  /// No description provided for @notificationsLoadFailed.
  ///
  /// In sq, this message translates to:
  /// **'Njoftimet nuk u ngarkuan.'**
  String get notificationsLoadFailed;

  /// No description provided for @notificationsEmpty.
  ///
  /// In sq, this message translates to:
  /// **'Nuk keni njoftime.'**
  String get notificationsEmpty;

  /// No description provided for @relativeYesterday.
  ///
  /// In sq, this message translates to:
  /// **'Dje'**
  String get relativeYesterday;

  /// No description provided for @weekdayMon.
  ///
  /// In sq, this message translates to:
  /// **'Hën'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In sq, this message translates to:
  /// **'Mar'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In sq, this message translates to:
  /// **'Mër'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In sq, this message translates to:
  /// **'Enj'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In sq, this message translates to:
  /// **'Pre'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In sq, this message translates to:
  /// **'Sht'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In sq, this message translates to:
  /// **'Die'**
  String get weekdaySun;

  /// No description provided for @monthJan.
  ///
  /// In sq, this message translates to:
  /// **'Jan'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In sq, this message translates to:
  /// **'Shk'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In sq, this message translates to:
  /// **'Mar'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In sq, this message translates to:
  /// **'Pri'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In sq, this message translates to:
  /// **'Maj'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In sq, this message translates to:
  /// **'Qer'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In sq, this message translates to:
  /// **'Kor'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In sq, this message translates to:
  /// **'Gus'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In sq, this message translates to:
  /// **'Sht'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In sq, this message translates to:
  /// **'Tet'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In sq, this message translates to:
  /// **'Nën'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In sq, this message translates to:
  /// **'Dhj'**
  String get monthDec;

  /// No description provided for @messagesTitle.
  ///
  /// In sq, this message translates to:
  /// **'Mesazhe'**
  String get messagesTitle;

  /// No description provided for @messagesSupportName.
  ///
  /// In sq, this message translates to:
  /// **'Cava Premium Support'**
  String get messagesSupportName;

  /// No description provided for @messagesSupportPreview.
  ///
  /// In sq, this message translates to:
  /// **'Porosia juaj #CP-2024-01568 është në rrugëtim.'**
  String get messagesSupportPreview;

  /// No description provided for @messagesOffersName.
  ///
  /// In sq, this message translates to:
  /// **'Ofertat Speciale'**
  String get messagesOffersName;

  /// No description provided for @messagesOffersPreview.
  ///
  /// In sq, this message translates to:
  /// **'Zbritje 15% për verërat italiane këtë javë.'**
  String get messagesOffersPreview;

  /// No description provided for @messagesCartName.
  ///
  /// In sq, this message translates to:
  /// **'Kujtesë Shporte'**
  String get messagesCartName;

  /// No description provided for @messagesCartPreview.
  ///
  /// In sq, this message translates to:
  /// **'Keni 2 produkte në shportë. Përfundoni blerjen!'**
  String get messagesCartPreview;

  /// No description provided for @ownerDashboardTitle.
  ///
  /// In sq, this message translates to:
  /// **'Paneli'**
  String get ownerDashboardTitle;

  /// No description provided for @ownerDashboardLoadFailed.
  ///
  /// In sq, this message translates to:
  /// **'Dashboard nuk u ngarkua.'**
  String get ownerDashboardLoadFailed;

  /// No description provided for @ownerDashboardLoadFailedRetry.
  ///
  /// In sq, this message translates to:
  /// **'Dashboard nuk u ngarkua. Provo përsëri.'**
  String get ownerDashboardLoadFailedRetry;

  /// No description provided for @ownerDashboardForbidden.
  ///
  /// In sq, this message translates to:
  /// **'Nuk ke të drejta për dashboard-in e pronarit.'**
  String get ownerDashboardForbidden;

  /// No description provided for @ownerNoDataYet.
  ///
  /// In sq, this message translates to:
  /// **'Nuk ka të dhëna ende.'**
  String get ownerNoDataYet;

  /// No description provided for @ownerSummary.
  ///
  /// In sq, this message translates to:
  /// **'Përmbledhje'**
  String get ownerSummary;

  /// No description provided for @ownerSummarySource.
  ///
  /// In sq, this message translates to:
  /// **'Burimi: statsDaily / stats (si Overview admin)'**
  String get ownerSummarySource;

  /// No description provided for @ownerSalesToday.
  ///
  /// In sq, this message translates to:
  /// **'Shitjet Sot'**
  String get ownerSalesToday;

  /// No description provided for @ownerTodayOrders.
  ///
  /// In sq, this message translates to:
  /// **'Porositë e sotme'**
  String get ownerTodayOrders;

  /// No description provided for @ownerNoTodayOrders.
  ///
  /// In sq, this message translates to:
  /// **'Nuk ka porosi sot.'**
  String get ownerNoTodayOrders;

  /// No description provided for @ownerTodayOrdersCount.
  ///
  /// In sq, this message translates to:
  /// **'{count} porosi sot'**
  String ownerTodayOrdersCount(int count);

  /// No description provided for @ownerSales7Days.
  ///
  /// In sq, this message translates to:
  /// **'Shitjet 7 ditë'**
  String get ownerSales7Days;

  /// No description provided for @ownerSales30Days.
  ///
  /// In sq, this message translates to:
  /// **'Shitjet 30 ditë'**
  String get ownerSales30Days;

  /// No description provided for @ownerTotalRevenue.
  ///
  /// In sq, this message translates to:
  /// **'Totali i të Ardhurave'**
  String get ownerTotalRevenue;

  /// No description provided for @ownerOrdersCount.
  ///
  /// In sq, this message translates to:
  /// **'Numri i Porosive'**
  String get ownerOrdersCount;

  /// No description provided for @ownerOrdersPending.
  ///
  /// In sq, this message translates to:
  /// **'Porosi në Pritje'**
  String get ownerOrdersPending;

  /// No description provided for @ownerOrdersProcessing.
  ///
  /// In sq, this message translates to:
  /// **'Porosi në Proces'**
  String get ownerOrdersProcessing;

  /// No description provided for @ownerOrdersCompleted.
  ///
  /// In sq, this message translates to:
  /// **'Porosi të Përfunduara'**
  String get ownerOrdersCompleted;

  /// No description provided for @ownerOrdersCancelled.
  ///
  /// In sq, this message translates to:
  /// **'Porosi të Anuluara'**
  String get ownerOrdersCancelled;

  /// No description provided for @ownerSalesChart.
  ///
  /// In sq, this message translates to:
  /// **'Shitjet · 7 ditë'**
  String get ownerSalesChart;

  /// No description provided for @ownerSalesChartSubtitle.
  ///
  /// In sq, this message translates to:
  /// **'Të ardhurat ditore'**
  String get ownerSalesChartSubtitle;

  /// No description provided for @ownerOrderPipeline.
  ///
  /// In sq, this message translates to:
  /// **'Statusi i porosive'**
  String get ownerOrderPipeline;

  /// No description provided for @ownerOrderPipelineSubtitle.
  ///
  /// In sq, this message translates to:
  /// **'30 ditët e fundit'**
  String get ownerOrderPipelineSubtitle;

  /// No description provided for @ownerPeriodOverview.
  ///
  /// In sq, this message translates to:
  /// **'Përmbledhje periudhash'**
  String get ownerPeriodOverview;

  /// No description provided for @ownerRecentOrders.
  ///
  /// In sq, this message translates to:
  /// **'Porositë e fundit'**
  String get ownerRecentOrders;

  /// No description provided for @ownerLifetimeOrders.
  ///
  /// In sq, this message translates to:
  /// **'Porosi gjithsej'**
  String get ownerLifetimeOrders;

  /// No description provided for @ownerLifetimeShort.
  ///
  /// In sq, this message translates to:
  /// **'Lifetime'**
  String get ownerLifetimeShort;

  /// No description provided for @ownerDays7Short.
  ///
  /// In sq, this message translates to:
  /// **'7 ditë'**
  String get ownerDays7Short;

  /// No description provided for @ownerDays30Short.
  ///
  /// In sq, this message translates to:
  /// **'30 ditë'**
  String get ownerDays30Short;

  /// No description provided for @ownerNoOrders.
  ///
  /// In sq, this message translates to:
  /// **'Nuk ka porosi.'**
  String get ownerNoOrders;

  /// No description provided for @ownerTopSelling.
  ///
  /// In sq, this message translates to:
  /// **'Produktet më të shitura'**
  String get ownerTopSelling;

  /// No description provided for @ownerTopSellingUnavailable.
  ///
  /// In sq, this message translates to:
  /// **'Nuk ofrohet në dashboard-in admin të website-it — pa agregim top-selling.'**
  String get ownerTopSellingUnavailable;

  /// No description provided for @ownerLowStockProducts.
  ///
  /// In sq, this message translates to:
  /// **'Produkte me stok të ulët'**
  String get ownerLowStockProducts;

  /// No description provided for @ownerLowStockThreshold.
  ///
  /// In sq, this message translates to:
  /// **'Pragu web: stock 1–9 · Numër: {count}'**
  String ownerLowStockThreshold(int count);

  /// No description provided for @ownerNoLowStock.
  ///
  /// In sq, this message translates to:
  /// **'Nuk ka produkte me stok të ulët.'**
  String get ownerNoLowStock;

  /// No description provided for @ownerLowStockListFailed.
  ///
  /// In sq, this message translates to:
  /// **'Lista nuk u lexua (kontrollo indeksin Firestore).'**
  String get ownerLowStockListFailed;

  /// No description provided for @ownerThresholdMax.
  ///
  /// In sq, this message translates to:
  /// **'Pragu max: {max}'**
  String ownerThresholdMax(Object max);

  /// No description provided for @ownerCustomers.
  ///
  /// In sq, this message translates to:
  /// **'Klientët'**
  String get ownerCustomers;

  /// No description provided for @ownerCustomersSubtitle.
  ///
  /// In sq, this message translates to:
  /// **'Si Overview admin — shuma e uniqueBuyerCount ditor'**
  String get ownerCustomersSubtitle;

  /// No description provided for @ownerUniqueBuyersLabel.
  ///
  /// In sq, this message translates to:
  /// **'Blerës unikë ditorë (30 ditë)'**
  String get ownerUniqueBuyersLabel;

  /// No description provided for @ownerChartNoData.
  ///
  /// In sq, this message translates to:
  /// **'Nuk ka të dhëna për grafikun.'**
  String get ownerChartNoData;

  /// No description provided for @ownerOrdersTitle.
  ///
  /// In sq, this message translates to:
  /// **'Porositë'**
  String get ownerOrdersTitle;

  /// No description provided for @ownerOrdersTabStore.
  ///
  /// In sq, this message translates to:
  /// **'Porositë'**
  String get ownerOrdersTabStore;

  /// No description provided for @ownerOrdersTabCourier.
  ///
  /// In sq, this message translates to:
  /// **'Postieri'**
  String get ownerOrdersTabCourier;

  /// No description provided for @ownerNoRecentOrders.
  ///
  /// In sq, this message translates to:
  /// **'Nuk ka porosi të fundit.'**
  String get ownerNoRecentOrders;

  /// No description provided for @ownerNoStoreOrders.
  ///
  /// In sq, this message translates to:
  /// **'Nuk ka porosi në dyqan.'**
  String get ownerNoStoreOrders;

  /// No description provided for @ownerNoCourierOrders.
  ///
  /// In sq, this message translates to:
  /// **'Nuk ka porosi te postieri.'**
  String get ownerNoCourierOrders;

  /// No description provided for @ownerAnalyticsTitle.
  ///
  /// In sq, this message translates to:
  /// **'Analitika'**
  String get ownerAnalyticsTitle;

  /// No description provided for @ownerNoData.
  ///
  /// In sq, this message translates to:
  /// **'Nuk ka të dhëna.'**
  String get ownerNoData;

  /// No description provided for @ownerAnalyticsIntro.
  ///
  /// In sq, this message translates to:
  /// **'Të njëjtat burime si Analytics/Overview admin (statsDaily UTC).'**
  String get ownerAnalyticsIntro;

  /// No description provided for @ownerTotalOrdersLifetime.
  ///
  /// In sq, this message translates to:
  /// **'Porosi totale'**
  String get ownerTotalOrdersLifetime;

  /// No description provided for @ownerTotalRevenueLifetime.
  ///
  /// In sq, this message translates to:
  /// **'Të ardhura totale'**
  String get ownerTotalRevenueLifetime;

  /// No description provided for @ownerCompleted30Days.
  ///
  /// In sq, this message translates to:
  /// **'Përfunduar (30 ditë)'**
  String get ownerCompleted30Days;

  /// No description provided for @ownerCancelled30Days.
  ///
  /// In sq, this message translates to:
  /// **'Anuluar / kthyer (30 ditë)'**
  String get ownerCancelled30Days;

  /// No description provided for @ownerAnalyticsRevenueTitle.
  ///
  /// In sq, this message translates to:
  /// **'Të ardhurat'**
  String get ownerAnalyticsRevenueTitle;

  /// No description provided for @ownerAnalyticsOrdersTitle.
  ///
  /// In sq, this message translates to:
  /// **'Statusi i porosive'**
  String get ownerAnalyticsOrdersTitle;

  /// No description provided for @ownerAnalyticsOrdersSubtitle.
  ///
  /// In sq, this message translates to:
  /// **'30 ditët e fundit'**
  String get ownerAnalyticsOrdersSubtitle;

  /// No description provided for @ownerAnalyticsNoChart.
  ///
  /// In sq, this message translates to:
  /// **'Nuk ka të dhëna për grafikun.'**
  String get ownerAnalyticsNoChart;

  /// No description provided for @ownerAnalyticsPendingShort.
  ///
  /// In sq, this message translates to:
  /// **'Pritje'**
  String get ownerAnalyticsPendingShort;

  /// No description provided for @ownerAnalyticsProcessingShort.
  ///
  /// In sq, this message translates to:
  /// **'Proces'**
  String get ownerAnalyticsProcessingShort;

  /// No description provided for @ownerAnalyticsCompletedShort.
  ///
  /// In sq, this message translates to:
  /// **'Përfunduar'**
  String get ownerAnalyticsCompletedShort;

  /// No description provided for @ownerAnalyticsCancelledShort.
  ///
  /// In sq, this message translates to:
  /// **'Anuluar'**
  String get ownerAnalyticsCancelledShort;

  /// No description provided for @ownerProductsTitle.
  ///
  /// In sq, this message translates to:
  /// **'Produktet'**
  String get ownerProductsTitle;

  /// No description provided for @ownerProductsIntro.
  ///
  /// In sq, this message translates to:
  /// **'Agregatet nga stats/productsSummary (si web).'**
  String get ownerProductsIntro;

  /// No description provided for @ownerInStockCount.
  ///
  /// In sq, this message translates to:
  /// **'Në stok (≥10)'**
  String get ownerInStockCount;

  /// No description provided for @ownerLowStockCount.
  ///
  /// In sq, this message translates to:
  /// **'Stok i ulët (1–9)'**
  String get ownerLowStockCount;

  /// No description provided for @ownerOutOfStockCount.
  ///
  /// In sq, this message translates to:
  /// **'Jashtë stoku'**
  String get ownerOutOfStockCount;

  /// No description provided for @ownerLowStockList.
  ///
  /// In sq, this message translates to:
  /// **'Lista stok i ulët'**
  String get ownerLowStockList;

  /// No description provided for @ownerNoListRows.
  ///
  /// In sq, this message translates to:
  /// **'Nuk ka rreshta për listë.'**
  String get ownerNoListRows;

  /// No description provided for @ownerTopSellingMissing.
  ///
  /// In sq, this message translates to:
  /// **'Top selling: nuk ekziston në admin web — pa të dhëna.'**
  String get ownerTopSellingMissing;

  /// No description provided for @ownerProfileTitle.
  ///
  /// In sq, this message translates to:
  /// **'Profili'**
  String get ownerProfileTitle;

  /// No description provided for @ownerRoleLabel.
  ///
  /// In sq, this message translates to:
  /// **'Roli: Owner / Admin'**
  String get ownerRoleLabel;

  /// No description provided for @ownerFallbackName.
  ///
  /// In sq, this message translates to:
  /// **'Pronari'**
  String get ownerFallbackName;

  /// No description provided for @ownerSettingsSection.
  ///
  /// In sq, this message translates to:
  /// **'Cilësimet e app'**
  String get ownerSettingsSection;

  /// No description provided for @ownerSettingsUsers.
  ///
  /// In sq, this message translates to:
  /// **'Përdoruesit e regjistruar'**
  String get ownerSettingsUsers;

  /// No description provided for @ownerSettingsUsersSubtitle.
  ///
  /// In sq, this message translates to:
  /// **'Shiko llogaritë e klientëve'**
  String get ownerSettingsUsersSubtitle;

  /// No description provided for @ownerSettingsStoreBanner.
  ///
  /// In sq, this message translates to:
  /// **'Foto «Na vizitoni fizikisht»'**
  String get ownerSettingsStoreBanner;

  /// No description provided for @ownerSettingsStoreBannerSubtitle.
  ///
  /// In sq, this message translates to:
  /// **'Ndrysho imazhin në faqen kryesore'**
  String get ownerSettingsStoreBannerSubtitle;

  /// No description provided for @ownerSettingsLegal.
  ///
  /// In sq, this message translates to:
  /// **'Dokumente legale'**
  String get ownerSettingsLegal;

  /// No description provided for @ownerSettingsLegalSubtitle.
  ///
  /// In sq, this message translates to:
  /// **'Ngarko PDF për Kushte & Privatësi'**
  String get ownerSettingsLegalSubtitle;

  /// No description provided for @ownerSettingsStoreContact.
  ///
  /// In sq, this message translates to:
  /// **'Kontakt & adresa dyqani'**
  String get ownerSettingsStoreContact;

  /// No description provided for @ownerSettingsStoreContactSubtitle.
  ///
  /// In sq, this message translates to:
  /// **'Email, telefon, Maps'**
  String get ownerSettingsStoreContactSubtitle;

  /// No description provided for @ownerUsersTitle.
  ///
  /// In sq, this message translates to:
  /// **'Përdoruesit'**
  String get ownerUsersTitle;

  /// No description provided for @ownerNoUsers.
  ///
  /// In sq, this message translates to:
  /// **'Nuk ka përdorues të regjistruar.'**
  String get ownerNoUsers;

  /// No description provided for @ownerUsersLoadFailed.
  ///
  /// In sq, this message translates to:
  /// **'Përdoruesit nuk u ngarkuan.'**
  String get ownerUsersLoadFailed;

  /// No description provided for @ownerStoreBannerTitle.
  ///
  /// In sq, this message translates to:
  /// **'Banner i dyqanit'**
  String get ownerStoreBannerTitle;

  /// No description provided for @ownerStoreBannerHint.
  ///
  /// In sq, this message translates to:
  /// **'Kjo foto shfaqet në «Na vizitoni fizikisht» në Home.'**
  String get ownerStoreBannerHint;

  /// No description provided for @ownerUploadPhoto.
  ///
  /// In sq, this message translates to:
  /// **'Ngarko foto'**
  String get ownerUploadPhoto;

  /// No description provided for @ownerChangePhoto.
  ///
  /// In sq, this message translates to:
  /// **'Ndrysho foton'**
  String get ownerChangePhoto;

  /// No description provided for @ownerSaveContact.
  ///
  /// In sq, this message translates to:
  /// **'Ruaj kontaktin'**
  String get ownerSaveContact;

  /// No description provided for @ownerStoreAddressLabel.
  ///
  /// In sq, this message translates to:
  /// **'Adresa e dyqanit'**
  String get ownerStoreAddressLabel;

  /// No description provided for @ownerMapsUrlLabel.
  ///
  /// In sq, this message translates to:
  /// **'URL e Google Maps'**
  String get ownerMapsUrlLabel;

  /// No description provided for @ownerContactEmailLabel.
  ///
  /// In sq, this message translates to:
  /// **'Email kontakt'**
  String get ownerContactEmailLabel;

  /// No description provided for @ownerContactPhoneLabel.
  ///
  /// In sq, this message translates to:
  /// **'Telefon kontakt'**
  String get ownerContactPhoneLabel;

  /// No description provided for @ownerUploadSuccess.
  ///
  /// In sq, this message translates to:
  /// **'U ruajt me sukses.'**
  String get ownerUploadSuccess;

  /// No description provided for @ownerUploadFailed.
  ///
  /// In sq, this message translates to:
  /// **'Ngarkimi dështoi.'**
  String get ownerUploadFailed;

  /// No description provided for @ownerLegalDocsTitle.
  ///
  /// In sq, this message translates to:
  /// **'Dokumente legale'**
  String get ownerLegalDocsTitle;

  /// No description provided for @ownerLegalTermsPdf.
  ///
  /// In sq, this message translates to:
  /// **'Kushtet e përdorimit (PDF)'**
  String get ownerLegalTermsPdf;

  /// No description provided for @ownerLegalPrivacyPdf.
  ///
  /// In sq, this message translates to:
  /// **'Politika e privatësisë (PDF)'**
  String get ownerLegalPrivacyPdf;

  /// No description provided for @ownerUploadPdf.
  ///
  /// In sq, this message translates to:
  /// **'Ngarko PDF'**
  String get ownerUploadPdf;

  /// No description provided for @ownerReplacePdf.
  ///
  /// In sq, this message translates to:
  /// **'Zëvendëso PDF'**
  String get ownerReplacePdf;

  /// No description provided for @ownerOpenPdf.
  ///
  /// In sq, this message translates to:
  /// **'Hap dokumentin PDF'**
  String get ownerOpenPdf;

  /// No description provided for @ownerPdfUploaded.
  ///
  /// In sq, this message translates to:
  /// **'PDF i ngarkuar'**
  String get ownerPdfUploaded;

  /// No description provided for @ownerPdfMissing.
  ///
  /// In sq, this message translates to:
  /// **'Nuk ka PDF të ngarkuar ende.'**
  String get ownerPdfMissing;

  /// No description provided for @ownerNoPdfSelected.
  ///
  /// In sq, this message translates to:
  /// **'Nuk u zgjodh asnjë skedar PDF.'**
  String get ownerNoPdfSelected;

  /// No description provided for @ownerFulfillmentReceived.
  ///
  /// In sq, this message translates to:
  /// **'Pranuar'**
  String get ownerFulfillmentReceived;

  /// No description provided for @ownerFulfillmentConfirmed.
  ///
  /// In sq, this message translates to:
  /// **'Konfirmuar'**
  String get ownerFulfillmentConfirmed;

  /// No description provided for @ownerFulfillmentPrepared.
  ///
  /// In sq, this message translates to:
  /// **'Përgatitur'**
  String get ownerFulfillmentPrepared;

  /// No description provided for @ownerFulfillmentShipped.
  ///
  /// In sq, this message translates to:
  /// **'Dërguar'**
  String get ownerFulfillmentShipped;

  /// No description provided for @ownerFulfillmentInTransit.
  ///
  /// In sq, this message translates to:
  /// **'Në tranzit'**
  String get ownerFulfillmentInTransit;

  /// No description provided for @ownerFulfillmentDelivered.
  ///
  /// In sq, this message translates to:
  /// **'Përfunduar'**
  String get ownerFulfillmentDelivered;

  /// No description provided for @ownerFulfillmentReturned.
  ///
  /// In sq, this message translates to:
  /// **'Kthyer'**
  String get ownerFulfillmentReturned;

  /// No description provided for @ownerFulfillmentCanceled.
  ///
  /// In sq, this message translates to:
  /// **'Anuluar'**
  String get ownerFulfillmentCanceled;

  /// No description provided for @ownerFulfillmentUnfulfilled.
  ///
  /// In sq, this message translates to:
  /// **'Pa përmbushur'**
  String get ownerFulfillmentUnfulfilled;

  /// No description provided for @ownerSupportTitle.
  ///
  /// In sq, this message translates to:
  /// **'Support'**
  String get ownerSupportTitle;

  /// No description provided for @ownerSendNotification.
  ///
  /// In sq, this message translates to:
  /// **'Dërgo njoftim'**
  String get ownerSendNotification;

  /// No description provided for @ownerRecipientUid.
  ///
  /// In sq, this message translates to:
  /// **'UID i marrësit'**
  String get ownerRecipientUid;

  /// No description provided for @ownerNotificationTitle.
  ///
  /// In sq, this message translates to:
  /// **'Titulli'**
  String get ownerNotificationTitle;

  /// No description provided for @ownerNotificationBody.
  ///
  /// In sq, this message translates to:
  /// **'Teksti'**
  String get ownerNotificationBody;

  /// No description provided for @ownerNotificationTypeGeneral.
  ///
  /// In sq, this message translates to:
  /// **'General'**
  String get ownerNotificationTypeGeneral;

  /// No description provided for @ownerNotificationTypePromotion.
  ///
  /// In sq, this message translates to:
  /// **'Promotion'**
  String get ownerNotificationTypePromotion;

  /// No description provided for @ownerNotificationSent.
  ///
  /// In sq, this message translates to:
  /// **'Njoftimi u dërgua.'**
  String get ownerNotificationSent;

  /// No description provided for @ownerNotificationFailed.
  ///
  /// In sq, this message translates to:
  /// **'Dështoi.'**
  String get ownerNotificationFailed;

  /// No description provided for @ownerFilterAll.
  ///
  /// In sq, this message translates to:
  /// **'Të gjitha'**
  String get ownerFilterAll;

  /// No description provided for @ownerNoConversations.
  ///
  /// In sq, this message translates to:
  /// **'Nuk ka biseda.'**
  String get ownerNoConversations;

  /// No description provided for @ownerConversationFallback.
  ///
  /// In sq, this message translates to:
  /// **'Biseda'**
  String get ownerConversationFallback;

  /// No description provided for @ownerAssignToMe.
  ///
  /// In sq, this message translates to:
  /// **'Cakto mua'**
  String get ownerAssignToMe;

  /// No description provided for @ownerNoMessages.
  ///
  /// In sq, this message translates to:
  /// **'Nuk ka mesazhe.'**
  String get ownerNoMessages;

  /// No description provided for @ownerReplyHint.
  ///
  /// In sq, this message translates to:
  /// **'Përgjigju...'**
  String get ownerReplyHint;

  /// No description provided for @ownerNotificationFieldsRequired.
  ///
  /// In sq, this message translates to:
  /// **'Plotëso titullin, tekstin dhe UID.'**
  String get ownerNotificationFieldsRequired;

  /// No description provided for @ownerNotificationTypeInvalid.
  ///
  /// In sq, this message translates to:
  /// **'Lloji duhet të jetë promotion ose general.'**
  String get ownerNotificationTypeInvalid;

  /// No description provided for @editProfileTitle.
  ///
  /// In sq, this message translates to:
  /// **'Edito profilin'**
  String get editProfileTitle;

  /// No description provided for @guestName.
  ///
  /// In sq, this message translates to:
  /// **'Mysafir'**
  String get guestName;

  /// No description provided for @tapToLogin.
  ///
  /// In sq, this message translates to:
  /// **'Trokit për t\'u kyçur'**
  String get tapToLogin;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sq'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sq':
      return AppLocalizationsSq();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
