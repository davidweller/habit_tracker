import 'dart:convert';
import 'package:http/http.dart' as http;

// Comprehensive list of countries (primary source)
List<String> _getDefaultCountries() {
  return [
    'Afghanistan',
    'Albania',
    'Algeria',
    'Andorra',
    'Angola',
    'Argentina',
    'Armenia',
    'Australia',
    'Austria',
    'Azerbaijan',
    'Bahamas',
    'Bahrain',
    'Bangladesh',
    'Barbados',
    'Belarus',
    'Belgium',
    'Belize',
    'Benin',
    'Bhutan',
    'Bolivia',
    'Bosnia and Herzegovina',
    'Botswana',
    'Brazil',
    'Brunei',
    'Bulgaria',
    'Burkina Faso',
    'Burundi',
    'Cambodia',
    'Cameroon',
    'Canada',
    'Cape Verde',
    'Central African Republic',
    'Chad',
    'Chile',
    'China',
    'Colombia',
    'Comoros',
    'Congo',
    'Costa Rica',
    'Croatia',
    'Cuba',
    'Cyprus',
    'Czech Republic',
    'Denmark',
    'Djibouti',
    'Dominica',
    'Dominican Republic',
    'Ecuador',
    'Egypt',
    'El Salvador',
    'Equatorial Guinea',
    'Eritrea',
    'Estonia',
    'Eswatini',
    'Ethiopia',
    'Fiji',
    'Finland',
    'France',
    'Gabon',
    'Gambia',
    'Georgia',
    'Germany',
    'Ghana',
    'Greece',
    'Grenada',
    'Guatemala',
    'Guinea',
    'Guinea-Bissau',
    'Guyana',
    'Haiti',
    'Honduras',
    'Hungary',
    'Iceland',
    'India',
    'Indonesia',
    'Iran',
    'Iraq',
    'Ireland',
    'Israel',
    'Italy',
    'Jamaica',
    'Japan',
    'Jordan',
    'Kazakhstan',
    'Kenya',
    'Kiribati',
    'Kuwait',
    'Kyrgyzstan',
    'Laos',
    'Latvia',
    'Lebanon',
    'Lesotho',
    'Liberia',
    'Libya',
    'Liechtenstein',
    'Lithuania',
    'Luxembourg',
    'Madagascar',
    'Malawi',
    'Malaysia',
    'Maldives',
    'Mali',
    'Malta',
    'Marshall Islands',
    'Mauritania',
    'Mauritius',
    'Mexico',
    'Micronesia',
    'Moldova',
    'Monaco',
    'Mongolia',
    'Montenegro',
    'Morocco',
    'Mozambique',
    'Myanmar',
    'Namibia',
    'Nauru',
    'Nepal',
    'Netherlands',
    'New Zealand',
    'Nicaragua',
    'Niger',
    'Nigeria',
    'North Korea',
    'North Macedonia',
    'Norway',
    'Oman',
    'Pakistan',
    'Palau',
    'Palestine',
    'Panama',
    'Papua New Guinea',
    'Paraguay',
    'Peru',
    'Philippines',
    'Poland',
    'Portugal',
    'Qatar',
    'Romania',
    'Russia',
    'Rwanda',
    'Saint Kitts and Nevis',
    'Saint Lucia',
    'Saint Vincent and the Grenadines',
    'Samoa',
    'San Marino',
    'Sao Tome and Principe',
    'Saudi Arabia',
    'Senegal',
    'Serbia',
    'Seychelles',
    'Sierra Leone',
    'Singapore',
    'Slovakia',
    'Slovenia',
    'Solomon Islands',
    'Somalia',
    'South Africa',
    'South Korea',
    'South Sudan',
    'Spain',
    'Sri Lanka',
    'Sudan',
    'Suriname',
    'Sweden',
    'Switzerland',
    'Syria',
    'Taiwan',
    'Tajikistan',
    'Tanzania',
    'Thailand',
    'Timor-Leste',
    'Togo',
    'Tonga',
    'Trinidad and Tobago',
    'Tunisia',
    'Turkey',
    'Turkmenistan',
    'Tuvalu',
    'Uganda',
    'Ukraine',
    'United Arab Emirates',
    'United Kingdom',
    'United States',
    'Uruguay',
    'Uzbekistan',
    'Vanuatu',
    'Vatican City',
    'Venezuela',
    'Vietnam',
    'Yemen',
    'Zambia',
    'Zimbabwe'
  ];
}

Future<List<String>> fetchCountries() async {
  // For web, CORS might be an issue, but we'll try the API first
  // List of API endpoints to try (v3.1 first as it's the latest)
  List<String> apiEndpoints = [
    'https://restcountries.com/v3.1/all?fields=name',
    'https://restcountries.com/v3.1/all',
    'https://restcountries.com/v2/all',
  ];
  
  // Try each API endpoint
  for (String endpoint in apiEndpoints) {
    try {
      print('Attempting to fetch from: $endpoint');
      
      // Create a simple GET request
      final uri = Uri.parse(endpoint);
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );
      
      print('API Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        try {
          List<dynamic> countriesJson = json.decode(response.body);
          List<String> countryList = countriesJson
              .map((country) {
                // Handle v3.1 format (name.common)
                if (country['name'] is Map) {
                  final nameMap = country['name'] as Map;
                  if (nameMap['common'] != null) {
                    return nameMap['common'] as String;
                  }
                }
                // Handle v2 format (name as string)
                if (country['name'] is String) {
                  return country['name'] as String;
                }
                return '';
              })
              .where((name) => name.isNotEmpty)
              .toList();
          
          if (countryList.isNotEmpty) {
            countryList.sort();
            print('Successfully fetched ${countryList.length} countries from API');
            return countryList;
          }
        } catch (parseError) {
          print('Error parsing JSON: $parseError');
          continue; // Try next endpoint
        }
      } else {
        print('API returned status code: ${response.statusCode}');
        if (response.body.isNotEmpty) {
          String preview = response.body.length > 200 
              ? response.body.substring(0, 200) 
              : response.body;
          print('Response preview: $preview');
        }
        // Try next endpoint
        continue;
      }
    } catch (e) {
      print('Error fetching from $endpoint: $e');
      // Try next endpoint
      continue;
    }
  }
  
  // All API endpoints failed, use comprehensive default list
  print('All API endpoints failed, using default country list');
  List<String> countries = _getDefaultCountries();
  countries.sort();
  print('Using default list with ${countries.length} countries');
  return countries;
}