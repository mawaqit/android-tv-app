class Country {
  String name;
  String isoCode;
  List<String> timezones;

  Country.empty()
      : name = '',
        isoCode = '',
        timezones = [];

  Country.from(Map<String, dynamic> map)
      : name = map['name'] ?? '',
        isoCode = map['isoCode'] ?? '',
        timezones = List<String>.from(map['Timezone'] ?? []);

  @override
  String toString() {
    return '{name: $name, isoCode: $isoCode, timezones: $timezones}';
  }
}

class Countries {
  static List<Country> get list => _list;
  static final List<Country> _list = [
    {
      'name': 'Afghanistan',
      'isoCode': 'AF',
      'Timezone': ['Asia/Kabul']
    },
    {
      'name': 'Aland Islands',
      'isoCode': 'AX',
      'Timezone': ['Europe/Mariehamn']
    },
    {
      'name': 'Albania',
      'isoCode': 'AL',
      'Timezone': ['Europe/Tirane']
    },
    {
      'name': 'Algeria',
      'isoCode': 'DZ',
      'Timezone': ['Africa/Algiers']
    },
    {
      'name': 'AmericanSamoa',
      'isoCode': 'AS',
      'Timezone': ['Pacific/Pago_Pago']
    },
    {
      'name': 'Andorra',
      'isoCode': 'AD',
      'Timezone': ['Europe/Andorra']
    },
    {
      'name': 'Angola',
      'isoCode': 'AO',
      'Timezone': ['Africa/Luanda']
    },
    {
      'name': 'Anguilla',
      'isoCode': 'AI',
      'Timezone': ['America/Anguilla']
    },
    {
      'name': 'Antarctica',
      'isoCode': 'AQ',
      'Timezone': [
        'Antarctica/McMurdo',
        'Antarctica/Casey',
        'Antarctica/Davis',
        'Antarctica/DumontDUrville',
        'Antarctica/Mawson',
        'Antarctica/Palmer',
        'Antarctica/Rothera',
        'Antarctica/Syowa',
        'Antarctica/Troll',
        'Antarctica/Vostok'
      ]
    },
    {
      'name': 'Antigua and Barbuda',
      'isoCode': 'AG',
      'Timezone': ['America/Antigua']
    },
    {
      'name': 'Argentina',
      'isoCode': 'AR',
      'Timezone': [
        'America/Argentina/Buenos_Aires',
        'America/Argentina/Cordoba',
        'America/Argentina/Salta',
        'America/Argentina/Jujuy',
        'America/Argentina/Tucuman',
        'America/Argentina/Catamarca',
        'America/Argentina/La_Rioja',
        'America/Argentina/San_Juan',
        'America/Argentina/Mendoza',
        'America/Argentina/San_Luis',
        'America/Argentina/Rio_Gallegos',
        'America/Argentina/Ushuaia'
      ]
    },
    {
      'name': 'Armenia',
      'isoCode': 'AM',
      'Timezone': ['Asia/Yerevan']
    },
    {
      'name': 'Aruba',
      'isoCode': 'AW',
      'Timezone': ['America/Aruba']
    },
    {
      'name': 'Australia',
      'isoCode': 'AU',
      'Timezone': [
        'Australia/Lord_Howe',
        'Antarctica/Macquarie',
        'Australia/Hobart',
        'Australia/Melbourne',
        'Australia/Sydney',
        'Australia/Broken_Hill',
        'Australia/Brisbane',
        'Australia/Lindeman',
        'Australia/Adelaide',
        'Australia/Darwin',
        'Australia/Perth',
        'Australia/Eucla'
      ]
    },
    {
      'name': 'Austria',
      'isoCode': 'AT',
      'Timezone': ['Europe/Vienna']
    },
    {
      'name': 'Azerbaijan',
      'isoCode': 'AZ',
      'Timezone': ['Asia/Baku']
    },
    {
      'name': 'Bahamas',
      'isoCode': 'BS',
      'Timezone': ['America/Nassau']
    },
    {
      'name': 'Bahrain',
      'isoCode': 'BH',
      'Timezone': ['Asia/Bahrain']
    },
    {
      'name': 'Bangladesh',
      'isoCode': 'BD',
      'Timezone': ['Asia/Dhaka']
    },
    {
      'name': 'Barbados',
      'isoCode': 'BB',
      'Timezone': ['America/Barbados']
    },
    {
      'name': 'Belarus',
      'isoCode': 'BY',
      'Timezone': ['Europe/Minsk']
    },
    {
      'name': 'Belgium',
      'isoCode': 'BE',
      'Timezone': ['Europe/Brussels']
    },
    {
      'name': 'Belize',
      'isoCode': 'BZ',
      'Timezone': ['America/Belize']
    },
    {
      'name': 'Benin',
      'isoCode': 'BJ',
      'Timezone': ['Africa/Porto-Novo']
    },
    {
      'name': 'Bermuda',
      'isoCode': 'BM',
      'Timezone': ['Atlantic/Bermuda']
    },
    {
      'name': 'Bhutan',
      'isoCode': 'BT',
      'Timezone': ['Asia/Thimphu']
    },
    {
      'name': 'Bolivia, Plurinational State of',
      'isoCode': 'BO',
      'Timezone': ['America/La_Paz']
    },
    {
      'name': 'Bosnia and Herzegovina',
      'isoCode': 'BA',
      'Timezone': ['Europe/Sarajevo']
    },
    {
      'name': 'Botswana',
      'isoCode': 'BW',
      'Timezone': ['Africa/Gaborone']
    },
    {
      'name': 'Brazil',
      'isoCode': 'BR',
      'Timezone': [
        'America/Noronha',
        'America/Belem',
        'America/Fortaleza',
        'America/Recife',
        'America/Araguaina',
        'America/Maceio',
        'America/Bahia',
        'America/Sao_Paulo',
        'America/Campo_Grande',
        'America/Cuiaba',
        'America/Santarem',
        'America/Porto_Velho',
        'America/Boa_Vista',
        'America/Manaus',
        'America/Eirunepe',
        'America/Rio_Branco'
      ]
    },
    {
      'name': 'British Indian Ocean Territory',
      'isoCode': 'IO',
      'Timezone': ['Indian/Chagos']
    },
    {
      'name': 'Brunei Darussalam',
      'isoCode': 'BN',
      'Timezone': ['Asia/Brunei']
    },
    {
      'name': 'Bulgaria',
      'isoCode': 'BG',
      'Timezone': ['Europe/Sofia']
    },
    {
      'name': 'Burkina Faso',
      'isoCode': 'BF',
      'Timezone': ['Africa/Ouagadougou']
    },
    {
      'name': 'Burundi',
      'isoCode': 'BI',
      'Timezone': ['Africa/Bujumbura']
    },
    {
      'name': 'Cambodia',
      'isoCode': 'KH',
      'Timezone': ['Asia/Phnom_Penh']
    },
    {
      'name': 'Cameroon',
      'isoCode': 'CM',
      'Timezone': ['Africa/Douala']
    },
    {
      'name': 'Canada',
      'isoCode': 'CA',
      'Timezone': [
        'America/St_Johns',
        'America/Halifax',
        'America/Glace_Bay',
        'America/Moncton',
        'America/Goose_Bay',
        'America/Blanc-Sablon',
        'America/Toronto',
        'America/Iqaluit',
        'America/Atikokan',
        'America/Winnipeg',
        'America/Resolute',
        'America/Rankin_Inlet',
        'America/Regina',
        'America/Swift_Current',
        'America/Edmonton',
        'America/Cambridge_Bay',
        'America/Yellowknife',
        'America/Inuvik',
        'America/Creston',
        'America/Dawson_Creek',
        'America/Fort_Nelson',
        'America/Whitehorse',
        'America/Dawson',
        'America/Vancouver'
      ]
    },
    {
      'name': 'Cape Verde',
      'isoCode': 'CV',
      'Timezone': ['Atlantic/Cape_Verde']
    },
    {
      'name': 'Cayman Islands',
      'isoCode': 'KY',
      'Timezone': ['America/Cayman']
    },
    {
      'name': 'Central African Republic',
      'isoCode': 'CF',
      'Timezone': ['Africa/Bangui']
    },
    {
      'name': 'Chad',
      'isoCode': 'TD',
      'Timezone': ['Africa/Ndjamena']
    },
    {
      'name': 'Chile',
      'isoCode': 'CL',
      'Timezone': ['America/Santiago', 'America/Punta_Arenas', 'Pacific/Easter']
    },
    {
      'name': 'China',
      'isoCode': 'CN',
      'Timezone': ['Asia/Shanghai', 'Asia/Urumqi']
    },
    {
      'name': 'Christmas Island',
      'isoCode': 'CX',
      'Timezone': ['Indian/Christmas']
    },
    {
      'name': 'Cocos (Keeling) Islands',
      'isoCode': 'CC',
      'Timezone': ['Indian/Cocos']
    },
    {
      'name': 'Colombia',
      'isoCode': 'CO',
      'Timezone': ['America/Bogota']
    },
    {
      'name': 'Comoros',
      'isoCode': 'KM',
      'Timezone': ['Indian/Comoro']
    },
    {
      'name': 'Congo',
      'isoCode': 'CG',
      'Timezone': ['Africa/Brazzaville']
    },
    {
      'name': 'Congo, The Democratic Republic of the Congo',
      'isoCode': 'CD',
      'Timezone': ['Africa/Kinshasa', 'Africa/Lubumbashi']
    },
    {
      'name': 'Cook Islands',
      'isoCode': 'CK',
      'Timezone': ['Pacific/Rarotonga']
    },
    {
      'name': 'Costa Rica',
      'isoCode': 'CR',
      'Timezone': ['America/Costa_Rica']
    },
    {
      'name': 'Cote Ivoire',
      'isoCode': 'CI',
      'Timezone': ['Africa/Abidjan']
    },
    {
      'name': 'Croatia',
      'isoCode': 'HR',
      'Timezone': ['Europe/Zagreb']
    },
    {
      'name': 'Cuba',
      'isoCode': 'CU',
      'Timezone': ['America/Havana']
    },
    {
      'name': 'Cyprus',
      'isoCode': 'CY',
      'Timezone': ['Asia/Nicosia', 'Asia/Famagusta']
    },
    {
      'name': 'Czech Republic',
      'isoCode': 'CZ',
      'Timezone': ['Europe/Prague']
    },
    {
      'name': 'Denmark',
      'isoCode': 'DK',
      'Timezone': ['Europe/Copenhagen']
    },
    {
      'name': 'Djibouti',
      'isoCode': 'DJ',
      'Timezone': ['Africa/Djibouti']
    },
    {
      'name': 'Dominica',
      'isoCode': 'DM',
      'Timezone': ['America/Dominica']
    },
    {
      'name': 'Dominican Republic',
      'isoCode': 'DO',
      'Timezone': ['America/Santo_Domingo']
    },
    {
      'name': 'Ecuador',
      'isoCode': 'EC',
      'Timezone': ['America/Guayaquil', 'Pacific/Galapagos']
    },
    {
      'name': 'Egypt',
      'isoCode': 'EG',
      'Timezone': ['Africa/Cairo']
    },
    {
      'name': 'El Salvador',
      'isoCode': 'SV',
      'Timezone': ['America/El_Salvador']
    },
    {
      'name': 'Equatorial Guinea',
      'isoCode': 'GQ',
      'Timezone': ['Africa/Malabo']
    },
    {
      'name': 'Eritrea',
      'isoCode': 'ER',
      'Timezone': ['Africa/Asmara']
    },
    {
      'name': 'Estonia',
      'isoCode': 'EE',
      'Timezone': ['Europe/Tallinn']
    },
    {
      'name': 'Ethiopia',
      'isoCode': 'ET',
      'Timezone': ['Africa/Addis_Ababa']
    },
    {
      'name': 'Falkland Islands (Malvinas)',
      'isoCode': 'FK',
      'Timezone': ['Atlantic/Stanley']
    },
    {
      'name': 'Faroe Islands',
      'isoCode': 'FO',
      'Timezone': ['Atlantic/Faroe']
    },
    {
      'name': 'Fiji',
      'isoCode': 'FJ',
      'Timezone': ['Pacific/Fiji']
    },
    {
      'name': 'Finland',
      'isoCode': 'FI',
      'Timezone': ['Europe/Helsinki']
    },
    {
      'name': 'France',
      'isoCode': 'FR',
      'Timezone': ['Europe/Paris']
    },
    {
      'name': 'French Guiana',
      'isoCode': 'GF',
      'Timezone': ['America/Cayenne']
    },
    {
      'name': 'French Polynesia',
      'isoCode': 'PF',
      'Timezone': ['Pacific/Tahiti', 'Pacific/Marquesas', 'Pacific/Gambier']
    },
    {
      'name': 'Gabon',
      'isoCode': 'GA',
      'Timezone': ['Africa/Libreville']
    },
    {
      'name': 'Gambia',
      'isoCode': 'GM',
      'Timezone': ['Africa/Banjul']
    },
    {
      'name': 'Georgia',
      'isoCode': 'GE',
      'Timezone': ['Asia/Tbilisi']
    },
    {
      'name': 'Germany',
      'isoCode': 'DE',
      'Timezone': ['Europe/Berlin', 'Europe/Busingen']
    },
    {
      'name': 'Ghana',
      'isoCode': 'GH',
      'Timezone': ['Africa/Accra']
    },
    {
      'name': 'Gibraltar',
      'isoCode': 'GI',
      'Timezone': ['Europe/Gibraltar']
    },
    {
      'name': 'Greece',
      'isoCode': 'GR',
      'Timezone': ['Europe/Athens']
    },
    {
      'name': 'Greenland',
      'isoCode': 'GL',
      'Timezone': [
        'America/Nuuk',
        'America/Danmarkshavn',
        'America/Scoresbysund',
        'America/Thule'
      ]
    },
    {
      'name': 'Grenada',
      'isoCode': 'GD',
      'Timezone': ['America/Grenada']
    },
    {
      'name': 'Guadeloupe',
      'isoCode': 'GP',
      'Timezone': ['America/Guadeloupe']
    },
    {
      'name': 'Guam',
      'isoCode': 'GU',
      'Timezone': ['Pacific/Guam']
    },
    {
      'name': 'Guatemala',
      'isoCode': 'GT',
      'Timezone': ['America/Guatemala']
    },
    {
      'name': 'Guernsey',
      'isoCode': 'GG',
      'Timezone': ['Europe/Guernsey']
    },
    {
      'name': 'Guinea',
      'isoCode': 'GN',
      'Timezone': ['Africa/Conakry']
    },
    {
      'name': 'Guinea-Bissau',
      'isoCode': 'GW',
      'Timezone': ['Africa/Bissau']
    },
    {
      'name': 'Guyana',
      'isoCode': 'GY',
      'Timezone': ['America/Guyana']
    },
    {
      'name': 'Haiti',
      'isoCode': 'HT',
      'Timezone': ['America/Port-au-Prince']
    },
    {
      'name': 'Holy See (Vatican City State)',
      'isoCode': 'VA',
      'Timezone': ['Europe/Vatican']
    },
    {
      'name': 'Honduras',
      'isoCode': 'HN',
      'Timezone': ['America/Tegucigalpa']
    },
    {
      'name': 'Hong Kong',
      'isoCode': 'HK',
      'Timezone': ['Asia/Hong_Kong']
    },
    {
      'name': 'Hungary',
      'isoCode': 'HU',
      'Timezone': ['Europe/Budapest']
    },
    {
      'name': 'Iceland',
      'isoCode': 'IS',
      'Timezone': ['Atlantic/Reykjavik']
    },
    {
      'name': 'India',
      'isoCode': 'IN',
      'Timezone': ['Asia/Kolkata']
    },
    {
      'name': 'Indonesia',
      'isoCode': 'ID',
      'Timezone': [
        'Asia/Jakarta',
        'Asia/Pontianak',
        'Asia/Makassar',
        'Asia/Jayapura'
      ]
    },
    {
      'name': 'Iran, Islamic Republic of Persian Gulf',
      'isoCode': 'IR',
      'Timezone': ['Asia/Tehran']
    },
    {
      'name': 'Iraq',
      'isoCode': 'IQ',
      'Timezone': ['Asia/Baghdad']
    },
    {
      'name': 'Ireland',
      'isoCode': 'IE',
      'Timezone': ['Europe/Dublin']
    },
    {
      'name': 'Isle of Man',
      'isoCode': 'IM',
      'Timezone': ['Europe/Isle_of_Man']
    },
    {
      'name': 'Israel',
      'isoCode': 'IL',
      'Timezone': ['Asia/Jerusalem']
    },
    {
      'name': 'Italy',
      'isoCode': 'IT',
      'Timezone': ['Europe/Rome']
    },
    {
      'name': 'Jamaica',
      'isoCode': 'JM',
      'Timezone': ['America/Jamaica']
    },
    {
      'name': 'Japan',
      'isoCode': 'JP',
      'Timezone': ['Asia/Tokyo']
    },
    {
      'name': 'Jersey',
      'isoCode': 'JE',
      'Timezone': ['Europe/Jersey']
    },
    {
      'name': 'Jordan',
      'isoCode': 'JO',
      'Timezone': ['Asia/Amman']
    },
    {
      'name': 'Kazakhstan',
      'isoCode': 'KZ',
      'Timezone': [
        'Asia/Almaty',
        'Asia/Qyzylorda',
        'Asia/Qostanay',
        'Asia/Aqtobe',
        'Asia/Aqtau',
        'Asia/Atyrau',
        'Asia/Oral'
      ]
    },
    {
      'name': 'Kenya',
      'isoCode': 'KE',
      'Timezone': ['Africa/Nairobi']
    },
    {
      'name': 'Kiribati',
      'isoCode': 'KI',
      'Timezone': ['Pacific/Tarawa', 'Pacific/Kanton', 'Pacific/Kiritimati']
    },
    {
      'name': 'Korea, Democratic People Republic of Korea',
      'isoCode': 'KP',
      'Timezone': ['Asia/Pyongyang']
    },
    {
      'name': 'Korea, Republic of South Korea',
      'isoCode': 'KR',
      'Timezone': ['Asia/Seoul']
    },
    {
      'name': 'Kuwait',
      'isoCode': 'KW',
      'Timezone': ['Asia/Kuwait']
    },
    {
      'name': 'Kyrgyzstan',
      'isoCode': 'KG',
      'Timezone': ['Asia/Bishkek']
    },
    {
      'name': 'Laos',
      'isoCode': 'LA',
      'Timezone': ['Asia/Vientiane']
    },
    {
      'name': 'Latvia',
      'isoCode': 'LV',
      'Timezone': ['Europe/Riga']
    },
    {
      'name': 'Lebanon',
      'isoCode': 'LB',
      'Timezone': ['Asia/Beirut']
    },
    {
      'name': 'Lesotho',
      'isoCode': 'LS',
      'Timezone': ['Africa/Maseru']
    },
    {
      'name': 'Liberia',
      'isoCode': 'LR',
      'Timezone': ['Africa/Monrovia']
    },
    {
      'name': 'Libyan Arab Jamahiriya',
      'isoCode': 'LY',
      'Timezone': ['Africa/Tripoli']
    },
    {
      'name': 'Liechtenstein',
      'isoCode': 'LI',
      'Timezone': ['Europe/Vaduz']
    },
    {
      'name': 'Lithuania',
      'isoCode': 'LT',
      'Timezone': ['Europe/Vilnius']
    },
    {
      'name': 'Luxembourg',
      'isoCode': 'LU',
      'Timezone': ['Europe/Luxembourg']
    },
    {
      'name': 'Macao',
      'isoCode': 'MO',
      'Timezone': ['Asia/Macau']
    },
    {
      'name': 'Macedonia',
      'isoCode': 'MK',
      'Timezone': ['Europe/Skopje']
    },
    {
      'name': 'Madagascar',
      'isoCode': 'MG',
      'Timezone': ['Indian/Antananarivo']
    },
    {
      'name': 'Malawi',
      'isoCode': 'MW',
      'Timezone': ['Africa/Blantyre']
    },
    {
      'name': 'Malaysia',
      'isoCode': 'MY',
      'Timezone': ['Asia/Kuala_Lumpur', 'Asia/Kuching']
    },
    {
      'name': 'Maldives',
      'isoCode': 'MV',
      'Timezone': ['Indian/Maldives']
    },
    {
      'name': 'Mali',
      'isoCode': 'ML',
      'Timezone': ['Africa/Bamako']
    },
    {
      'name': 'Malta',
      'isoCode': 'MT',
      'Timezone': ['Europe/Malta']
    },
    {
      'name': 'Marshall Islands',
      'isoCode': 'MH',
      'Timezone': ['Pacific/Majuro', 'Pacific/Kwajalein']
    },
    {
      'name': 'Martinique',
      'isoCode': 'MQ',
      'Timezone': ['America/Martinique']
    },
    {
      'name': 'Mauritania',
      'isoCode': 'MR',
      'Timezone': ['Africa/Nouakchott']
    },
    {
      'name': 'Mauritius',
      'isoCode': 'MU',
      'Timezone': ['Indian/Mauritius']
    },
    {
      'name': 'Mayotte',
      'isoCode': 'YT',
      'Timezone': ['Indian/Mayotte']
    },
    {
      'name': 'Mexico',
      'isoCode': 'MX',
      'Timezone': [
        'America/Mexico_City',
        'America/Cancun',
        'America/Merida',
        'America/Monterrey',
        'America/Matamoros',
        'America/Chihuahua',
        'America/Ciudad_Juarez',
        'America/Ojinaga',
        'America/Mazatlan',
        'America/Bahia_Banderas',
        'America/Hermosillo',
        'America/Tijuana'
      ]
    },
    {
      'name': 'Micronesia, Federated States of Micronesia',
      'isoCode': 'FM',
      'Timezone': ['Pacific/Chuuk', 'Pacific/Pohnpei', 'Pacific/Kosrae']
    },
    {
      'name': 'Moldova',
      'isoCode': 'MD',
      'Timezone': ['Europe/Chisinau']
    },
    {
      'name': 'Monaco',
      'isoCode': 'MC',
      'Timezone': ['Europe/Monaco']
    },
    {
      'name': 'Mongolia',
      'isoCode': 'MN',
      'Timezone': ['Asia/Ulaanbaatar', 'Asia/Hovd', 'Asia/Choibalsan']
    },
    {
      'name': 'Montenegro',
      'isoCode': 'ME',
      'Timezone': ['Europe/Podgorica']
    },
    {
      'name': 'Montserrat',
      'isoCode': 'MS',
      'Timezone': ['America/Montserrat']
    },
    {
      'name': 'Morocco',
      'isoCode': 'MA',
      'Timezone': ['Africa/Casablanca']
    },
    {
      'name': 'Mozambique',
      'isoCode': 'MZ',
      'Timezone': ['Africa/Maputo']
    },
    {
      'name': 'Myanmar',
      'isoCode': 'MM',
      'Timezone': ['Asia/Yangon']
    },
    {
      'name': 'Namibia',
      'isoCode': 'NA',
      'Timezone': ['Africa/Windhoek']
    },
    {
      'name': 'Nauru',
      'isoCode': 'NR',
      'Timezone': ['Pacific/Nauru']
    },
    {
      'name': 'Nepal',
      'isoCode': 'NP',
      'Timezone': ['Asia/Kathmandu']
    },
    {
      'name': 'Netherlands',
      'isoCode': 'NL',
      'Timezone': ['Europe/Amsterdam']
    },
    {'name': 'Netherlands Antilles', 'isoCode': 'AN', 'Timezone': []},
    {
      'name': 'New Caledonia',
      'isoCode': 'NC',
      'Timezone': ['Pacific/Noumea']
    },
    {
      'name': 'New Zealand',
      'isoCode': 'NZ',
      'Timezone': ['Pacific/Auckland', 'Pacific/Chatham']
    },
    {
      'name': 'Nicaragua',
      'isoCode': 'NI',
      'Timezone': ['America/Managua']
    },
    {
      'name': 'Niger',
      'isoCode': 'NE',
      'Timezone': ['Africa/Niamey']
    },
    {
      'name': 'Nigeria',
      'isoCode': 'NG',
      'Timezone': ['Africa/Lagos']
    },
    {
      'name': 'Niue',
      'isoCode': 'NU',
      'Timezone': ['Pacific/Niue']
    },
    {
      'name': 'Norfolk Island',
      'isoCode': 'NF',
      'Timezone': ['Pacific/Norfolk']
    },
    {
      'name': 'Northern Mariana Islands',
      'isoCode': 'MP',
      'Timezone': ['Pacific/Saipan']
    },
    {
      'name': 'Norway',
      'isoCode': 'NO',
      'Timezone': ['Europe/Oslo']
    },
    {
      'name': 'Oman',
      'isoCode': 'OM',
      'Timezone': ['Asia/Muscat']
    },
    {
      'name': 'Pakistan',
      'isoCode': 'PK',
      'Timezone': ['Asia/Karachi']
    },
    {
      'name': 'Palau',
      'isoCode': 'PW',
      'Timezone': ['Pacific/Palau']
    },
    {
      'name': 'Palestinian Territory, Occupied',
      'isoCode': 'PS',
      'Timezone': ['Asia/Gaza', 'Asia/Hebron']
    },
    {
      'name': 'Panama',
      'isoCode': 'PA',
      'Timezone': ['America/Panama']
    },
    {
      'name': 'Papua New Guinea',
      'isoCode': 'PG',
      'Timezone': ['Pacific/Port_Moresby', 'Pacific/Bougainville']
    },
    {
      'name': 'Paraguay',
      'isoCode': 'PY',
      'Timezone': ['America/Asuncion']
    },
    {
      'name': 'Peru',
      'isoCode': 'PE',
      'Timezone': ['America/Lima']
    },
    {
      'name': 'Philippines',
      'isoCode': 'PH',
      'Timezone': ['Asia/Manila']
    },
    {
      'name': 'Pitcairn',
      'isoCode': 'PN',
      'Timezone': ['Pacific/Pitcairn']
    },
    {
      'name': 'Poland',
      'isoCode': 'PL',
      'Timezone': ['Europe/Warsaw']
    },
    {
      'name': 'Portugal',
      'isoCode': 'PT',
      'Timezone': ['Europe/Lisbon', 'Atlantic/Madeira', 'Atlantic/Azores']
    },
    {
      'name': 'Puerto Rico',
      'isoCode': 'PR',
      'Timezone': ['America/Puerto_Rico']
    },
    {
      'name': 'Qatar',
      'isoCode': 'QA',
      'Timezone': ['Asia/Qatar']
    },
    {
      'name': 'Romania',
      'isoCode': 'RO',
      'Timezone': ['Europe/Bucharest']
    },
    {
      'name': 'Russia',
      'isoCode': 'RU',
      'Timezone': [
        'Europe/Kaliningrad',
        'Europe/Moscow',
        'Europe/Kirov',
        'Europe/Volgograd',
        'Europe/Astrakhan',
        'Europe/Saratov',
        'Europe/Ulyanovsk',
        'Europe/Samara',
        'Asia/Yekaterinburg',
        'Asia/Omsk',
        'Asia/Novosibirsk',
        'Asia/Barnaul',
        'Asia/Tomsk',
        'Asia/Novokuznetsk',
        'Asia/Krasnoyarsk',
        'Asia/Irkutsk',
        'Asia/Chita',
        'Asia/Yakutsk',
        'Asia/Khandyga',
        'Asia/Vladivostok',
        'Asia/Ust-Nera',
        'Asia/Magadan',
        'Asia/Sakhalin',
        'Asia/Srednekolymsk',
        'Asia/Kamchatka',
        'Asia/Anadyr'
      ]
    },
    {
      'name': 'Rwanda',
      'isoCode': 'RW',
      'Timezone': ['Africa/Kigali']
    },
    {
      'name': 'Reunion',
      'isoCode': 'RE',
      'Timezone': ['Indian/Reunion']
    },
    {
      'name': 'Saint Barthelemy',
      'isoCode': 'BL',
      'Timezone': ['America/St_Barthelemy']
    },
    {
      'name': 'Saint Helena, Ascension and Tristan Da Cunha',
      'isoCode': 'SH',
      'Timezone': ['Atlantic/St_Helena']
    },
    {
      'name': 'Saint Kitts and Nevis',
      'isoCode': 'KN',
      'Timezone': ['America/St_Kitts']
    },
    {
      'name': 'Saint Lucia',
      'isoCode': 'LC',
      'Timezone': ['America/St_Lucia']
    },
    {
      'name': 'Saint Martin',
      'isoCode': 'MF',
      'Timezone': ['America/Marigot']
    },
    {
      'name': 'Saint Pierre and Miquelon',
      'isoCode': 'PM',
      'Timezone': ['America/Miquelon']
    },
    {
      'name': 'Saint Vincent and the Grenadines',
      'isoCode': 'VC',
      'Timezone': ['America/St_Vincent']
    },
    {
      'name': 'Samoa',
      'isoCode': 'WS',
      'Timezone': ['Pacific/Apia']
    },
    {
      'name': 'San Marino',
      'isoCode': 'SM',
      'Timezone': ['Europe/San_Marino']
    },
    {
      'name': 'Sao Tome and Principe',
      'isoCode': 'ST',
      'Timezone': ['Africa/Sao_Tome']
    },
    {
      'name': 'Saudi Arabia',
      'isoCode': 'SA',
      'Timezone': ['Asia/Riyadh']
    },
    {
      'name': 'Senegal',
      'isoCode': 'SN',
      'Timezone': ['Africa/Dakar']
    },
    {
      'name': 'Serbia',
      'isoCode': 'RS',
      'Timezone': ['Europe/Belgrade']
    },
    {
      'name': 'Seychelles',
      'isoCode': 'SC',
      'Timezone': ['Indian/Mahe']
    },
    {
      'name': 'Sierra Leone',
      'isoCode': 'SL',
      'Timezone': ['Africa/Freetown']
    },
    {
      'name': 'Singapore',
      'isoCode': 'SG',
      'Timezone': ['Asia/Singapore']
    },
    {
      'name': 'Slovakia',
      'isoCode': 'SK',
      'Timezone': ['Europe/Bratislava']
    },
    {
      'name': 'Slovenia',
      'isoCode': 'SI',
      'Timezone': ['Europe/Ljubljana']
    },
    {
      'name': 'Solomon Islands',
      'isoCode': 'SB',
      'Timezone': ['Pacific/Guadalcanal']
    },
    {
      'name': 'Somalia',
      'isoCode': 'SO',
      'Timezone': ['Africa/Mogadishu']
    },
    {
      'name': 'South Africa',
      'isoCode': 'ZA',
      'Timezone': ['Africa/Johannesburg']
    },
    {
      'name': 'South Sudan',
      'isoCode': 'SS',
      'Timezone': ['Africa/Juba']
    },
    {
      'name': 'South Georgia and the South Sandwich Islands',
      'isoCode': 'GS',
      'Timezone': ['Atlantic/South_Georgia']
    },
    {
      'name': 'Spain',
      'isoCode': 'ES',
      'Timezone': ['Europe/Madrid', 'Africa/Ceuta', 'Atlantic/Canary']
    },
    {
      'name': 'Sri Lanka',
      'isoCode': 'LK',
      'Timezone': ['Asia/Colombo']
    },
    {
      'name': 'Sudan',
      'isoCode': 'SD',
      'Timezone': ['Africa/Khartoum']
    },
    {
      'name': 'Suriname',
      'isoCode': 'SR',
      'Timezone': ['America/Paramaribo']
    },
    {
      'name': 'Svalbard and Jan Mayen',
      'isoCode': 'SJ',
      'Timezone': ['Arctic/Longyearbyen']
    },
    {
      'name': 'Swaziland',
      'isoCode': 'SZ',
      'Timezone': ['Africa/Mbabane']
    },
    {
      'name': 'Sweden',
      'isoCode': 'SE',
      'Timezone': ['Europe/Stockholm']
    },
    {
      'name': 'Switzerland',
      'isoCode': 'CH',
      'Timezone': ['Europe/Zurich']
    },
    {
      'name': 'Syrian Arab Republic',
      'isoCode': 'SY',
      'Timezone': ['Asia/Damascus']
    },
    {
      'name': 'Taiwan',
      'isoCode': 'TW',
      'Timezone': ['Asia/Taipei']
    },
    {
      'name': 'Tajikistan',
      'isoCode': 'TJ',
      'Timezone': ['Asia/Dushanbe']
    },
    {
      'name': 'Tanzania, United Republic of Tanzania',
      'isoCode': 'TZ',
      'Timezone': ['Africa/Dar_es_Salaam']
    },
    {
      'name': 'Thailand',
      'isoCode': 'TH',
      'Timezone': ['Asia/Bangkok']
    },
    {
      'name': 'Timor-Leste',
      'isoCode': 'TL',
      'Timezone': ['Asia/Dili']
    },
    {
      'name': 'Togo',
      'isoCode': 'TG',
      'Timezone': ['Africa/Lome']
    },
    {
      'name': 'Tokelau',
      'isoCode': 'TK',
      'Timezone': ['Pacific/Fakaofo']
    },
    {
      'name': 'Tonga',
      'isoCode': 'TO',
      'Timezone': ['Pacific/Tongatapu']
    },
    {
      'name': 'Trinidad and Tobago',
      'isoCode': 'TT',
      'Timezone': ['America/Port_of_Spain']
    },
    {
      'name': 'Tunisia',
      'isoCode': 'TN',
      'Timezone': ['Africa/Tunis']
    },
    {
      'name': 'Turkey',
      'isoCode': 'TR',
      'Timezone': ['Europe/Istanbul']
    },
    {
      'name': 'Turkmenistan',
      'isoCode': 'TM',
      'Timezone': ['Asia/Ashgabat']
    },
    {
      'name': 'Turks and Caicos Islands',
      'isoCode': 'TC',
      'Timezone': ['America/Grand_Turk']
    },
    {
      'name': 'Tuvalu',
      'isoCode': 'TV',
      'Timezone': ['Pacific/Funafuti']
    },
    {
      'name': 'Uganda',
      'isoCode': 'UG',
      'Timezone': ['Africa/Kampala']
    },
    {
      'name': 'Ukraine',
      'isoCode': 'UA',
      'Timezone': ['Europe/Simferopol', 'Europe/Kyiv']
    },
    {
      'name': 'United Arab Emirates',
      'isoCode': 'AE',
      'Timezone': ['Asia/Dubai']
    },
    {
      'name': 'United Kingdom',
      'isoCode': 'GB',
      'Timezone': ['Europe/London']
    },
    {
      'name': 'United States',
      'isoCode': 'US',
      'Timezone': [
        'America/New_York',
        'America/Detroit',
        'America/Kentucky/Louisville',
        'America/Kentucky/Monticello',
        'America/Indiana/Indianapolis',
        'America/Indiana/Vincennes',
        'America/Indiana/Winamac',
        'America/Indiana/Marengo',
        'America/Indiana/Petersburg',
        'America/Indiana/Vevay',
        'America/Chicago',
        'America/Indiana/Tell_City',
        'America/Indiana/Knox',
        'America/Menominee',
        'America/North_Dakota/Center',
        'America/North_Dakota/New_Salem',
        'America/North_Dakota/Beulah',
        'America/Denver',
        'America/Boise',
        'America/Phoenix',
        'America/Los_Angeles',
        'America/Anchorage',
        'America/Juneau',
        'America/Sitka',
        'America/Metlakatla',
        'America/Yakutat',
        'America/Nome',
        'America/Adak',
        'Pacific/Honolulu'
      ]
    },
    {
      'name': 'Uruguay',
      'isoCode': 'UY',
      'Timezone': ['America/Montevideo']
    },
    {
      'name': 'Uzbekistan',
      'isoCode': 'UZ',
      'Timezone': ['Asia/Samarkand', 'Asia/Tashkent']
    },
    {
      'name': 'Vanuatu',
      'isoCode': 'VU',
      'Timezone': ['Pacific/Efate']
    },
    {
      'name': 'Venezuela, Bolivarian Republic of Venezuela',
      'isoCode': 'VE',
      'Timezone': ['America/Caracas']
    },
    {
      'name': 'Vietnam',
      'isoCode': 'VN',
      'Timezone': ['Asia/Ho_Chi_Minh']
    },
    {
      'name': 'Virgin Islands, British',
      'isoCode': 'VG',
      'Timezone': ['America/Tortola']
    },
    {
      'name': 'Virgin Islands, U.S.',
      'isoCode': 'VI',
      'Timezone': ['America/St_Thomas']
    },
    {
      'name': 'Wallis and Futuna',
      'isoCode': 'WF',
      'Timezone': ['Pacific/Wallis']
    },
    {
      'name': 'Yemen',
      'isoCode': 'YE',
      'Timezone': ['Asia/Aden']
    },
    {
      'name': 'Zambia',
      'isoCode': 'ZM',
      'Timezone': ['Africa/Lusaka']
    },
    {
      'name': 'Zimbabwe',
      'isoCode': 'ZW',
      'Timezone': ['Africa/Harare']
    },
  ].map((e) => Country.from(e)).toList();
}
