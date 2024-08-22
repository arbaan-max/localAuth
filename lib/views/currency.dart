import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class CurrencyFormatterScreen extends StatefulWidget {
  const CurrencyFormatterScreen({super.key});

  @override
  State<CurrencyFormatterScreen> createState() => _CurrencyFormatterScreenState();
}

class _CurrencyFormatterScreenState extends State<CurrencyFormatterScreen> {
  double earnedCoins = 200; // Coins earned by the user
  String selectedLocale = Intl.getCurrentLocale(); // Default locale
  late NumberFormat currencyFormatter; // Currency formatter
  List<String> filteredLocales = []; // Filtered list of locales
  TextEditingController searchController = TextEditingController(); // Search controller

  String currentCountry = 'Loading...';
  String selectedCountry = 'Loading...';
  String loc = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    filteredLocales = locales.keys.toList(); // Initialize filtered locales
    currencyFormatter = NumberFormat.simpleCurrency(locale: 'en_IN'); // Initialize currency formatter
  }

  void _filterLocales(String query) {
    setState(() {
      filteredLocales = locales.keys.where((country) => country.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  void _showLocaleDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: TextFormField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: 'Search Country',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _filterLocales(value);
                  });
                },
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: ListView.builder(
                  itemCount: filteredLocales.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(filteredLocales[index]),
                      onTap: () {
                        _updateCurrencyFormat(locales[filteredLocales[index]]!);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _updateCurrencyFormat(String newLocale) {
    setState(() {
      selectedLocale = newLocale;
      currencyFormatter = NumberFormat.simpleCurrency(locale: selectedLocale);
      if (!conversionRates.containsKey(selectedCountry)) {
        selectedCountry = 'USD';
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await _determinePosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks[0];

      setState(() {
        loc = place.country ?? 'Unknown';
        currentCountry = place.country ?? 'Unknown';
        selectedCountry = currentCountry;
        currencyFormatter = NumberFormat.simpleCurrency(locale: loc);
      });
    } catch (e) {
      setState(() {
        currentCountry = 'Failed to get country';
        selectedCountry = currentCountry;
        currencyFormatter = NumberFormat.simpleCurrency(locale: 'en_IN');
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    // Get the conversion rate for the selected country
    String country = locales.entries.firstWhere((entry) => entry.value == selectedLocale).key;
    double conversionRate = conversionRates[country] ?? 1.0;

    // Calculate the converted amount
    double convertedAmount = earnedCoins * conversionRate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Formatter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _showLocaleDialog,
              child: const Text('Select Country'),
            ),
            const SizedBox(height: 20),
            Text(
              'Earned: $earnedCoins coins',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 10),
            Text(
              'Converted: ${currencyFormatter.format(convertedAmount)}',
              style: const TextStyle(fontSize: 24, color: Colors.blue),
            ),
            const SizedBox(height: 10),
            Text(
              'Currency Name: ${currencyFormatter.currencyName}',
              style: const TextStyle(fontSize: 24, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              'Currency Symbol: ${currencyFormatter.currencySymbol}',
              style: const TextStyle(fontSize: 24),
            ),
        
          
          ],
        ),
      ),
    );
  }
}

Map<String, double> conversionRates = {
  // 'Afghanistan': 0.0125, // 800 coins = 1 AFN
  // 'Albania': 0.01, // 100 coins = 1 ALL
  // 'Algeria': 0.0074, // 135 coins = 1 DZD
  // 'Andorra': 0.01, // 100 coins = 1 EUR (Euro)
  // 'Angola': 0.0005, // 2000 coins = 1 AOA
  'Antigua and Barbuda': 0.0037, // 270 coins = 1 XCD
  'Argentina': 0.0025, // 400 coins = 1 ARS
  'Armenia': 0.002, // 500 coins = 1 AMD
  'Australia': 0.01, // 100 coins = 1 AUD
  'Austria': 0.01, // 100 coins = 1 EUR (Euro)
  'Azerbaijan': 0.01, // 100 coins = 1 AZN
  'Bahamas': 0.01, // 100 coins = 1 BSD
  'Bahrain': 0.0026, // 385 coins = 1 BHD
  'Bangladesh': 0.00001, // 10000 coins = 1 BDT
  'Barbados': 0.005, // 200 coins = 1 BBD
  'Belarus': 0.003, // 333 coins = 1 BYN
  'Belgium': 0.01, // 100 coins = 1 EUR (Euro)
  'Belize': 0.005, // 200 coins = 1 BZD
  'Benin': 0.01, // 100 coins = 1 XOF
  'Bhutan': 0.01, // 100 coins = 1 BTN
  'Bolivia': 0.0014, // 714 coins = 1 BOB
  'Bosnia and Herzegovina': 0.005, // 200 coins = 1 BAM
  'Botswana': 0.0077, // 130 coins = 1 BWP
  'Brazil': 0.00025, // 4000 coins = 1 BRL
  'Brunei': 0.0075, // 133 coins = 1 BND
  'Bulgaria': 0.005, // 200 coins = 1 BGN
  'Burkina Faso': 0.01, // 100 coins = 1 XOF
  'Burundi': 0.00001, // 10000 coins = 1 BIF
  'Cabo Verde': 0.001, // 1000 coins = 1 CVE
  'Cambodia': 0.000025, // 40000 coins = 1 KHR
  'Cameroon': 0.01, // 100 coins = 1 XAF
  'Canada': 0.01, // 100 coins = 1 CAD
  'Central African Republic': 0.01, // 100 coins = 1 XAF
  'Chad': 0.01, // 100 coins = 1 XAF
  'Chile': 0.00125, // 800 coins = 1 CLP
  'China': 0.00015, // 6666 coins = 1 CNY
  'Colombia': 0.00005, // 20000 coins = 1 COP
  'Comoros': 0.01, // 100 coins = 1 KMF
  'Congo, Republic of the': 0.01, // 100 coins = 1 XAF
  'Congo, Democratic Republic of the': 0.00005, // 20000 coins = 1 CDF
  'Costa Rica': 0.000015, // 66666 coins = 1 CRC
  'Croatia': 0.0015, // 666 coins = 1 HRK
  'Cuba': 0.01, // 100 coins = 1 CUP
  'Cyprus': 0.01, // 100 coins = 1 EUR (Euro)
  'Czech Republic': 0.00045, // 2222 coins = 1 CZK
  'Denmark': 0.0015, // 666 coins = 1 DKK
  'Djibouti': 0.01, // 100 coins = 1 DJF
  'Dominica': 0.0037, // 270 coins = 1 XCD
  'Dominican Republic': 0.00018, // 5555 coins = 1 DOP
  'Ecuador': 0.000125, // 8000 coins = 1 USD (uses USD)
  'Egypt': 0.00032, // 3125 coins = 1 EGP
  'El Salvador': 0.000125, // 8000 coins = 1 USD (uses USD)
  'Equatorial Guinea': 0.01, // 100 coins = 1 XAF
  'Eritrea': 0.0067, // 150 coins = 1 ERN
  'Estonia': 0.01, // 100 coins = 1 EUR (Euro)
  'Eswatini': 0.00066, // 1515 coins = 1 SZL
  'Ethiopia': 0.00018, // 5555 coins = 1 ETB
  'Fiji': 0.0047, // 212 coins = 1 FJD
  'Finland': 0.01, // 100 coins = 1 EUR (Euro)
  'France': 0.01, // 100 coins = 1 EUR (Euro)
  'Gabon': 0.01, // 100 coins = 1 XAF
  'Gambia': 0.00018, // 5555 coins = 1 GMD
  'Georgia': 0.0028, // 357 coins = 1 GEL
  'Germany': 0.01, // 100 coins = 1 EUR (Euro)
  'Ghana': 0.000086, // 11627 coins = 1 GHS
  'Greece': 0.01, // 100 coins = 1 EUR (Euro)
  'Grenada': 0.0037, // 270 coins = 1 XCD
  'Guatemala': 0.000125, // 8000 coins = 1 GTQ
  'Guinea': 0.00001, // 10000 coins = 1 GNF
  'Guinea-Bissau': 0.01, // 100 coins = 1 XOF
  'Guyana': 0.0006, // 1666 coins = 1 GYD
  'Haiti': 0.00018, // 5555 coins = 1 HTG
  'Honduras': 0.00041, // 2439 coins = 1 HNL
  'Hungary': 0.00027, // 3703 coins = 1 HUF
  'Iceland': 0.00075, // 1333 coins = 1 ISK
  'India': 0.01, // 100 coins = 1 INR
  'Indonesia': 0.0000066, // 151515 coins = 1 IDR
  'Iran': 0.0000025, // 400000 coins = 1 IRR
  'Iraq': 0.000068, // 14705 coins = 1 IQD
  'Ireland': 0.01, // 100 coins = 1 EUR (Euro)
  'Israel': 0.0031, // 322 coins = 1 ILS
  'Italy': 0.01, // 100 coins = 1 EUR (Euro)
  'Jamaica': 0.00065, // 1538 coins = 1 JMD
  'Japan': 0.00069, // 1449 coins = 1 JPY
  'Jordan': 0.0014, // 714 coins = 1 JOD
  'Kazakhstan': 0.000022, // 45454 coins = 1 KZT
  'Kenya': 0.000067, // 14925 coins = 1 KES
  'Kiribati': 0.000125, // 8000 coins = 1 AUD (uses AUD)
  'Korea, North': 0.0011, // 909 coins = 1 KPW
  'Korea, South': 0.000083, // 12048 coins = 1 KRW
  'Kuwait': 0.0033, // 303 coins = 1 KWD
  'Kyrgyzstan': 0.000012, // 83333 coins = 1 KGS
  'Laos': 0.0000005, // 2000000 coins = 1 LAK
  'Latvia': 0.01, // 100 coins = 1 EUR (Euro)
  'Lebanon': 0.000000067, // 14925373 coins = 1 LBP
  'Lesotho': 0.000066, // 15151 coins = 1 LSL
  'Liberia': 0.000052, // 19231 coins = 1 LRD
  'Libya': 0.0015, // 666 coins = 1 LYD
  'Liechtenstein': 0.01, // 100 coins = 1 CHF
  'Lithuania': 0.01, // 100 coins = 1 EUR (Euro)
  'Luxembourg': 0.01, // 100 coins = 1 EUR (Euro)
  'Madagascar': 0.000015, // 66666 coins = 1 MGA
  'Malawi': 0.00001, // 100000 coins = 1 MWK
  'Malaysia': 0.0022, // 454 coins = 1 MYR
  'Maldives': 0.00058, // 1724 coins = 1 MVR
  'Mali': 0.01, // 100 coins = 1 XOF
  'Malta': 0.01, // 100 coins = 1 EUR (Euro)
  'Marshall Islands': 0.000125, // 8000 coins = 1 USD (uses USD)
  'Mauritania': 0.00029, // 3448 coins = 1 MRU
  'Mauritius': 0.0022, // 454 coins = 1 MUR
  'Mexico': 0.00075, // 1333 coins = 1 MXN
  'Micronesia': 0.000125, // 8000 coins = 1 USD (uses USD)
  'Moldova': 0.000056, // 17857 coins = 1 MDL
  'Monaco': 0.01, // 100 coins = 1 EUR (Euro)
  'Mongolia': 0.000017, // 58823 coins = 1 MNT
  'Montenegro': 0.01, // 100 coins = 1 EUR (Euro)
  'Morocco': 0.001, // 1000 coins = 1 MAD
  'Mozambique': 0.000015, // 66666 coins = 1 MZN
  'Myanmar': 0.000016, // 62500 coins = 1 MMK
  'Namibia': 0.000066, // 15151 coins = 1 NAD
  'Nauru': 0.000125, // 8000 coins = 1 AUD (uses AUD)
  'Nepal': 0.000008, // 125000 coins = 1 NPR
  'Netherlands': 0.01, // 100 coins = 1 EUR (Euro)
  'New Zealand': 0.01, // 100 coins = 1 NZD
  'Nicaragua': 0.000034, // 29411 coins = 1 NIO
  'Niger': 0.01, // 100 coins = 1 XOF
  'Nigeria': 0.000011, // 90909 coins = 1 NGN
  'North Macedonia': 0.00017, // 5882 coins = 1 MKD
  'Norway': 0.00091, // 1098 coins = 1 NOK
  'Oman': 0.0026, // 385 coins = 1 OMR
  'Pakistan': 0.000005, // 200000 coins = 1 PKR
  'Palau': 0.000125, // 8000 coins = 1 USD (uses USD)
  'Panama': 0.000125, // 8000 coins = 1 USD (uses USD)
  'Papua New Guinea': 0.000027, // 37037 coins = 1 PGK
  'Paraguay': 0.00000014, // 7142857 coins = 1 PYG
  'Peru': 0.00027, // 3703 coins = 1 PEN
  'Philippines': 0.000017, // 58823 coins = 1 PHP
  'Poland': 0.00023, // 4347 coins = 1 PLN
  'Portugal': 0.01, // 100 coins = 1 EUR (Euro)
  'Qatar': 0.0027, // 370 coins = 1 QAR
  'Romania': 0.00022, // 4545 coins = 1 RON
  'Russia': 0.000015, // 66666 coins = 1 RUB
  'Rwanda': 0.000007, // 142857 coins = 1 RWF
  'Saint Kitts and Nevis': 0.0037, // 270 coins = 1 XCD
  'Saint Lucia': 0.0037, // 270 coins = 1 XCD
  'Saint Vincent and the Grenadines': 0.0037, // 270 coins = 1 XCD
  'Samoa': 0.000366, // 2732 coins = 1 WST
  'San Marino': 0.01, // 100 coins = 1 EUR (Euro)
  'Sao Tome and Principe': 0.0000035, // 285714 coins = 1 STN
  'Saudi Arabia': 0.0027, // 370 coins = 1 SAR
  'Senegal': 0.01, // 100 coins = 1 XOF
  'Serbia': 0.000088, // 11363 coins = 1 RSD
  'Seychelles': 0.000075, // 13333 coins = 1 SCR
  'Sierra Leone': 0.0000016, // 625000 coins = 1 SLL
  'Singapore': 0.0075, // 133 coins = 1 SGD
  'Slovakia': 0.01, // 100 coins = 1 EUR (Euro)
  'Slovenia': 0.01, // 100 coins = 1 EUR (Euro)
  'Solomon Islands': 0.00012, // 8333 coins = 1 SBD
  'Somalia': 0.00000088, // 1136364 coins = 1 SOS
  'South Africa': 0.000055, // 18182 coins = 1 ZAR
  'South Sudan': 0.00011, // 9090 coins = 1 SSP
  'Spain': 0.01, // 100 coins = 1 EUR (Euro)
  'Sri Lanka': 0.00031, // 3226 coins = 1 LKR
  'Sudan': 0.000011, // 90909 coins = 1 SDG
  'Suriname': 0.000028, // 35714 coins = 1 SRD
  'Sweden': 0.00086, // 1162 coins = 1 SEK
  'Switzerland': 0.01, // 100 coins = 1 CHF
  'Syria': 0.00000002, // 50000000 coins = 1 SYP
  'Taiwan': 0.000033, // 30303 coins = 1 TWD
  'Tajikistan': 0.000014, // 71428 coins = 1 TJS
  'Tanzania': 0.000002, // 500000 coins = 1 TZS
  'Thailand': 0.000028, // 35714 coins = 1 THB
  'Timor-Leste': 0.000125, // 8000 coins = 1 USD (uses USD)
  'Togo': 0.01, // 100 coins = 1 XOF
  'Tonga': 0.000374, // 2674 coins = 1 TOP
  'Trinidad and Tobago': 0.00147, // 680 coins = 1 TTD
  'Tunisia': 0.00031, // 3225 coins = 1 TND
  'Turkey': 0.000037, // 27027 coins = 1 TRY
  'Turkmenistan': 0.000036, // 27777 coins = 1 TMT
  'Tuvalu': 0.000125, // 8000 coins = 1 AUD (uses AUD)
  'Uganda': 0.00000027, // 370370 coins = 1 UGX
  'Ukraine': 0.000027, // 37037 coins = 1 UAH
  'United Arab Emirates': 0.0027, // 370 coins = 1 AED
  'United Kingdom': 0.0125, // 80 coins = 1 GBP
  'United States': 0.000125, // 8000 coins = 1 USD
  'Uruguay': 0.000025, // 40000 coins = 1 UYU
  'Uzbekistan': 0.0000085, // 117647 coins = 1 UZS
  'Vanuatu': 0.000084, // 11905 coins = 1 VUV
  'Vatican City': 0.01, // 100 coins = 1 EUR (Euro)
  'Venezuela': 0.0017, // 588 coins = 1 VES
  'Vietnam': 0.000000042, // 2380952 coins = 1 VND
  'Yemen': 0.0000004, // 2500000 coins = 1 YER
  'Zambia': 0.000037, // 27027 coins = 1 ZMW
  'Zimbabwe': 0.000002, // 500000 coins = 1 ZWL
};

Map<String, String> locales = {
  // 'Afghanistan': 'fa_AF',
  // 'Albania': 'sq_AL',
  // 'Algeria': 'ar_DZ',
  // 'Andorra': 'ca_AD',
  // 'Angola': 'pt_AO',
  'Antigua and Barbuda': 'en_AG',
  'Argentina': 'es_AR',
  'Armenia': 'hy_AM',
  'Australia': 'en_AU',
  'Austria': 'de_AT',
  'Azerbaijan': 'az_AZ',
  'Bahamas': 'en_BS',
  'Bahrain': 'ar_BH',
  'Bangladesh': 'bn_BD',
  'Barbados': 'en_BB',
  'Belarus': 'be_BY',
  'Belgium': 'nl_BE',
  'Belize': 'en_BZ',
  'Benin': 'fr_BJ',
  'Bhutan': 'en_BT',
  'Bolivia': 'es_BO',
  'Bosnia and Herzegovina': 'bs_BA',
  'Botswana': 'en_BW',
  'Brazil': 'pt_BR',
  'Brunei': 'ms_BN',
  'Bulgaria': 'bg_BG',
  'Burkina Faso': 'fr_BF',
  'Burundi': 'rn_BI',
  'Cabo Verde': 'pt_CV',
  'Cambodia': 'km_KH',
  'Cameroon': 'fr_CM',
  'Canada': 'en_CA',
  'Central African Republic': 'fr_CF',
  'Chad': 'fr_TD',
  'Chile': 'es_CL',
  'China': 'zh_CN',
  'Colombia': 'es_CO',
  'Comoros': 'ar_KM',
  'Congo, Republic of the': 'fr_CG',
  'Congo, Democratic Republic of the': 'fr_CD',
  'Costa Rica': 'es_CR',
  'Croatia': 'hr_HR',
  'Cuba': 'es_CU',
  'Cyprus': 'el_CY',
  'Czech Republic': 'cs_CZ',
  'Denmark': 'da_DK',
  'Djibouti': 'fr_DJ',
  'Dominica': 'en_DM',
  'Dominican Republic': 'es_DO',
  'Ecuador': 'es_EC',
  'Egypt': 'ar_EG',
  'El Salvador': 'es_SV',
  'Equatorial Guinea': 'es_GQ',
  'Eritrea': 'ti_ER',
  'Estonia': 'et_EE',
  'Eswatini': 'en_SZ',
  'Ethiopia': 'am_ET',
  'Fiji': 'en_FJ',
  'Finland': 'fi_FI',
  'France': 'fr_FR',
  'Gabon': 'fr_GA',
  'Gambia': 'en_GM',
  'Georgia': 'ka_GE',
  'Germany': 'de_DE',
  'Ghana': 'en_GH',
  'Greece': 'el_GR',
  'Grenada': 'en_GD',
  'Guatemala': 'es_GT',
  'Guinea': 'fr_GN',
  'Guinea-Bissau': 'pt_GW',
  'Guyana': 'en_GY',
  'Haiti': 'ht_HT',
  'Honduras': 'es_HN',
  'Hungary': 'hu_HU',
  'Iceland': 'is_IS',
  'India': 'en_IN',
  'Indonesia': 'id_ID',
  'Iran': 'fa_IR',
  'Iraq': 'ar_IQ',
  'Ireland': 'en_IE',
  'Israel': 'he_IL',
  'Italy': 'it_IT',
  'Jamaica': 'en_JM',
  'Japan': 'ja_JP',
  'Jordan': 'ar_JO',
  'Kazakhstan': 'kk_KZ',
  'Kenya': 'en_KE',
  'Kiribati': 'en_KI',
  'Korea, North': 'ko_KP',
  'Korea, South': 'ko_KR',
  'Kuwait': 'ar_KW',
  'Kyrgyzstan': 'ky_KG',
  'Laos': 'lo_LA',
  'Latvia': 'lv_LV',
  'Lebanon': 'ar_LB',
  'Lesotho': 'en_LS',
  'Liberia': 'en_LR',
  'Libya': 'ar_LY',
  'Liechtenstein': 'de_LI',
  'Lithuania': 'lt_LT',
  'Luxembourg': 'lb_LU',
  'Madagascar': 'mg_MG',
  'Malawi': 'en_MW',
  'Malaysia': 'ms_MY',
  'Maldives': 'dv_MV',
  'Mali': 'fr_ML',
  'Malta': 'en_MT',
  'Marshall Islands': 'en_MH',
  'Mauritania': 'ar_MR',
  'Mauritius': 'en_MU',
  'Mexico': 'es_MX',
  'Micronesia': 'en_FM',
  'Moldova': 'ro_MD',
  'Monaco': 'fr_MC',
  'Mongolia': 'mn_MN',
  'Montenegro': 'sr_ME',
  'Morocco': 'ar_MA',
  'Mozambique': 'pt_MZ',
  'Myanmar': 'my_MM',
  'Namibia': 'en_NA',
  'Nauru': 'en_NR',
  'Nepal': 'ne_NP',
  'Netherlands': 'nl_NL',
  'New Zealand': 'en_NZ',
  'Nicaragua': 'es_NI',
  'Niger': 'fr_NE',
  'Nigeria': 'en_NG',
  'North Macedonia': 'mk_MK',
  'Norway': 'no_NO',
  'Oman': 'ar_OM',
  'Pakistan': 'ur_PK',
  'Palau': 'en_PW',
  'Panama': 'es_PA',
  'Papua New Guinea': 'en_PG',
  'Paraguay': 'es_PY',
  'Peru': 'es_PE',
  'Philippines': 'en_PH',
  'Poland': 'pl_PL',
  'Portugal': 'pt_PT',
  'Qatar': 'ar_QA',
  'Romania': 'ro_RO',
  'Russia': 'ru_RU',
  'Rwanda': 'rw_RW',
  'Saint Kitts and Nevis': 'en_KN',
  'Saint Lucia': 'en_LC',
  'Saint Vincent and the Grenadines': 'en_VC',
  'Samoa': 'en_WS',
  'San Marino': 'it_SM',
  'Sao Tome and Principe': 'pt_ST',
  'Saudi Arabia': 'ar_SA',
  'Senegal': 'fr_SN',
  'Serbia': 'sr_RS',
  'Seychelles': 'fr_SC',
  'Sierra Leone': 'en_SL',
  'Singapore': 'en_SG',
  'Slovakia': 'sk_SK',
  'Slovenia': 'sl_SL',
  'Solomon Islands': 'en_SB',
  'Somalia': 'so_SO',
  'South Africa': 'en_ZA',
  'South Sudan': 'en_SS',
  'Spain': 'es_ES',
  'Sri Lanka': 'si_LK',
  'Sudan': 'ar_SD',
  'Suriname': 'nl_SR',
  'Sweden': 'sv_SE',
  'Switzerland': 'de_CH',
  'Syria': 'ar_SY',
  'Taiwan': 'zh_TW',
  'Tajikistan': 'tg_TJ',
  'Tanzania': 'sw_TZ',
  'Thailand': 'th_TH',
  'Timor-Leste': 'tet_TL',
  'Togo': 'fr_TG',
  'Tonga': 'en_TO',
  'Trinidad and Tobago': 'en_TT',
  'Tunisia': 'ar_TN',
  'Turkey': 'tr_TR',
  'Turkmenistan': 'tk_TM',
  'Tuvalu': 'en_TV',
  'Uganda': 'en_UG',
  'Ukraine': 'uk_UA',
  'United Arab Emirates': 'ar_AE',
  'United Kingdom': 'en_GB',
  'United States': 'en_US',
};
